<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Subject;

class AttendanceController extends Controller
{
    public function getLecturerSubjects(Request $request)
    {
        // Use 'lecturer_id' instead of 'user_id' to match your migration
        $lecturerId = $request->query('user_id'); 

        if (!$lecturerId) {
            return response()->json(['success' => false, 'message' => 'Lecturer ID is required'], 400);
        }

        $subjects = Subject::whereHas('sections', function ($query) use ($lecturerId) {
            // Updated to 'sections.lecturer_id'
            $query->where('sections.lecturer_id', $lecturerId); 
        })
        ->with(['sections' => function ($query) use ($lecturerId) {
            // Updated to 'sections.lecturer_id' and added the foreign key to the select
            $query->where('sections.lecturer_id', $lecturerId)
                ->select('section_id', 'subject_id', 'lecturer_id', 'section_no');
        }])
        ->select('subject_id', 'subject_code', 'subject_name')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $subjects
        ], 200);
    }
}