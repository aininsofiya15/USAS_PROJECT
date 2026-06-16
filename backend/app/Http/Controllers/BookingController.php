<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{
    /**
     * Fetch modules booked by a specific student for "My Curriculum"
     */
    public function getStudentBookings($studentId)
        {
            try {
                // Query the bookings table by linking it safely to the specific module session records
                $bookings = DB::table('bookings')
                    ->join('modules', 'bookings.module_id', '=', 'modules.id')
                    
                    // 🎯 FIXED CHAIN: Link bookings to their respective module attendance record row entries
                    ->leftJoin('attendances', 'bookings.id', '=', 'attendances.booking_id')
                    ->leftJoin('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                    
                    // Filter down to pull only this specific student's rows
                    ->where('bookings.student_id', $studentId)
                    ->select(
                        'bookings.id as booking_id', // Changed to avoid collisions on your front-end model mapping
                        'modules.activity_name',
                        'modules.date_time',
                        'modules.venue',
                        'bookings.is_claimed',
                        'attendance_records.status as attendance_status', // Captures active status strings cleanly
                        'attendance_records.marks as total_marks'         // Aliased explicitly to prevent front-end drop nulls
                    )
                    ->get();

                // Return the structured payload list wrapper straight back up the pipeline
                return response()->json([
                    'status' => 'success',
                    'data' => $bookings
                ], 200);

            } catch (\Exception $e) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Database operation failed to compile: ' . $e->getMessage()
                ], 500);
            }
        }

    /**
     * Register a student for a module (Atomic Transaction)
     */
    public function applyToModule(Request $request)
    {
        $request->validate([
            'module_id' => 'required|integer',
            'student_id' => 'required|integer',
        ]);

        $moduleId = $request->input('module_id');
        $studentId = $request->input('student_id');

        return DB::transaction(function () use ($moduleId, $studentId) {
            // Check for duplicate registration by module name
            $alreadyBooked = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $studentId)
                ->where('modules.activity_name', function($query) use ($moduleId) {
                    $query->select('activity_name')->from('modules')->where('id', $moduleId);
                })
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('attendances')
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                        ->whereColumn('attendances.booking_id', 'bookings.id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->exists();

            if ($alreadyBooked) {
                return response()->json(['message' => 'Already registered for this module type!'], 400);
            }

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

            if ($activeBookingCount >= 4) {
                return response()->json([
                    'message' => 'You can only register up to 4 modules. If one module is marked absent, you may register another module.'
                ], 400);
            }

            $module = DB::table('modules')->where('id', $moduleId)->lockForUpdate()->first();

            if (!$module || ($module->capacity - $module->current_registration) <= 0) {
                return response()->json(['message' => 'Module full or not found!'], 400);
            }

            DB::table('bookings')->insert([
                'student_id' => $studentId,
                'module_id' => $moduleId,
                'is_claimed' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::table('modules')->where('id', $moduleId)->increment('current_registration', 1);

            return response()->json(['message' => 'Module added successfully!'], 200);
        });
    }

    /**
     * Individual Module Claim Logic
     */
    public function claimModule($id)
    {
        try {
            $totalRequired = 4;

            // Find the specific booking row entry
            $booking = DB::table('bookings')->where('id', $id)->first();

            if (!$booking) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Booking record row reference target not found.'
                ], 404);
            }

            $activeBookingCount = DB::table('bookings')
                ->where('bookings.student_id', $booking->student_id)
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('attendances')
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                        ->whereColumn('attendances.booking_id', 'bookings.id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->count();

            if ($activeBookingCount < $totalRequired) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Not eligible to claim. Insufficient module.',
                    'claimed_count' => DB::table('bookings')
                        ->where('student_id', $booking->student_id)
                        ->where('is_claimed', 1)
                        ->count(),
                    'total_required' => $totalRequired,
                ], 400);
            }

            // Update column flag to true (1)
            DB::table('bookings')
                ->where('id', $id)
                ->update([
                    'is_claimed' => 1,
                    'updated_at' => now()
                ]);

            $claimedCount = DB::table('bookings')
                ->where('student_id', $booking->student_id)
                ->where('is_claimed', 1)
                ->count();

            return response()->json([
                'status' => 'success',
                'message' => 'Module claimed successfully.',
                'claimed_count' => $claimedCount,
                'total_required' => $totalRequired,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Server script configuration fault: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Drop/Delete a booking
     */
    public function destroy($id)
    {
        // 1. Look up the booking row target
        $booking = DB::table('bookings')->where('id', $id)->first();

        if ($booking) {
            // 2. Decrement your module registration capacity counter
            DB::table('modules')->where('id', $booking->module_id)->decrement('current_registration', 1);

            // 3. Directly delete the target booking row out of MySQL
            DB::table('bookings')->where('id', $id)->delete();

            return response()->json(['message' => 'Successfully deleted'], 200);
        }

        return response()->json(['message' => 'Booking not found'], 404);
    }

    /**
     * View registered students for a module (Pusat ADAB Attendance List)
     */
    public function getRegisteredStudents($moduleId)
    {
        $registeredStudents = DB::table('bookings')
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

        return response()->json($registeredStudents); // Or return wrapped in ['data' => ...]
    }
}
