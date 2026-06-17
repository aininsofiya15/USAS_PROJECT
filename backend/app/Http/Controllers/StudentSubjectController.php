<?php

namespace App\Http\Controllers;

use App\Models\Subject;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StudentSubjectController extends Controller
{
    /**
     * ==========================================================
     * Retrieve all active subjects together with sections,
     * labs and current registered student count.
     * ==========================================================
     */
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

    /**
     * ==========================================================
     * Retrieve all active registered subjects for
     * selected student.
     * ==========================================================
     */
    public function getRegisteredSubjects($student_id)
    {
        // Sync approved curriculum claims before displaying
        $this->syncApprovedCreditClaims($student_id);

        $registrations = DB::table('registration')

            ->join(
                'subjects',
                'registration.subject_id',
                '=',
                'subjects.subject_id'
            )

            ->leftJoin(
                'sections',
                'registration.section_id',
                '=',
                'sections.section_id'
            )

            ->leftJoin(
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

    /**
     * ==========================================================
     * Automatically register approved curriculum
     * subjects into registration table.
     * ==========================================================
     */
    private function syncApprovedCreditClaims($studentId)
    {
        $approvedClaims = DB::table('credit_claims')
            ->where('student_id', $studentId)
            ->where('status', 'approved')
            ->get();

        foreach ($approvedClaims as $claim) {

            // Check if subject already registered
            $alreadyRegistered = DB::table('registration')
                ->where('student_id', $claim->student_id)
                ->where('subject_id', $claim->subject_id)
                ->where('status', 'active')
                ->exists();

            if ($alreadyRegistered) {
                continue;
            }

            // Get default section
            $section = DB::table('sections')
                ->where('subject_id', $claim->subject_id)
                ->first();

            // Auto insert registration
            DB::table('registration')->insert([
                'student_id'    => $claim->student_id,
                'subject_id'    => $claim->subject_id,
                'section_id'    => $section ? $section->section_id : null,
                'lab_id'        => null,
                'status'        => 'active',
                'registered_at' => now(),
            ]);
        }
    }

    /**
     * ==========================================================
     * Register student into selected subject and lab.
     * Includes validation:
     * - Duplicate registration
     * - Credit hour limit
     * - Schedule conflict
     * ==========================================================
     */
    public function registerSubject(Request $request)
    {
        /**
         * SDD Validation:
         * CHECK DUPLICATE REGISTRATION
         */
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

        if ($exists) {

            return response()->json([

                'success' => false,

                'message' =>
                    'Subject already registered'
            ]);
        }

        /**
         
         * CHECK CREDIT LIMIT */
        

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

        $newSubject = DB::table('subjects')

            ->where(
                'subject_id',
                $request->subject_id
            )

            ->first();

        // Maximum 20 credit hours
        if (($currentCredit + $newSubject->credit_hours) > 20) {

            return response()->json([

                'success' => false,

                'message' =>
                    'Maximum 20 credit hours exceeded'
            ], 400);
        }

        /**
         * SDD Validation:
         * CHECK SCHEDULE CONFLICT
         * Equivalent:
         * checkScheduleConflict(student_id, lab_id)
         */

        $newLab = DB::table('labs')

            ->where(
                'lab_id',
                $request->lab_id
            )

            ->first();

        $existingLabs = DB::table('registration')

            ->join(
                'labs',
                'registration.lab_id',
                '=',
                'labs.lab_id'
            )

            ->where(
                'registration.student_id',
                $request->student_id
            )

            ->where(
                'registration.status',
                'active'
            )

            ->select(

                'labs.schedule_day',

                'labs.schedule_time'
            )

            ->get();

        foreach ($existingLabs as $lab) {

            if (

                strtolower($lab->schedule_day) ==
                strtolower($newLab->schedule_day)

            ) {

                if (

                    strtolower($lab->schedule_time) ==
                    strtolower($newLab->schedule_time)

                ) {

                    return response()->json([

                        'success' => false,

                        'message' =>

                            'Schedule conflict detected'
                    ], 400);
                }
            }
        }

        /**
         
         * Insert into registration table
         */
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

        /**
         * UPDATE LAB ENROLLED COUNT
         */
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

    /**
     * ==========================================================
     * Remove registered subject and
     * release lab slot.
     * ==========================================================
     */
    public function dropSubject($registration_id)
    {
        $registration = DB::table('registration')

            ->where(
                'registration_id',
                $registration_id
            )

            ->first();

        /**
         * DECREASE LAB ENROLLED COUNT
         */
        DB::table('labs')

            ->where(
                'lab_id',
                $registration->lab_id
            )

            ->decrement('enrolled');

        /**
         * UPDATE REGISTRATION STATUS
         */
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