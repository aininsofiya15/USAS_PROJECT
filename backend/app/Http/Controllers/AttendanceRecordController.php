<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\AttendanceRecord; 
use App\Models\Module;
use App\Models\ModuleAttendance;
use Illuminate\Validation\ValidationException;

class AttendanceRecordController extends Controller
{
    // AININ

    // 1. Fetch the list of published modules for the Pusat Adab attendance selection page.
    public function fetchPusatAdabModules()
    {
        $modules = Module::where('status', 'published')
            ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'status')
            ->get();
        
        return response()->json(['data' => $modules], 200);
    }

    // 2. Fetch module details and the list of students who submitted attendance.
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
                
                // Joined matching the numeric integer values
                ->join('students', 'attendance_records.student_id', '=', 'students.id')
                ->join('users', 'students.id', '=', 'users.id')
                
                // Filter down to this specific module session
                ->where('modules.id', $moduleId)
                
                ->select(
                    'attendance_records.id as id', 
                    'users.name as student_name',
                    'students.student_id as matrix_no', 
                    'attendance_records.status as attendance_status',
                    'attendance_records.created_at as check_in_time',
                    'attendance_records.marks as marks',           // ◄ ADD THIS COLUMN
                    'attendance_records.grade_category as grade_category' // ◄ ADD THIS COLUMN
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
     * Updates student marks and evaluation grade category.
     * TARGET MODULE: PUSAT ADAB MODULE GRADING
     */
    public function updateStudentGrade(Request $request, $recordId)
    {
        try {
            // 1. Strictly validate incoming score numeric boundaries
            $request->validate([
                'marks' => 'required|numeric|min:0|max:100',
            ]);

            $marks = $request->input('marks');
            $gradeCategory = 'Fail';

            // 2. Classify grade benchmarks text dynamically based on the percentage score
            if ($marks >= 80) {
                $gradeCategory = 'Excellent';
            } elseif ($marks >= 60) {
                $gradeCategory = 'Satisfactory';
            } elseif ($marks >= 40) {
                $gradeCategory = 'Pass';
            }

            // 3. Verify the targeted attendance record entry actually exists in the background
            $record = DB::table('attendance_records')->where('id', $recordId)->first();
            
            if (!$record) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Targeted attendance record line item not found.'
                ], 404);
            }

            // 4. Update your live columns matching your phpMyAdmin schema panel perfectly
            DB::table('attendance_records')
                ->where('id', $recordId)
                ->update([
                    'marks' => $marks,                  
                    'grade_category' => $gradeCategory, 
                    'updated_at' => now(),
                ]);

            // 5. Return clean confirmation back to your Flutter app layout
            return response()->json([
                'status' => 'success',
                'message' => 'Student records graded successfully!',
                'data' => [
                    'record_id' => (int)$recordId,
                    'student_id' => $record->student_id,
                    'marks' => $marks,
                    'grade_category' => $gradeCategory
                ]
            ], 200);

        } catch (ValidationException $ve) {
            return response()->json([
                'status' => 'validation_error',
                'error' => $ve->errors()->first()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'error' => 'Database grading transaction failed: ' . $e->getMessage()
            ], 500);
        }
    }
}
