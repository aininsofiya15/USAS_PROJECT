<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AttendanceRecord;
use App\Models\Attendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Booking;

class AttendanceRecordController extends Controller
{

    /**
     * GET /api/attendance-sessions
     * Fetches the list of modules for the Selection Page
     */
    public function fetchPusatAdabModules()
    {
        // Fetch only modules where status is 'published'
        // Based on image_19f63e.png column names
        $modules = \App\Models\Module::where('status', 'published')->get();
        
        return response()->json($modules);
    }

    public function getPresentStudents($moduleId) {
    // 1. Query the records table
    // 2. Join with students to get names and faculty info
    return DB::table('attendance_records')
        ->join('students', 'attendance_records.student_id', '=', 'students.student_id')
        ->where('attendance_records.attendance_id', $moduleId)
        ->where('attendance_records.status', 'present')
        ->select(
            'students.student_id', 
            'students.faculty', 
            'attendance_records.marks', 
            'attendance_records.id as record_id'
        )
        ->get();
}

}