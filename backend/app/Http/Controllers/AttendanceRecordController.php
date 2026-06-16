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
        // Retrieve modules with published status
        $modules = Module::where('status', 'published')
            // Select module attributes to display
            ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'status')
            ->get();
        
        // Return JSON payload response
        return response()->json(['data' => $modules], 200);
    }

    // 2. Fetch student attendance list for a specific module
    public function getPresentStudents($moduleId)
    {
        try {
            // Retrieve module details by module ID
            $moduleInfo = DB::table('modules')
            // Filter by module ID and select moduleattributes 
                ->where('id', $moduleId)
                ->select('id', 'activity_name', 'date_time', 'venue', 'lecturer_name', 'capacity', 'current_registration')
                ->first();

            // Message when module ID does not exist in database
            if (!$moduleInfo) {
                return response()->json(['message' => 'Module session not found'], 404);
            }

            // Query database relations to compile attendance records
            $students = DB::table('module_attendances')
                ->join('bookings', 'module_attendances.booking_id', '=', 'bookings.id')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->join('attendances', 'bookings.id', '=', 'attendances.booking_id') 
                ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                ->join('students', 'attendance_records.student_id', '=', 'students.id')
                ->join('users', 'students.id', '=', 'users.id')
                // Filter records by choosen module ID
                ->where('modules.id', $moduleId)
                // Select attributes for the attendance record
                ->select(
                    'attendance_records.id as id', 
                    'users.name as student_name',
                    'students.student_id as matrix_no', 
                    'attendance_records.status as attendance_status',
                    'attendance_records.created_at as check_in_time',
                    'attendance_records.marks as marks',           
                    'attendance_records.grade_category as grade_category' 
                )
                ->get();

            // Return JSON payload response with module info and student attendance records
            return response()->json([
                'data' => [
                    'module' => $moduleInfo,
                    'students' => $students
                ]
            ], 200);
        // Catch exceptions that occur during database query execution 
        } catch (\Exception $e) {
            // Return an error response
            return response()->json(['error' => 'Database query failed: ' . $e->getMessage()], 500);
        }
    }
    
    // 3. Update student module marks
    public function updateStudentGrade(Request $request, $recordId)
    {
        try {
            // Validate the entered marks format
            $request->validate([
                'marks' => 'required|numeric|min:0|max:100',
            ]);
            // Retrieve the marks input and determine the grade category
            $marks = $request->input('marks');
            $gradeCategory = 'Fail';

            // Determine grade category based on marks entered
            if ($marks >= 80) {
                $gradeCategory = 'Excellent';
            } elseif ($marks >= 60) {
                $gradeCategory = 'Satisfactory';
            } elseif ($marks >= 40) {
                $gradeCategory = 'Pass';
            }

            // Check if the attendance record line item exists for the provided record ID
            $record = DB::table('attendance_records')->where('id', $recordId)->first();
            
            if (!$record) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Targeted attendance record line item not found.'
                ], 404);
            }

            // Execute database columns update execution statement
            DB::table('attendance_records')
                ->where('id', $recordId)
                ->update([
                    'marks' => $marks,                  
                    'grade_category' => $gradeCategory, 
                    'updated_at' => now(),
                ]);

            // Return success configuration status array data
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
            // Handle validation error exceptions
            return response()->json([
                'status' => 'validation_error',
                'error' => $ve->errors()->first()
            ], 422);
        } catch (\Exception $e) {
            // Handle execution fallback error exceptions
            return response()->json([
                'status' => 'error',
                'error' => 'Database grading transaction failed: ' . $e->getMessage()
            ], 500);
        }
    }
}