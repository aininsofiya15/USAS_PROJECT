<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CreditController extends Controller
{
    // 1. Student submit final credit claim 
    public function submitFinalCredit(Request $request)
    {
        // Validate student id 
        $request->validate([
            'student_id' => 'required|string', // Validates incoming ID payload string safely
        ]);

        $studentId = $request->input('student_id');

        // Retrieve subject row for Co-Curriculum
        $subject = DB::table('subjects')
            ->where('subject_code', 'UQA2002')
            ->first();

        // Validate subject existence
        if (!$subject) {
            return response()->json(['message' => 'UQA2002 Co-Curriculum subject row not found in database.'], 404);
        }

        // Check if student has already submitted a claim for this subject
        $existingClaim = DB::table('credit_claims')
            ->where('student_id', $studentId)
            ->where('subject_id', $subject->subject_id)
            ->first();

        // If a claim already exists, return a error message
        if ($existingClaim) {
            return response()->json([
                'message' => 'You have already submitted a claim for this credit hour.',
                'status' => $existingClaim->status
            ], 409); 
        }

        // Insert new credit claim record into database
        DB::table('credit_claims')->insert([
            'student_id' => $studentId,
            'subject_id' => $subject->subject_id,
            'status'     => 'pending', 
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Return a success response
        return response()->json(['message' => 'Credit claim submitted successfully!'], 201);
    }

    // 2. Student claim individual module 
    public function claimIndividualModule($id)
    {
        try {

            // set the total required modules for claiming = 4
            $totalRequired = 4;

            // Retrieve booking record of the student 
            $booking = DB::table('bookings')->where('id', $id)->first();

            // If booking record not found, return an error message
            if (!$booking) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Booking record row reference target not found.'
                ], 404);
            }

            // Count total active module bookings exclude absences
            $activeBookingCount = DB::table('bookings')

                // Check for bookings of the student
                ->where('bookings.student_id', $booking->student_id)
                // Exclude rows where student status is 'absent'
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('attendances')
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                        ->whereColumn('attendances.booking_id', 'bookings.id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->count();

            // Enforce minimum required modules check 
            if ($activeBookingCount < $totalRequired) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Not eligible to claim. Insufficient module.',
                    'claimed_count' => DB::table('bookings')
                        ->where('student_id', $booking->student_id)
                        ->where('is_claimed', 1)
                        ->count(),
                    'total_required' => $totalRequired,
                ], 400);
            }

            // Update the booking record to mark the module as claimed
            DB::table('bookings')
                ->where('id', $id)
                ->update([
                    'is_claimed' => 1,
                    'updated_at' => now()
                ]);

            // Re-count final total claimed records
            $claimedCount = DB::table('bookings')
                ->where('student_id', $booking->student_id)
                ->where('is_claimed', 1)
                ->count();

            // Return a success response with claimed count and total required
            return response()->json([
                'status' => 'success',
                'message' => 'Module claimed successfully.',
                'claimed_count' => $claimedCount,
                'total_required' => $totalRequired,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Server script configuration fault: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // 3. Fetch credit claim status records for a student
    public function getClaimStatus($studentId)
    {
        // Query the credit_claims table for the student
        $claim = DB::table('credit_claims')
            ->join('subjects', 'credit_claims.subject_id', '=', 'subjects.subject_id')
            ->where('credit_claims.student_id', $studentId)
            ->select('subjects.subject_code', 'subjects.subject_name', 'credit_claims.status')
            ->first();

        // Return the claim status if found
        if ($claim) {
            return response()->json([
                'status' => 'exists',
                'data' => [
                    'subject_code' => $claim->subject_code,
                    'subject_name' => $claim->subject_name,
                    'status'       => $claim->status, 
                ]
            ], 200);
        }

        // If no claim record found, return a response indicating none
        return response()->json([
            'status' => 'none',
            'data' => null
        ], 200);
    }

    // 4. Fetch all students claims for pusat adab to view
    public function index(Request $request)
    {
        $filter = $request->query('filter', 'all');

        // Query to retrieve credit claims with student details
        $query = DB::table('credit_claims')
            // Join users table mapping the student id integer index reference (9 = 9)
            ->join('users', 'credit_claims.student_id', '=', 'users.id')
            // Pull text Matric Number details out from structural student table safely
            ->leftJoin('students', 'users.id', '=', 'students.id') 
            ->select(
                'credit_claims.id as claim_id',
                'credit_claims.student_id as user_id', 
                'users.name as student_name',
                DB::raw('COALESCE(students.student_id, users.id) as matric_id'), 
                'credit_claims.status as claim_status'
            );

        if ($filter === 'pending') {
            $query->where('credit_claims.status', 'pending');
        }
    
        $claims = $query->get();

        // For each claim record, aggregate matching module entries directly using the user id (9)
        foreach ($claims as $claim) {

            $completedModules = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                // 🎯 FIX: Query using the integer user_id directly to capture your active database structure!
                ->where('bookings.student_id', $claim->user_id)
                ->where('bookings.is_claimed', 1) 
                ->pluck('modules.activity_name'); 

            $claim->completed_modules = $completedModules;
        }

        return response()->json([
            'status' => 'success',
            'count' => $claims->count(),
            'data' => $claims
        ], 200);
    }

    // 5. Pusat adab update claim status and auto-register student into course if claim is approved
    public function updateStatus($id)
    {
        // Set the claim record by id
        $claim = DB::table('credit_claims')->where('id', $id)->first();

        // Validate claim existence
        if (!$claim) {
            return response()->json(['message' => 'Claim record not found.'], 404);
        }

        DB::transaction(function () use ($claim, $id) {
            
        // Update the claim status to approved 
            if ($claim->status !== 'approved') {
                DB::table('credit_claims')
                    ->where('id', $id)
                    ->update([
                        'status' => 'approved',
                        'updated_at' => now()
                    ]);
            }

            // Fetch the section_id for the subject being claimed
            $section = DB::table('sections')
                ->where('subject_id', $claim->subject_id)
                ->first();

            // If no section found, default to section_id = 1
            $sectionId = $section ? $section->section_id : 1; 

            // Check if the student is already registered for the subject
            $alreadyRegistered = DB::table('registration')
                ->where('student_id', $claim->student_id)
                ->where('subject_id', $claim->subject_id)
                ->where('status', 'active')
                ->exists();

            // If not already registered, insert a new registration record
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