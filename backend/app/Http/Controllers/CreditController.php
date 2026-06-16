<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CreditController extends Controller
{

    // 1. Student submit final credit claim 
    public function submitFinalCredit(Request $request)
    {
        // Validate student id parameters
        $request->validate([
            'student_id' => 'required|integer',
        ]);

        // Extract student ID from the request 
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

        // If subject already exists, display error messsage
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

        // Return success message when claim submission success
        return response()->json(['message' => 'Credit claim submitted successfully!'], 201);
    }

    // 2. Student claim module 
    public function claimIndividualModule($id)
    {
        try {

            // Define the total number of modules required for credit claim
            $totalRequired = 4;

            // Retrieve booking record by ID
            $booking = DB::table('bookings')->where('id', $id)->first();

            // Validate booking record existence
            if (!$booking) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Booking record row reference target not found.'
                ], 404);
            }

            // Count total active module bookings excluding absences
            $activeBookingCount = DB::table('bookings')
                // Check for active bookings of the student 
                ->where('bookings.student_id', $booking->student_id)
                // Join with attendances and attendance_records to exclude absences modules
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

            // Return success message with number of claimed modules and balance required modules for claim the credit
            return response()->json([
                'status' => 'success',
                'message' => 'Module claimed successfully.',
                'claimed_count' => $claimedCount,
                'total_required' => $totalRequired,
            ], 200);

        } catch (\Exception $e) {
            // Handle unexpected runtime error exceptions
            return response()->json([
                'status' => 'error',
                'message' => 'Server script configuration fault: ' . $e->getMessage()
            ], 500);
        }
    }

    // 3. Fetch credit claim status records for a student
    public function getClaimStatus($studentId)
    {
        // Retrieve the credit claim status for the student
        $claim = DB::table('credit_claims')
            // Join with subjects table to get subject details for the claim
            ->join('subjects', 'credit_claims.subject_id', '=', 'subjects.subject_id')
            ->where('credit_claims.student_id', $studentId)
            ->select('subjects.subject_code', 'subjects.subject_name', 'credit_claims.status')
            ->first();

        // If claim record exists, return the claim status and subject details
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

        // If no claim record found, return status indicating no claim exists
        return response()->json([
            'status' => 'none',
            'data' => null
        ], 200);
    }

    // 4. Fetch all students claims for pusat adab to view
    public function index(Request $request)
    {
        // Optional filter parameter to retrieve only pending claims
        $filter = $request->query('filter', 'all');

        // Query to retrieve credit claims with student details
        $query = DB::table('credit_claims')
            // Join with users and students tables to get student details for each claim
            ->join('users', 'credit_claims.student_id', '=', 'users.id')
            ->leftJoin('students', 'users.id', '=', 'students.id') 
            ->select(
                'credit_claims.id as claim_id',
                'credit_claims.student_id',
                'users.name as student_name',
                DB::raw('COALESCE(students.student_id, users.id) as matric_id'), 
                'credit_claims.status as claim_status'
            );

        // Apply filter to retrieve only pending claims 
        if ($filter === 'pending') {
            $query->where('credit_claims.status', 'pending');
        }
    
        $claims = $query->get();

        // For each claim, retrieve the list of completed modules that have been claimed by the student
        foreach ($claims as $claim) {

            // Retrieve the list of completed modules that have been claimed by the student
            $completedModules = DB::table('bookings')
                 // Join with modules table to get module details of the student's claimed modules
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $claim->student_id)
                ->where('bookings.is_claimed', 1) 
                ->pluck('modules.activity_name'); 

            $claim->completed_modules = $completedModules;
        }

        // Return  list of claims with student details and their completed claimed modules
        return response()->json([
            'status' => 'success',
            'count' => $claims->count(),
            'data' => $claims
        ], 200);
    }

    // 5. Pusat adab update claim status and auto-register student into course if claim is approved
    public function updateStatus($id)
    {
        // Retrieve the credit claim record by ID
        $claim = DB::table('credit_claims')->where('id', $id)->first();

        // Validate claim record existence, if not found return error message
        if (!$claim) {
            return response()->json(['message' => 'Claim record not found.'], 404);
        }

        // Use database transaction to ensure data integrity during claim status update 
        DB::transaction(function () use ($claim, $id) {
            
            // Update claim status to 'approved' it havent approved
            if ($claim->status !== 'approved') {
                // Update the claim status to 'approved' in the database
                DB::table('credit_claims')
                    ->where('id', $id)
                    ->update([
                        'status' => 'approved',
                        'updated_at' => now()
                    ]);
            }

            // Retrieve the section ID for the subject to be registered, default to 1 if not found
            $section = DB::table('sections')
                ->where('subject_id', $claim->subject_id)
                ->first();
            
            // If section record exists, use the section ID, otherwise default to 1
            $sectionId = $section ? $section->section_id : 1; 

            // Check if the student is already registered for the subject to prevent duplicate registration
            $alreadyRegistered = DB::table('registration')
                ->where('student_id', $claim->student_id)
                ->where('subject_id', $claim->subject_id)
                ->where('status', 'active')
                ->exists();

            // If the student is not yet registered, insert a new registration record for the student into the course
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

        // Return success message after claim status update and auto-registration process
        return response()->json([
            'status' => 'success',
            'message' => 'Application approved and student auto-registered into the course successfully.'
        ], 200);
    }
}