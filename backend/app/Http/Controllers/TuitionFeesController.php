<?php
namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB; 
use App\Models\User;
use App\Models\Student;
use App\Models\StudentFee;
use App\Models\BlockSetting;
use App\Models\Payment;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class TuitionFeesController extends Controller
{
    public function index()
    {
        // We join users, students, and fees tables to get everything in one list
        $data = DB::table('users')
            ->join('students', 'users.id', '=', 'students.id')
            ->leftJoin('fees', 'users.id', '=', 'fees.student_id')
            ->where('users.role', 'student')
            ->select(
                'students.student_id as matric_id',
                'users.name',
                'fees.outstanding_amount',
                'fees.status',
                'students.is_blocked'
            )
            ->get();

        return response()->json($data);
    }

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
    
    public function getStudentDetail($userId)
    {
        try {
            $student = \DB::table('users')
                // Link directly on the id field since user_id doesn't exist
                ->join('students', 'users.id', '=', 'students.id') 
                // Link fees to students using the matric number (student_id)
                ->leftJoin('fees', 'students.student_id', '=', 'fees.student_id') 
                ->where('users.id', $userId)
                ->select(
                    'users.name',
                    'users.email',
                    'users.phone_num',
                    'students.student_id',
                    'students.course_name',
                    'students.program',
                    'fees.outstanding_amount',
                    'fees.status'
                )
                ->first();

            if (!$student) {
                return response()->json(null, 200); 
            }

            return response()->json($student);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    } 

    // Get the count of unpaid students for the preview
    public function getUnpaidCount() {
        $count = \App\Models\Fee::where('status', 'unpaid')->count();
        return response()->json(['unpaid_count' => $count]);
    }

    // Save the block date
    public function saveBlockSettings(Request $request) {
        $request->validate(['block_date' => 'required|date']);
        
        // Store in your settings table
        \DB::table('block_settings')->updateOrInsert(
            ['id' => 1], // Assuming a single global config row
            ['block_start_date' => $request->block_date, 'updated_at' => now()]
        );

        return response()->json(['message' => 'Block start date has been set!']);
    }

    //students
    public function getStudentFinancialProfile($userId)
    {
        // 1. Fetch the profile
        $data = DB::table('students')
            ->join('users', 'users.id', '=', 'students.id') 
            ->leftJoin('fees', 'students.student_id', '=', 'fees.student_id')
            ->leftJoin('bank_accounts', 'students.student_id', '=', 'bank_accounts.student_id')
            ->select(
                'users.name',
                'students.student_id', 
                'students.ic_no',
                'students.course_name',
                'students.program',
                'bank_accounts.bank_name',
                'bank_accounts.acc_no',
                'fees.total_invoice', 
                'fees.outstanding_amount' 
            )
            ->where('users.id', $userId)
            ->first();

        // 2. Check if student exists
        if (!$data) {
            return response()->json(['message' => 'Student not found'], 404);
        }

        // 3. Calculate Total Payment
        // We use $data->student_id (the matric string) to find payments
        $totalPayment = DB::table('payments')
            ->where('student_id', $data->student_id) 
            ->sum('total_payment');

        // 4. Merge and Return
        $result = (array)$data;
        $result['total_payment'] = (float)$totalPayment;

        return response()->json($result);
    }

    public function updateStudentBank(Request $request)
    {
        try {
            // 1. Validate the incoming data
            $request->validate([
                'student_id' => 'required', // This is the numerical User ID
                'acc_no' => 'required|numeric',
                'bank_name' => 'required|string',
            ]);

            // 2. Find the matric number (student_id string) from the students table 
            // because bank_accounts table uses the matric number, not user_id
            $matricId = DB::table('students')
                ->where('id', $request->student_id)
                ->value('student_id');

            if (!$matricId) {
                return response()->json(['message' => 'Student record not found'], 404);
            }

            // 3. Update or Insert the bank account info
            DB::table('bank_accounts')->updateOrInsert(
                ['student_id' => $matricId], // Match based on Matric No (e.g., CA24030)
                [
                    'acc_no' => $request->acc_no,
                    'bank_name' => $request->bank_name,
                    'updated_at' => now()
                ]
            );

            return response()->json(['message' => 'Record has been saved!'], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getPaymentHistory($userId)
    {
        try {
            // 1. Get the matric ID (student_id string) for this user
            $matricId = DB::table('students')->where('id', $userId)->value('student_id');

            if (!$matricId) {
                return response()->json([], 200);
            }

            // 2. Fetch payments
            $history = DB::table('payments')
                ->where('student_id', $matricId)
                ->select('payment_id', 'payment_desc', 'amount', 'payment_date')
                ->orderBy('payment_date', 'desc')
                ->get();

            return response()->json($history);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}