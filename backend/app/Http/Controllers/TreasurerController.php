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

    public function dashboardSummary()
    {
        $paidStudents = StudentFee::where('status', 'paid')->count();
        $unpaidStudents = StudentFee::where('status', 'unpaid')->count();
        $blockedStudents = StudentFee::where('status', 'blocked')
            ->orWhere(function($q) {
                $q->whereNotNull('block_start_date')->where('block_start_date', '<=', now());
            })->count();
        

        $totalStudents = User::where('role', 'student')->count();
        $totalCollectedToday = Payment::whereDate('paid_at', today())->sum('amount');
        $totalCollectedThisWeek = Payment::whereBetween('paid_at', [now()->startOfWeek(), now()->endOfWeek()])->sum('amount');
        
        return response()->json([
            'paid_students' => $paidStudents,
            'unpaid_students' => $unpaidStudents,
            'blocked_students' => $blockedStudents,
            'total_students' => $totalStudents,
            'total_collected_today' => $totalCollectedToday,
            'total_collected_this_week' => $totalCollectedThisWeek
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