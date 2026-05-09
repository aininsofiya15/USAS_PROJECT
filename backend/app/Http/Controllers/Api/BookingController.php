<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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
        $bookings = DB::table('bookings')
            ->join('modules', 'bookings.module_id', '=', 'modules.id')
            // Join attendance_records to get live marks and status
            ->leftJoin('attendance_records', function($join) {
                $join->on('bookings.student_id', '=', 'attendance_records.student_id');
            })
            ->where('bookings.student_id', $studentId)
            ->select(
                'bookings.id as id',
                'modules.activity_name',
                'modules.date_time',
                'modules.venue',
                'attendance_records.status as attendance_status', // From attendance table
                'attendance_records.marks',              // From attendance table
                'bookings.is_claimed'
            )
            ->get();

        return response()->json($bookings, 200);
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
                ->exists();

            if ($alreadyBooked) {
                return response()->json(['message' => 'Already registered for this module type!'], 400);
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
    public function claimModule(Request $request)
    {
        $bookingId = $request->input('booking_id');

        DB::table('bookings')
            ->where('id', $bookingId)
            ->update([
                'is_claimed' => 1,
                'updated_at' => now()
            ]);

        return response()->json(['message' => 'Module claimed successfully!']);
    }

    /**
     * Check if student has 4/4 modules for Credit Claim
     */
    public function checkCreditEligibility($studentId)
    {
        $count = DB::table('bookings')
            ->where('student_id', $studentId)
            ->where('is_claimed', 1)
            ->count();

        return response()->json([
            'claimed_count' => $count,
            'is_eligible' => $count >= 4
        ]);
    }

    /**
     * Drop/Delete a booking
     */
    public function destroy($id)
    {
        $booking = DB::table('bookings')->where('id', $id)->first();

        if ($booking) {
            DB::table('modules')->where('id', $booking->module_id)->decrement('current_registration', 1);
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
        $students = DB::table('bookings')
            ->join('students', 'bookings.student_id', '=', 'students.id') 
            ->join('users', 'students.id', '=', 'users.id') 
            ->where('bookings.module_id', $moduleId)
            ->select(
                'bookings.id as booking_id', 
                'users.name as student_name',
                'students.student_id as matric_id'
            )
            ->get();

        return response()->json($students);
    }
}