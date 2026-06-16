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
        $request->validate([
            'student_id' => 'required|integer',
        ]);

        $studentId = $request->input('student_id');

        $subject = DB::table('subjects')
            ->where('subject_code', 'UQA2002')
            ->first();

        if (!$subject) {
            return response()->json(['message' => 'UQA2002 Co-Curriculum subject row not found in database.'], 404);
        }

        $existingClaim = DB::table('credit_claims')
            ->where('student_id', $studentId)
            ->where('subject_id', $subject->subject_id)
            ->first();

        if ($existingClaim) {
            return response()->json([
                'message' => 'You have already submitted a claim for this credit hour.',
                'status' => $existingClaim->status
            ], 409); 
        }

        DB::table('credit_claims')->insert([
            'student_id' => $studentId,
            'subject_id' => $subject->subject_id,
            'status'     => 'pending', 
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['message' => 'Credit claim submitted successfully!'], 201);
    }

    /**
     * Individual Module Claim Logic
     */
    public function claimIndividualModule($id)
    {
        try {
            $totalRequired = 4;

            // Find the specific booking row entry
            $booking = DB::table('bookings')->where('id', $id)->first();

            if (!$booking) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Booking record row reference target not found.'
                ], 404);
            }

            $activeBookingCount = DB::table('bookings')
                ->where('bookings.student_id', $booking->student_id)
                ->whereNotExists(function ($query) {
                    $query->select(DB::raw(1))
                        ->from('attendances')
                        ->join('attendance_records', 'attendances.id', '=', 'attendance_records.attendance_id')
                        ->whereColumn('attendances.booking_id', 'bookings.id')
                        ->whereColumn('attendance_records.student_id', 'bookings.student_id')
                        ->whereRaw('LOWER(attendance_records.status) = ?', ['absent']);
                })
                ->count();

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

            // Update column flag to true (1)
            DB::table('bookings')
                ->where('id', $id)
                ->update([
                    'is_claimed' => 1,
                    'updated_at' => now()
                ]);

            $claimedCount = DB::table('bookings')
                ->where('student_id', $booking->student_id)
                ->where('is_claimed', 1)
                ->count();

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

    public function getClaimStatus($studentId)
    {
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
                    'status'       => $claim->status, 
                ]
            ], 200);
        }

        return response()->json([
            'status' => 'none',
            'data' => null
        ], 200);
    }

    public function index(Request $request)
    {
        $filter = $request->query('filter', 'all');

        $query = DB::table('credit_claims')
            ->join('users', 'credit_claims.student_id', '=', 'users.id')
            ->leftJoin('students', 'users.id', '=', 'students.id') 
            ->select(
                'credit_claims.id as claim_id',
                'credit_claims.student_id',
                'users.name as student_name',
                DB::raw('COALESCE(students.student_id, users.id) as matric_id'), 
                'credit_claims.status as claim_status'
            );

        if ($filter === 'pending') {
            $query->where('credit_claims.status', 'pending');
        }

        $claims = $query->get();

        foreach ($claims as $claim) {
            $completedModules = DB::table('bookings')
                ->join('modules', 'bookings.module_id', '=', 'modules.id')
                ->where('bookings.student_id', $claim->student_id)
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

    /**
     * ✅ UPDATE CREDIT CLAIM STATUS & REGISTER STUDENT
     */
    public function updateStatus($id)
    {
        $claim = DB::table('credit_claims')->where('id', $id)->first();

        if (!$claim) {
            return response()->json(['message' => 'Claim record not found.'], 404);
        }

        DB::transaction(function () use ($claim, $id) {
            
            if ($claim->status !== 'approved') {
                DB::table('credit_claims')
                    ->where('id', $id)
                    ->update([
                        'status' => 'approved',
                        'updated_at' => now()
                    ]);
            }

            // 🎯 FIXED: Dynamic lookup matching her 'sections.section_id' target primary column
            $section = DB::table('sections')
                ->where('subject_id', $claim->subject_id)
                ->first();
                
            // 🎯 FIXED: Defends against inner joins by defaulting to 1 if no section entry exists yet
            $sectionId = $section ? $section->section_id : 1; 

            $alreadyRegistered = DB::table('registration')
                ->where('student_id', $claim->student_id)
                ->where('subject_id', $claim->subject_id)
                ->where('status', 'active')
                ->exists();

            // 🎯 PERFECT ALIGNMENT: lab_id passes null clean, matching her new leftJoin structure!
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
