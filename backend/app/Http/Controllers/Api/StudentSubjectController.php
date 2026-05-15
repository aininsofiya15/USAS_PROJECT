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

            ->join(
                'labs',
                'registration.lab_id',
                '=',
                'labs.lab_id'
            )

            ->select(

                'registration.registration_id',

                'subjects.subject_code',

                'subjects.subject_name',

                'subjects.credit_hours',

                'labs.lab_name',

                'labs.schedule_day',

                'labs.schedule_time'
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

        /// CHECK TOTAL CREDIT HOUR
$currentCredit = DB::table('registration')

    ->join(
        'subjects',
        'registration.subject_id',
        '=',
        'subjects.subject_id'
    )

    ->where(
        'registration.student_id',
        $request->student_id
    )

    ->where(
        'registration.status',
        'active'
    )

    ->sum('subjects.credit_hours');


/// GET NEW SUBJECT CREDIT
$newSubject = DB::table('subjects')

    ->where(
        'subject_id',
        $request->subject_id
    )

    ->first();


/// LIMIT 20 CREDIT
if (($currentCredit + $newSubject->credit_hours) > 20) {

    return response()->json([

        'success' => false,

        'message' =>
            'Maximum 20 credit hours exceeded'
    ], 400);
}

        /// INSERT REGISTRATION
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

        /// INCREASE LAB ENROLLED
        DB::table('labs')

            ->where(
                'lab_id',
                $request->lab_id
            )

            ->increment('enrolled');

        return response()->json([

            'success' => true,

            'message' =>
                'Subject registered successfully'
        ]);
    }

    /// DROP SUBJECT
    public function dropSubject($registration_id)
    {
        $registration = DB::table('registration')

            ->where(
                'registration_id',
                $registration_id
            )

            ->first();

        /// DECREASE LAB ENROLLED
        DB::table('labs')

            ->where(
                'lab_id',
                $registration->lab_id
            )

            ->decrement('enrolled');

        /// UPDATE STATUS
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