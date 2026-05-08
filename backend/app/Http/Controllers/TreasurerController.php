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

    public function getTuitionFeesSummary(Request $request) 
{
    // 1. Get Summary Counts
    $paidCount = \App\Models\Fee::where('status', 'paid')->count();
    $unpaidCount = \App\Models\Fee::where('status', 'unpaid')->count();
    $blockedCount = \App\Models\Student::where('is_blocked', true)->count();

    // 2. Fetch Students with JOINs
    $students = \DB::table('users')
        ->where('users.role', 'student')
        ->join('students', 'users.id', '=', 'students.id') // Link users.id to students.id
        ->leftJoin('fees', 'students.id', '=', 'fees.student_id') // Link students.id to fees.student_id
        ->select(
            'users.id',
            'users.name', 
            'students.student_id', // This is the Matric ID string (e.g., CA24030)
            'fees.outstanding_amount', 
            'fees.status',
            'students.is_blocked'
        );

    // 3. Apply Search if user typed in the search bar
    if ($request->has('search') && $request->search != '') {
        $searchTerm = $request->search;
        $students->where(function($q) use ($searchTerm) {
            $q->where('users.name', 'like', "%$searchTerm%")
              ->orWhere('students.student_id', 'like', "%$searchTerm%");
        });
    }

    return response()->json([
        'summary' => [
            'paid' => $paidCount,
            'unpaid' => $unpaidCount,
            'blocked' => $blockedCount
        ],
        'students' => $students->get(), // Returns the full list
        'total_pages' => 1 // For now, keep it simple
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
    
    public function getStudentFeeDetail($id)
    {
        $student = \DB::table('users')
            ->join('students', 'users.id', '=', 'students.id')
            ->leftJoin('fees', 'students.id', '=', 'fees.student_id')
            ->select(
                'users.name', 'users.email', 'users.phone_num',
                'students.student_id as matric_id', 'students.faculty', 'students.course_name', 'students.program',
                'fees.total_fee', 'fees.paid_amount', 'fees.outstanding_amount', 'fees.status'
            )
            ->where('users.id', $id)
            ->first();

        return response()->json($student);
    }
}