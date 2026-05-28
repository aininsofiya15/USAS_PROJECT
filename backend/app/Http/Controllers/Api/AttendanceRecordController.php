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
    
//AININ

    // 1. Fetch the list of published modules for the Pusat Adab attendance selection page.
    public function fetchPusatAdabModules()
    {
        $modules = Module::where('status', 'published')
            ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'status')
            ->get();
        
        return response()->json(['data' => $modules], 200);
    }

    //2. Fetch module details and the list of students who submitted attendance.
    public function getPresentStudents($moduleId)
    {
        try {
            // 1. Fetch the master module header info using its 'id' column
            $moduleInfo = DB::table('modules')
                ->where('id', $moduleId)
                ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'capacity', 'current_registration')
                ->first();

            if (!$moduleInfo) {
                return response()->json(['message' => 'Module session not found'], 404);
            }

            // 2. Query matching your EXACT database column structures
            $students = DB::table('module_attendances')
                ->join('bookings', 'module_attendances.booking_id', '=', 'bookings.id')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->join('attendances', 'bookings.id', '=', 'attendances.booking_id') 
                ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                
                // FIX: Changed from students.student_id to students.id to match the numeric integer values!
                ->join('students', 'attendance_records.student_id', '=', 'students.id')
                ->join('users', 'students.id', '=', 'users.id')
                
                // Filter down to this specific module session
                ->where('modules.id', $moduleId)
                
                // Select fields mapped perfectly to your Flutter string keys
                ->select(
                    'users.name as student_name',
                    'students.student_id as matrix_no', // This returns CA24000 as "matrix_no" for Flutter text fields
                    'attendance_records.status as attendance_status',
                    'attendance_records.created_at as check_in_time'
                )
                ->get();

            // 3. Package it together with the 'data' key wrapper for Flutter
            return response()->json([
                'data' => [
                    'module' => $moduleInfo,
                    'students' => $students
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => 'Database query failed: ' . $e->getMessage()], 500);
        }
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