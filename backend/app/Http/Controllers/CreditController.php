<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\AttendanceRecord;
use App\Models\CreditClaim;

class CreditController extends Controller
{
    public function submitFinalCredit(Request $request)
    {
        // 1. Only require the student ID from the Flutter app
        $request->validate([
            'student_id' => 'required|integer',
        ]);

        $studentId = $request->input('student_id');

        // 2. AUTOMATIC LOOKUP: Find your Co-Curriculum subject row automatically
        $subject = DB::table('subjects')
            ->where('subject_code', 'UQA2002')
            ->first();

        // Safe fallback in case the database seeder hasn't run yet
        if (!$subject) {
            return response()->json(['message' => 'UQA2002 Co-Curriculum subject row not found in database.'], 404);
        }

        // 3. STRICT ONE-TIME CONSTRAINT: Check if they already submitted an application
        $existingClaim = DB::table('credit_claims')
            ->where('student_id', $studentId)
            ->where('subject_id', $subject->subject_id)
            ->first();

        if ($existingClaim) {
            return response()->json([
                'message' => 'You have already submitted a claim for this credit hour.',
                'status' => $existingClaim->status
            ], 409); // Blocks duplicate records immediately
        }

        // 4. THE TRANSACTION: Create the pending row entry in MySQL
        DB::table('credit_claims')->insert([
            'student_id' => $studentId,
            'subject_id' => $subject->subject_id,
            'status'     => 'pending', // Starts as pending for your Status View Page to read
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Credit claim submitted successfully!'], 201);
    }

    public function checkCreditStatus($studentId)
    {
        // Query the claim row and join the subject metrics cleanly
        $claim = DB::table('credit_claims')
            ->join('subjects', 'credit_claims.subject_id', '=', 'subjects.subject_id')
            ->where('credit_claims.student_id', $studentId)
            ->select('subjects.subject_code', 'subjects.subject_name', 'credit_claims.status')
            ->first();

        if ($claim) {
            return response()->json([
                'status' => 'exists',
                'data' => [
                    'subject_code' => $claim->subject_code,
                    'subject_name' => $claim->subject_name,
                    'status'       => $claim->status, // 'pending' or 'approved'
                ]
            ], 200);
        }

        return response()->json([
            'status' => 'none',
            'data' => null
        ], 200);
    }

    /**
     * 📋 GET ALL CLAIMS FOR PUSAT ADAB
     */
public function getAllClaims(Request $request)
    {
        $filter = $request->query('filter', 'all');

        // 1. Fetch primary claims by linking users and matching student records
        $query = DB::table('credit_claims')
            ->join('users', 'credit_claims.student_id', '=', 'users.id')
            // 🎯 MAP FIX: Joins the user account ID directly to the student profile record ID
            ->leftJoin('students', 'users.id', '=', 'students.id') 
            ->select(
                'credit_claims.id as claim_id',
                'credit_claims.student_id',
                'users.name as student_name',
                // 🎯 Maps the true alphanumeric string column from image_87b783.png
                DB::raw('COALESCE(students.student_id, users.id) as matric_id'), 
                'credit_claims.status as claim_status'
            );

        if ($filter === 'pending') {
            $query->where('credit_claims.status', 'pending');
        }

        $claims = $query->get();

        // 2. Attach the completed modules dynamically for each student card row
        foreach ($claims as $claim) {
            // 🎯 FIX: Added a strict condition to only pull modules tied directly to this claim activation
            $completedModules = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $claim->student_id)
                ->where('bookings.is_claimed', 1) // 🌟 Only fetch modules explicitly tagged for the claim!
                ->pluck('modules.activity_name');

            $claim->completed_modules = $completedModules;
        }

        return response()->json([
            'status' => 'success',
            'count' => $claims->count(),
            'data' => $claims
        ], 200);
    }

    /**
     * ✅ APPROVE CREDIT CLAIM
     */
   
    public function approveClaim($id)
    {
        // 1. Verify that the claim record exists
        $claim = DB::table('credit_claims')->where('id', $id)->first();

        if (!$claim) {
            return response()->json(['message' => 'Claim record not found.'], 404);
        }

        // 2. Run operations inside a secure database transaction
        DB::transaction(function () use ($claim, $id) {
            
            // A. Update the credit claim status to approved
            if ($claim->status !== 'approved') {
                DB::table('credit_claims')
                    ->where('id', $id)
                    ->update([
                        'status' => 'approved',
                        'updated_at' => now()
                    ]);
            }

            // B. Find a matching section for this subject. Koko subjects may not have labs.
            $section = DB::table('sections')
                ->where('subject_id', $claim->subject_id)
                ->first();
                
            $sectionId = $section ? $section->section_id : null;

            $alreadyRegistered = DB::table('registration')
                ->where('student_id', $claim->student_id)
                ->where('subject_id', $claim->subject_id)
                ->where('status', 'active')
                ->exists();

            // C. Insert row into registration table without a lab for co-curriculum subject.
            if (!$alreadyRegistered) {
                DB::table('registration')->insert([
                    'student_id'    => $claim->student_id,
                    'subject_id'    => $claim->subject_id,
                    'section_id'    => $sectionId,
                    'lab_id'        => null,
                    'status'        => 'active',
                    'registered_at' => now(),
                ]);
            }
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Application approved and student auto-registered into the course successfully.'
        ], 200);
    }
}
