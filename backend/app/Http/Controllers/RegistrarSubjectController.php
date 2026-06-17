<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\Subject;
use App\Models\Section;
use App\Models\Lab;
use App\Models\User;

class RegistrarSubjectController extends Controller
{

    // Purpose: Create a new subject with sections and labs
    public function registerSubject(Request $request)
    {
        // Purpose: Start database transaction
        DB::beginTransaction();

        try {

            // Purpose: Create subject record
            $subject = Subject::create([

                'subject_name' => $request->subject_name,
                'subject_code' => $request->subject_code,
                'credit_hours' => $request->credit_hours,
                'total_section' => $request->total_section,
                'total_lab' => 0,
                'subject_status' => 'active',
            ]);

            // Purpose: Track total number of labs
            $totalLab = 0;

            // Purpose: Create sections for subject
            foreach ($request->sections as $sectionData) {

                $section = Section::create([

                    'subject_id' => $subject->subject_id,

                    'lecturer_id' => $sectionData['lecturer_id'],

                    'section_no' => $sectionData['section_name'],
                ]);

                // Purpose: Create labs for section
                foreach ($sectionData['labs'] as $labData) {

                    Lab::create([

                        'section_id' => $section->section_id,

                        'lab_name' => $labData['lab_name'],

                        'capacity' => $labData['capacity'],

                        'schedule_day' => $labData['schedule_day'],

                        'schedule_time' => $labData['schedule_time'],
                    ]);

                    // Purpose: Count total labs
                    $totalLab++;
                }
            }

            // Purpose: Update total lab count
            $subject->update([
                'total_lab' => $totalLab
            ]);

            // Purpose: Save all changes
            DB::commit();

            // Purpose: Return successful response
            return response()->json([

                'success' => true,
                'message' => 'Subject Registered Successfully',
            ]);

        } catch (\Exception $e) {

            // Purpose: Undo all changes if error occurs
            DB::rollBack();

            // Purpose: Return error response
            return response()->json([

                'success' => false,
                'error' => $e->getMessage(),
                'line' => $e->getLine(),
                'file' => $e->getFile(),
            ], 500);
        }
    }

    // Purpose: Retrieve all subjects
    public function getSubjects()
    {
        $subjects = Subject::all();

        foreach ($subjects as $subject) {

            // Purpose: Calculate total labs for subject
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

            // Purpose: Assign total lab count
            $subject->total_lab = $totalLab;
        }

        // Purpose: Return subject list
        return response()->json($subjects);
    }

    // Purpose: Retrieve lecturer list
    public function getLecturers()
    {
        return User::where(
            'role',
            'lecturer'
        )->get();
    }

    // Purpose: Retrieve subject details with sections, labs and registrations
    public function getSubjectDetails($id)
    {

        // Purpose: Retrieve subject information
        $subject = DB::table('subjects')

            ->where('subject_id', $id)

            ->first();

        // Purpose: Retrieve subject sections
        $sections = DB::table('sections')

            ->where('subject_id', $id)

            ->get();

        foreach ($sections as $section) {

            // Purpose: Retrieve labs for section
            $labs = DB::table('labs')

                ->where(
                    'section_id',
                    $section->section_id
                )

                ->get();

            foreach ($labs as $lab) {

                // Purpose: Retrieve registered students
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

                    ->where(
                        'registration.status',
                        'active'
                    )

                    ->select(
                        'users.id',
                        'users.name',
                        'users.email',
                        'registration.status'
                    )

                    ->distinct()

                    ->get();

                // Purpose: Attach registration list to lab
                $lab->registrations = $registrations;

                // Purpose: Calculate total registered students
                $lab->total_students =
                    $registrations->count();

                // Purpose: Calculate available lab slots
                $lab->available =
                    $lab->capacity -
                    $lab->total_students;
            }

            // Purpose: Attach labs to section
            $section->labs = $labs;
        }

        // Purpose: Return complete subject details
        return response()->json([

            'subject' => $subject,

            'sections' => $sections,
        ]);
    }
}