<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Module;
use Illuminate\Validation\ValidationException;

class AttendanceRecordController extends Controller
{
    // 1. Fetch published modules 
    public function fetchPusatAdabModules()
    {
        $modules = Module::where('status', 'published')
            ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'status')
            ->get();
        
        return response()->json(['data' => $modules], 200);
    }

    // 2. Fetch student attendance list for a specific module
    public function getPresentStudents($moduleId)
    {
        try {
            $moduleInfo = DB::table('modules')->where('id', $moduleId)->first();
            if (!$moduleInfo) {
                return response()->json(['message' => 'Module session not found'], 404);
            }

            // 🎯 DIRECT SHORTCUT QUERY: Bypasses deep booking string comparisons
            // It grabs attendance records directly via the module bridge links
            $students = DB::table('attendance_records')
                ->join('attendances', 'attendance_records.attendance_id', '=', 'attendances.id')
                ->join('module_attendances', 'attendances.id', '=', 'module_attendances.attendance_id')
                ->join('users', 'attendance_records.student_id', '=', 'users.id')
                ->leftJoin('students', 'users.id', '=', 'students.id') // Left join prevents crash if profile row is missing
                ->where('module_attendances.module_id', $moduleId)
                ->select(
                    'attendance_records.id as id', 
                    'users.name as student_name',
                    DB::raw('COALESCE(students.student_id, "No Matric") as matrix_no'), 
                    'attendance_records.status as attendance_status',
                    'attendance_records.created_at as check_in_time',
                    'attendance_records.marks as marks',           
                    'attendance_records.grade_category as grade_category' 
                )
                ->get();

            return response()->json([
                'data' => [
                    'module' => $moduleInfo,
                    'students' => $students
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => 'Database bypass query failed: ' . $e->getMessage()], 500);
        }
    }
    
    // 3. Update student module marks
    public function updateStudentGrade(Request $request, $recordId)
    {
        try {
            $request->validate([
                'marks' => 'required|numeric|min:0|max:100',
            ]);

            $marks = $request->input('marks');
            $gradeCategory = 'Fail';

            if ($marks >= 80) {
                $gradeCategory = 'Excellent';
            } elseif ($marks >= 60) {
                $gradeCategory = 'Satisfactory';
            } elseif ($marks >= 40) {
                $gradeCategory = 'Pass';
            }

            $record = DB::table('attendance_records')->where('id', $recordId)->first();
            
            if (!$record) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Targeted attendance record line item not found.'
                ], 404);
            }

            DB::table('attendance_records')
                ->where('id', $recordId)
                ->update([
                    'marks' => $marks,                                  
                    'grade_category' => $gradeCategory, 
                    'updated_at' => now(),
                ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Student records graded successfully!',
                'data' => [
                    'record_id' => (int)$recordId,
                    'student_id' => $record->student_id, // This passes the clean User ID integer back
                    'marks' => $marks,
                    'grade_category' => $gradeCategory
                ]
            ], 200);

        } catch (ValidationException $ve) {
            return response()->json([
                'status' => 'validation_error',
                'error' => $ve->validator->errors()->first()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'error' => 'Database grading transaction failed: ' . $e->getMessage()
            ], 500);
        }
    }
}