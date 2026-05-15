<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StudentSubjectController extends Controller
{
    /// GET ALL SUBJECTS
    public function getSubjects()
    {
        $subjects = Subject::with([

            'sections' => function ($query) {

                $query

                    ->withCount([

                        'registrations as registered_count' => function ($q) {

                            $q->where(
                                'status',
                                'active'
                            );
                        }
                    ])

                    ->with('labs');
            }

        ])

        ->where(
            'subject_status',
            'active'
        )

        ->get();

        return response()->json([

            'success' => true,

            'data' => $subjects
        ]);
    }

    /// GET REGISTERED SUBJECTS
    public function getRegisteredSubjects($student_id)
    {
        $registrations = DB::table('registration')

            ->join(
                'subjects',
                'registration.subject_id',
                '=',
                'subjects.subject_id'
            )

            ->join(
                'sections',
                'registration.section_id',
                '=',
                'sections.section_id'
            )

            ->select(

                'registration.registration_id',

                'subjects.subject_code',

                'subjects.subject_name',

                'subjects.credit_hours',

                'sections.section_no'
            )

            ->where(
                'registration.student_id',
                $student_id
            )

            ->where(
                'registration.status',
                'active'
            )

            ->get();

        return response()->json([

            'success' => true,

            'data' => $registrations
        ]);
    }

    /// REGISTER SUBJECT
    public function registerSubject(
        Request $request
    )
    {
        $exists = DB::table('registration')

            ->where(
                'student_id',
                $request->student_id
            )

            ->where(
                'subject_id',
                $request->subject_id
            )

            ->where(
                'status',
                'active'
            )

            ->exists();

        /// PREVENT DUPLICATE
        if ($exists) {

            return response()->json([

                'success' => false,

                'message' =>
                    'Subject already registered'
            ]);
        }

        /// INSERT
        DB::table('registration')

            ->insert([

                'student_id' =>
                    $request->student_id,

                'subject_id' =>
                    $request->subject_id,

                'section_id' =>
                    $request->section_id,

                'lab_id' =>
                    $request->lab_id,

                'status' => 'active',

                'registered_at' => now(),
            ]);

        return response()->json([

            'success' => true,

            'message' =>
                'Subject registered successfully'
        ]);
    }

    /// DROP SUBJECT
    public function dropSubject($registration_id)
    {
        DB::table('registration')

            ->where(
                'registration_id',
                $registration_id
            )

            ->update([

                'status' => 'dropped'
            ]);

        return response()->json([

            'success' => true,

            'message' =>
                'Subject dropped successfully'
        ]);
    }
}

