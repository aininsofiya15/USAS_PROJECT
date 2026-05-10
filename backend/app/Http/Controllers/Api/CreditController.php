<?php
//not yet implemente
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\AttendanceRecord;
use App\Models\CreditClaim;

class CreditClaimController extends Controller
{
    /**
     * METHOD 1: Claim Individual Module
     * This marks a single activity (e.g., Kayaking) as "Used" for credit.
     */
    public function claimModule(Request $request)
    {
        $request->validate(['id' => 'required|integer']);

        $record = AttendanceRecord::findOrFail($request->id);

        // Security check: Student must be Present and have marks to claim
        if ($record->status !== 'present' || $record->marks < 50) {
            return response()->json(['message' => 'Module not eligible for claim.'], 403);
        }

        $record->is_claimed = 1; // Mark this specific booking as used
        $record->save();

        return response()->json(['message' => 'Module claimed successfully!']);
    }

    /**
     * METHOD 2: Final Subject Credit Submission
     * Only works if the user has completed Method 1 four times.
     */
    public function submitFinalCredit(Request $request)
    {
        $request->validate([
            'student_id' => 'required|integer',
            'subject_id' => 'required|integer'
        ]);

        // COUNT logic: Check how many individual modules have been "Claimed"
        $claimedCount = AttendanceRecord::where('student_id', $request->student_id)
            ->where('is_claimed', 1)
            ->count();

        // 4-Module Rule Validation
        if ($claimedCount < 4) {
            return response()->json([
                'message' => 'Not Eligible to Claim (Insufficient Module)',
                'current_count' => $claimedCount
            ], 403);
        }

        // Create the final application for Pusat Adab approval
        $claim = CreditClaim::create([
            'student_id' => $request->student_id,
            'subject_id' => $request->subject_id,
            'status' => 'pending',
        ]);

        return response()->json(['message' => 'Credit Claim Successfully Submitted!'], 201);
    }
}