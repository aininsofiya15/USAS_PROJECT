<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

use Illuminate\Http\Request;

use App\Models\Subject;
use App\Models\Section;
use App\Models\Lab;
use App\Models\User;

class RegistrarSubjectController
    extends Controller
{

    public function registerSubject(
        Request $request)
    {

        $subject = Subject::create([

            'subject_name' =>
                $request->subject_name,

            'subject_code' =>
                $request->subject_code,

            'credit_hours' =>
                $request->credit_hours,

            'total_section' =>
                $request->total_section,

            'total_lab' => 0,

            'subject_status' => 'active',
        ]);

        foreach ($request->sections
            as $sectionData) {

            $section = Section::create([

                'subject_id' =>
                    $subject->subject_id,

                'lecturer_id' =>
                    $sectionData['lecturer_id'],

                'section_no' =>
                    $sectionData['section_name'],

                'capacity' => 0,
            ]);

            foreach ($sectionData['labs']
                as $labData) {

                Lab::create([

                    'section_id' =>
                        $section->section_id,

                    'lab_name' =>
                        $labData['lab_name'],

                    'capacity' =>
                        $labData['capacity'],

                    'schedule_day' =>
                        $labData['schedule_day'],

                    'schedule_time' =>
                        $labData['schedule_time'],
                ]);
            }
        }

        return response()->json([

            'message' =>
                'Subject Registered Successfully',
        ]);
    }

    public function getSubjects()
    {
        return Subject::all();
    }

    public function getLecturers()
    {

        return User::where(
            'role',
            'lecturer'
        )->get();
    }
}