<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{

    // 1. Fetch modules booked by a specific student
    public function getStudentBookings($studentId)
    {
        try {
            // Join bookings with modules table first
            $bookings = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                
                // 🎯 FIXED LEFT JOINS: Stepping through your real ER diagram tables path cleanly
                ->leftJoin('module_attendances', 'modules.id', '=', 'module_attendances.module_id')
                ->leftJoin('attendances', 'module_attendances.attendance_id', '=', 'attendances.id')
                
                // Left join the records but match BOTH the attendance ID AND this specific student's ID
                ->leftJoin('attendance_records', function($join) use ($studentId) {
                    $join->on('attendances.id', '=', 'attendance_records.attendance_id')
                         ->on('bookings.student_id', '=', 'attendance_records.student_id');
                })
                
                // Filter records by the logged-in student's ID
                ->where('bookings.student_id', $studentId)
                
                // Select attributes to display for your Flutter model fields layout map
                ->select(
                    'bookings.id as booking_id', 
                    'modules.id as id', // Added so your Flutter Module object factory matches keys
                    'modules.activity_name',
                    'modules.date_time',
                    'modules.venue',
                    'bookings.is_claimed',
                    DB::raw('MAX(attendance_records.status) as attendance_status'),
                    DB::raw('MAX(attendance_records.marks) as total_marks')
                )
                ->groupBy(
                    'bookings.id',
                    'modules.id',
                    'modules.activity_name',
                    'modules.date_time',
                    'modules.venue',
                    'bookings.is_claimed'
                )
                ->get();

            // Return clean JSON payload response
            return response()->json([
                'status' => 'success',
                'data' => $bookings
            ], 200);

        } catch (\Exception $e) {
            // Handle execution fallback error exceptions
            return response()->json([
                'status' => 'error',
                'message' => 'Database operation failed to compile: ' . $e->getMessage()
            ], 500);
        }
    }

    // 2. Student apply module
    public function applyToModule(Request $request)
    {
        $request->validate([
            'module_id' => 'required|integer',
            'student_id' => 'required|integer',
        ]);

        $moduleId = $request->input('module_id');
        $studentId = $request->input('student_id');

        // Fetch the target module details first
        $targetModule = DB::table('modules')->where('id', $moduleId)->first();
        if (!$targetModule) {
            return response()->json(['message' => 'Module session not found!'], 404);
        }

        return DB::transaction(function () use ($targetModule, $moduleId, $studentId) {

            $sameSessionAlreadyBooked = DB::table('bookings')
                ->where('student_id', $studentId)
                ->where('module_id', $moduleId)
                ->lockForUpdate()
                ->exists();

            if ($sameSessionAlreadyBooked) {
                return response()->json(['message' => 'Already registered for this module!'], 400);
            }

            // 🎯 FIXED QUERY: Matches your phpMyAdmin 'attendances' table columns exactly
            $alreadyBooked = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $studentId)
                ->where('modules.activity_name', $targetModule->activity_name)
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('module_attendances')
                        ->join('attendances', 'module_attendances.attendance_id', '=', 'attendances.id') // ◄ FIXED: table is 'attendances', column is '.id'
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id') // ◄ FIXED: matching on '.id'
                        ->whereColumn('module_attendances.module_id', 'bookings.module_id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->exists();

            if ($alreadyBooked) {
                return response()->json(['message' => 'Already registered for this module type!'], 400);
            }

            // Count current total active module registrations for the student
            $activeBookingCount = DB::table('bookings')
                ->where('bookings.student_id', $studentId)
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('module_attendances')
                        ->join('attendances', 'module_attendances.attendance_id', '=', 'attendances.id') // ◄ FIXED here too
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id') // ◄ FIXED here too
                        ->whereColumn('module_attendances.module_id', 'bookings.module_id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->count();

            if ($activeBookingCount >= 4) {
                return response()->json([
                    'message' => 'You can only register up to 4 modules. If one module is marked absent, you may register another module.'
                ], 400);
            }

            // Lock the row for capacity verification safely
            $moduleLock = DB::table('modules')->where('id', $moduleId)->lockForUpdate()->first();

            if (($moduleLock->capacity - $moduleLock->current_registration) <= 0) {
                return response()->json(['message' => 'Module full!'], 400);
            }

            // Insert the new booking row data cleanly
            DB::table('bookings')->insert([
                'student_id' => $studentId,
                'module_id' => $moduleId,
                'is_claimed' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Increment the current registration count counter
            DB::table('modules')->where('id', $moduleId)->increment('current_registration', 1);

            return response()->json(['message' => 'Module added successfully!'], 200);
        });
    }

    // 3. Student drop module
    public function destroy($id)
    {
        // Search the selected module to drop
        $booking = DB::table('bookings')->where('id', $id)->first();

        if ($booking) {
            // Remove the choosen module out of database table
            DB::table('bookings')->where('id', $id)->delete();

            // Recalculate remaining active bookings for the specific module 
            $remainingRegistration = DB::table('bookings')
                ->where('module_id', $booking->module_id)
                ->count();

            // Update module registration capacity
            DB::table('modules')
                ->where('id', $booking->module_id)
                ->update([
                    'current_registration' => $remainingRegistration,
                    'updated_at' => now(),
                ]);

            // Return success message and updated module registration capacity 
            return response()->json([
                'message' => 'Successfully deleted',
                'module_id' => $booking->module_id,
                'current_registration' => $remainingRegistration,
            ], 200);
        }
        // If booking not found, display error message
        return response()->json(['message' => 'Booking not found'], 404);
    }

    // 4. View registered students for a specific module 
    public function getRegisteredStudents($moduleId)
    {
        // Retrieve students registered of the selected module
        $registeredStudents = DB::table('bookings')
        // Join bookings with students and users tables to get student details
            ->join('students', 'bookings.student_id', '=', 'students.id')
            ->leftJoin('users', 'bookings.student_id', '=', 'users.id')
            ->where('bookings.module_id', $moduleId)
            ->select(
                'bookings.id as booking_id',
                'bookings.module_id',
                'students.student_id as matric_id',    
                DB::raw('COALESCE(users.name, students.student_id) as student_name')
            )
            ->orderBy('users.name')
            ->get();
            
        // Return JSON payload response
        return response()->json($registeredStudents); 
    }
}
