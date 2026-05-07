<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ModuleController extends Controller
{
    /**
     * Fetch all available co-curricular modules catalog
     */
    public function index()
    {
        try {
            $modules = DB::table('modules')->get();
            return response()->json(['data' => $modules], 200);
        } catch (\Exception $e) {
            Log::error("Fetch Modules Error: " . $e->getMessage());
            return response()->json(['error' => 'Failed to load modules'], 500);
        }
    }

    /**
     * Fetch all modules successfully booked by a specific student ID
     */
    public function getStudentBookings($studentId)
    {
        $bookings = DB::table('bookings')
            ->join('modules', 'bookings.module_id', '=', 'modules.id')
            ->where('bookings.student_id', $studentId)
            ->select(
                'bookings.id as id',          // 🔥 Use Column #1 from your screenshot!
                'modules.activity_name',
                'modules.date_time',
                'modules.venue',
                'bookings.attendance',
                'bookings.total_marks',
                'bookings.is_claimed'
            )
            ->get();

        return response()->json($bookings, 200);
    }

    /**
     * Safe Application Logic Handler (Deducts exactly 1 seat safely)
     */
    public function applyToModule(Request $request)
    {
        $request->validate([
            'module_id' => 'required|integer',
            'student_id' => 'required|integer',
        ]);

        $moduleId = $request->input('module_id');
        $studentId = $request->input('student_id');

        // 🔥 ATOMIC TRANSACTION BLOCK: Locks rows while running to stop the -5 duplicate bug!
        return DB::transaction(function () use ($moduleId, $studentId) {
            Log::info("Checking duplicate for Student: $studentId and Module: $moduleId");
            // 1. Check if this student already registered for this module row
            $alreadyBooked = DB::table('bookings')
                ->where('student_id', $studentId)
                ->where('module_id', $moduleId)
                ->exists();

            // 1. Check if this student already registered for ANY module with this same name
            $alreadyBooked = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $studentId)
                ->where('modules.activity_name', function($query) use ($moduleId) {
                    // This sub-query finds the name of the module the student is trying to join
                    $query->select('activity_name')
                        ->from('modules')
                        ->where('id', $moduleId);
                })
                ->exists();

            if ($alreadyBooked) {
                return response()->json(['message' => 'Already registered for this module!'], 400);
            }

            // 2. Fetch the target module details and lock the row during assessment
            $module = DB::table('modules')->where('id', $moduleId)->lockForUpdate()->first();

            if (!$module) {
                return response()->json(['message' => 'Module not found!'], 404);
            }

            // Calculate current remaining seats dynamically
            $availableSeats = $module->capacity - $module->current_registration;

            if ($availableSeats <= 0) {
                return response()->json(['message' => 'Slots are completely full!'], 400);
            }

            // 3. Create the enrollment entry record in your bookings table
            DB::table('bookings')->insert([
                'student_id' => $studentId,
                'module_id' => $moduleId,
                'attendance' => '-',
                'total_marks' => '-',
                'is_claimed' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // 4. FIXED: Atomic increment to add EXACTLY 1 to current_registration count column
            DB::table('modules')
                ->where('id', $moduleId)
                ->increment('current_registration', 1);

            
            return response()->json(['message' => 'Module added successfully!'], 200);
        });
    }

    public function destroy($id)
    {
        // Find the record using the ID from your screenshot
        $booking = DB::table('bookings')->where('id', $id)->first();

        if ($booking) {
            // Use the module_id (Column #3 in your screenshot) to free a seat
            DB::table('modules')
                ->where('id', $booking->module_id)
                ->decrement('current_registration', 1);

            // Delete the row from the bookings table
            DB::table('bookings')->where('id', $id)->delete();

            return response()->json(['message' => 'Successfully deleted'], 200);
        }

        return response()->json(['message' => 'Booking ID not found'], 404);
    }
}