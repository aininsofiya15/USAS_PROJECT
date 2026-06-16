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
            // Join bookings with modules and attendance tables
            $bookings = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                
                // Left join to display bookings even if attendance didnt recorded yet
                ->leftJoin('attendances', 'bookings.id', '=', 'attendances.booking_id')
                ->leftJoin('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                
                // Filter records by the student's ID
                ->where('bookings.student_id', $studentId)
                // Select attributes to display for each booking
                ->select(
                    'bookings.id as booking_id', 
                    'modules.activity_name',
                    'modules.date_time',
                    'modules.venue',
                    'bookings.is_claimed',
                    'attendance_records.status as attendance_status', 
                    'attendance_records.marks as total_marks'         
                )
                ->get();

            // Return JSON payload response
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
        // Validate request attributes
        $request->validate([
            'module_id' => 'required|integer',
            'student_id' => 'required|integer',
        ]);

        // Extract validated input data
        $moduleId = $request->input('module_id');
        $studentId = $request->input('student_id');

        return DB::transaction(function () use ($moduleId, $studentId) {

            // Check for duplicate registrations of the same module 
            $alreadyBooked = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $studentId)
                ->where('modules.activity_name', function($query) use ($moduleId) {
                    $query->select('activity_name')->from('modules')->where('id', $moduleId);
                })
                // Exclude modules where the student was marked absent
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('attendances')
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                        ->whereColumn('attendances.booking_id', 'bookings.id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->exists();

            // Error message if the selected module already booked
            if ($alreadyBooked) {
                return response()->json(['message' => 'Already registered for this module type!'], 400);
            }

            // Count current total module registrations for the student
            $activeBookingCount = DB::table('bookings')
                ->where('bookings.student_id', $studentId)
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('attendances')
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                        ->whereColumn('attendances.booking_id', 'bookings.id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->count();

            // Display error message if student has already registered 4 module
            if ($activeBookingCount >= 4) {
                return response()->json([
                    'message' => 'You can only register up to 4 modules. If one module is marked absent, you may register another module.'
                ], 400);
            }

            $module = DB::table('modules')->where('id', $moduleId)->lockForUpdate()->first();

            // Validate seat availability capacity checks
            if (!$module || ($module->capacity - $module->current_registration) <= 0) {
                return response()->json(['message' => 'Module full or not found!'], 400);
            }

            // Insert the registered module and student into database
            DB::table('bookings')->insert([
                'student_id' => $studentId,
                'module_id' => $moduleId,
                'is_claimed' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Increment the module registration number capacity
            DB::table('modules')->where('id', $moduleId)->increment('current_registration', 1);

            // Display success message
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