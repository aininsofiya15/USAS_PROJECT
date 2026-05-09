<?php

namespace App\Http\Controllers\Api; // This MUST match the folder structure

use App\Http\Controllers\Controller; // Required because it's in a subfolder
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Module;

class AttendanceRecordController extends Controller
{
    /**
     * Fetch published modules for the selection list.
     */
    public function fetchPusatAdabModules()
    {
        $modules = Module::where('status', 'published')
            ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'status')
            ->get();
        
        return response()->json($modules);
    }

    /**
     * Fetch students specifically for a Pusat ADAB module.
     * Note: Changed $moduleId to $bookingId to match your Bridge Table.
     */
    public function getPresentStudents($bookingId) 
    {
        // We must first find the correct session ID from your module_attendances bridge
        $records = DB::table('attendance_records')
            ->join('students', 'attendance_records.student_id', '=', 'students.student_id')
            ->join('module_attendances', 'attendance_records.attendance_id', '=', 'module_attendances.attendance_id')
            ->where('module_attendances.booking_id', $bookingId)
            ->select(
                'students.student_id', 
                'students.name as studentName', // Added for your Flutter UI
                'students.faculty', 
                'attendance_records.status',
                'attendance_records.marks', 
                'attendance_records.id'
            )
            ->get();

        return response()->json([
            'records' => $records
        ]);
    }
}