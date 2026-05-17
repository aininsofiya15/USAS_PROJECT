<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\Subject;
use App\Models\Section;
use App\Models\Lab;
use App\Models\User;

class RegistrarSubjectController extends Controller
{

    public function registerSubject(Request $request)
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

        foreach ($request->sections as $sectionData) {

            $section = Section::create([

                'subject_id' =>
                    $subject->subject_id,

                'lecturer_id' =>
                    $sectionData['lecturer_id'],

                'section_no' =>
                    $sectionData['section_name'],

                'capacity' => 0,
            ]);

            foreach ($sectionData['labs'] as $labData) {

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
        $subjects = Subject::all();

        foreach ($subjects as $subject) {

            $totalLab = DB::table('labs')

                ->join(
                    'sections',
                    'labs.section_id',
                    '=',
                    'sections.section_id'
                )

                ->where(
                    'sections.subject_id',
                    $subject->subject_id
                )

                ->count();

            $subject->total_lab = $totalLab;
        }

        return response()->json($subjects);
    }

    public function getLecturers()
    {

        return User::where(
            'role',
            'lecturer'
        )->get();
    }

    public function getSubjectDetails($id)
    {

        $subject = DB::table('subjects')

            ->where('subject_id', $id)

            ->first();

        $sections = DB::table('sections')

            ->where('subject_id', $id)

            ->get();

        foreach ($sections as $section) {

            $labs = DB::table('labs')

                ->where(
                    'section_id',
                    $section->section_id
                )

                ->get();

            foreach ($labs as $lab) {

                $registrations = DB::table('registration')

                    ->join(
                        'users',
                        'registration.student_id',
                        '=',
                        'users.id'
                    )

                    ->where(
                        'registration.lab_id',
                        $lab->lab_id
                    )

                    ->select(
                        'users.id',
                        'users.name',
                        'users.email',
                        'registration.status'
                    )

                    ->get();

                $lab->registrations = $registrations;

                $lab->total_students =
                    $registrations->count();

                $lab->available =
                    $lab->capacity -
                    $lab->total_students;
            }

            $section->labs = $labs;
        }

        return response()->json([

            'subject' => $subject,

            'sections' => $sections,
        ]);
    }
}