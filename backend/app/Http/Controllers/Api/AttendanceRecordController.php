<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\AttendanceRecord; // Ensure models are imported
use App\Models\Module;
use App\Models\ModuleAttendance;

class AttendanceRecordController extends Controller
{
    /**
     * 1. Fetch published modules catalog for the selection list.
     */
    public function fetchPusatAdabModules()
    {
        $modules = Module::where('status', 'published')
            ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'status')
            ->get();
        
        return response()->json($modules);
    }

    /**
     * 2. Fetch students for a specific module session.
     * Matches Route: /attendance/details/{bookingId}
     */
    public function getPresentStudents($bookingId) 
    {
        // Find the bridge record linked to the specific module booking
        $moduleSession = ModuleAttendance::where('booking_id', $bookingId)
            ->with(['attendance', 'booking.module'])
            ->first();

        if (!$moduleSession) {
            return response()->json(['message' => 'No session found'], 404);
        }

        // Fetch students and their names/matric IDs from joined tables
        $records = DB::table('attendance_records')
            ->join('students', 'attendance_records.student_id', '=', 'students.student_id')
            ->join('users', 'students.id', '=', 'users.id') // To get names from users table
            ->where('attendance_records.attendance_id', $moduleSession->attendance_id)
            ->select(
                'attendance_records.id',
                'students.student_id', 
                'users.name as student_name', 
                'attendance_records.status',
                'attendance_records.marks',
                'attendance_records.grade_category'
            )
            ->get();

        return response()->json([
            'header' => [
                'activity_name' => $moduleSession->booking->module->activity_name,
                'venue' => $moduleSession->booking->module->venue,
            ],
            'records' => $records
        ]);
    }

    /**
     * 3. Update a student's grade from the Flutter "Grade" button.
     * Matches Route: /attendance/update-grade
     */
    public function updateStudentGrade(Request $request)
    {
        $request->validate([
            'record_id' => 'required|integer',
            'marks' => 'required|numeric|min:0|max:100',
        ]);

        $record = AttendanceRecord::find($request->record_id);
        
        if (!$record) {
            return response()->json(['message' => 'Record not found'], 404);
        }

        $record->update([
            'marks' => $request->marks,
            'grade_category' => $request->marks >= 50 ? 'Pass' : 'Fail', 
        ]);

        return response()->json([
            'message' => 'Grade updated successfully',
            'record' => $record
        ]);
    }
}