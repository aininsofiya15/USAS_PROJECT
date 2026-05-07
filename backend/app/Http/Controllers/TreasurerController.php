<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Student;
use App\Models\StudentFee;
use App\Models\BlockSetting;
use App\Models\Payment;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class TreasurerController extends Controller
{
    public function getStudentCount()
    {
        // Query to count users where role is 'student'
        $count = User::where('role', 'student')->count();

        return response()->json([
            'total_students' => $count
        ]);
    }

    public function getTuitionFeesSummary() {
    // Summary Counts
    $paidCount = \App\Models\Fee::where('status', 'paid')->count();
    $unpaidCount = \App\Models\Fee::where('status', 'unpaid')->count();
    $blockedCount = \App\Models\Student::where('is_blocked', true)->count();

    $students = \DB::table('students')
        ->join('users', 'students.user_id', '=', 'users.user_id')
        ->join('fees', 'students.user_id', '=', 'fees.user_id')
        ->select(
            'students.matric_id', 
            'users.name', 
            'fees.outstanding_amount', 
            'fees.status',
            'students.is_blocked'
        )
        ->get();

        return response()->json([
            'summary' => [
                'paid' => $paidCount,
                'unpaid' => $unpaidCount,
                'blocked' => $blockedCount
            ],
            'students' => $students
    ]);
}
    
    public function getStudentsFeeStatus(Request $request)
    {
        $query = StudentFee::with('student.user');
        
        if ($request->has('search')) {
            $query->whereHas('student.user', function($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('email', 'like', '%' . $request->search . '%');
            });
        }
        
        if ($request->has('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }
        
        $fees = $query->paginate(20);
        
        $formattedStudents = $fees->map(function($fee) {
            $student = $fee->student;
            $user = $student->user;
            
            return [
                'student_id' => $student->student_id,
                'name' => $user ? $user->name : 'N/A',
                'matric_no' => $student->student_id, // Or use a matric_no field if exists
                'total_fees' => $fee->total_fees,
                'paid_amount' => $fee->paid_amount,
                'balance' => $fee->balance,
                'status' => $fee->status,
                'is_blocked' => $fee->is_blocked
            ];
        });
        
        return response()->json([
            'students' => $formattedStudents,
            'current_page' => $fees->currentPage(),
            'total_pages' => $fees->lastPage()
        ]);
    }
    
    public function getStudentFeeDetail($studentId)
    {
        $student = Student::with(['user', 'fee', 'fee.payments', 'bankAccount'])
            ->findOrFail($studentId);
            
        return response()->json([
            'student' => [
                'id' => $student->student_id,
                'name' => $student->user ? $student->user->name : 'N/A',
                'email' => $student->user ? $student->user->email : 'N/A',
                'matric_no' => $student->student_id,
                'faculty' => $student->faculty,
                'course' => $student->course_name,
                'semester' => $student->current_semester
            ],
            'fee_summary' => [
                'total_fees' => $student->fee ? $student->fee->total_fees : 0,
                'paid_amount' => $student->fee ? $student->fee->paid_amount : 0,
                'balance' => $student->fee ? $student->fee->balance : 0,
                'status' => $student->fee ? $student->fee->status : 'unpaid'
            ],
            'payment_history' => $student->fee ? $student->fee->payments : [],
            'bank_account' => $student->bankAccount
        ]);
    }
}