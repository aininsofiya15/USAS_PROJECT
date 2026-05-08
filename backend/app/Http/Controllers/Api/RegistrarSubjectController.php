<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Subject;
use App\Models\Section;
use App\Models\Lab;

class RegistrarSubjectController extends Controller
{
    public function registerSubject(Request $request)
{

    $subject = Subject::create([

        'subject_name' => $request->subject_name,
        'subject_code' => $request->subject_code,
        'credit_hours' => $request->credit_hours,
        'total_section' => $request->total_section,

    ]);

    foreach ($request->sections as $sectionData) {

        $section = Section::create([

            'subject_id' => $subject->subject_id,

            'section_no' =>
                $sectionData['section_name'],

            'capacity' =>
                $sectionData['capacity'],

        ]);

        for ($i = 1; $i <= $sectionData['total_labs']; $i++) {

            Lab::create([

                'section_id' => $section->section_id,

                'lab_name' =>
                    $sectionData['section_name'] .
                    chr(64 + $i),

                'capacity' =>
                    $sectionData['capacity'],

            ]);
        }
    }

    return response()->json([

        'message' =>
            'Subject Registered Successfully',

    ]);
}
}