<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Subject;

class RegistrarSubjectController extends Controller
{
    public function registerSubject(Request $request)
    {

        $subject = Subject::create([

            'subject_name' => $request->subject_name,
            'subject_code' => $request->subject_code,
            'credit_hours' => $request->credit_hours,
            'total_section' => $request->total_section,
            'total_lab' => $request->total_lab,

        ]);

        return response()->json([

            'message' => 'Subject Registered Successfully',
            'data' => $subject

        ]);
    }

    public function getSubjects()
    {
        $subjects = Subject::all();

        return response()->json($subjects);
    }

}