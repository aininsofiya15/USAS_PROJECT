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
        $perPage = $request->query('per_page', 10);
        $statusFilter = $request->query('status', 'all');
        $search = $request->query('search', '');

        // 1. Correct Join Logic
        // We join users -> students (to get the matric ID) -> fees (to get the money)
        $query = \DB::table('users')
            ->join('students', 'users.id', '=', 'students.id')
            ->leftJoin('fees', 'students.student_id', '=', 'fees.student_id')
            ->where('users.role', 'student')
            ->select([
                'users.id',
                'users.name', 
                'students.student_id', // This is the Matric ID (e.g., CD23001)
                'fees.outstanding_amount', 
                'fees.status',
                'students.is_blocked'
            ]);

        // 2. Apply Search
        if (!empty($search)) {
            $query->where(function($q) use ($search) {
                $q->where('users.name', 'like', "%$search%")
                ->orWhere('students.student_id', 'like', "%$search%");
            });
        }

        // 3. Apply Filter
        if ($statusFilter !== 'all') {
            $query->where('fees.status', $statusFilter);
        }

        // 4. Correct Pagination
        // Using paginate() automatically calculates total_pages and current_page for Flutter
        $students = $query->paginate($perPage);

        return response()->json([
            'summary' => [
                'paid' => \DB::table('fees')->where('status', 'paid')->count(),
                'unpaid' => \DB::table('fees')->where('status', 'unpaid')->count(),
                'blocked' => \DB::table('students')->where('is_blocked', true)->count()
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
    
    public function getStudentDetail($userId)
    {
        try {
            $student = \DB::table('users')
                ->join('students', 'users.id', '=', 'students.id') 
                ->leftJoin('fees', 'students.student_id', '=', 'fees.student_id') 
                ->where('users.id', $userId)
                ->select(
                    'users.name',
                    'users.email',
                    'users.phone_num',
                    'students.student_id',
                    'students.course_name',
                    'students.program',
                    'fees.total_invoice',      // Added this field
                    'fees.outstanding_amount',
                    'fees.status',
                    // Subquery to calculate total payment from payments table
                    \DB::raw('(SELECT SUM(amount) FROM payments WHERE student_id = students.student_id) as total_payment')
                )
                ->first();

            if (!$student) {
                return response()->json(null, 200); 
            }

            // Convert to array to ensure we return clean JSON
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
    public function updateBlockSettings(Request $request) 
{
        $request->validate([
            'treasurer_id' => 'required', // This is the numeric User ID from Flutter
            'block_start_date' => 'required|date',
        ]);

        try {
            $userId = intval($request->treasurer_id);
            $formattedDate = \Carbon\Carbon::parse($request->block_start_date)->format('Y-m-d');

            // 1. Find the corresponding row in treasurers using the logged-in user's numeric ID
            $treasurer = \DB::table('treasurers')->where('id', $userId)->first();

            // 2. If they don't exist yet, automatically provision them a profile
            if (!$treasurer) {
                $stringIdentifier = 'TR' . str_pad($userId, 4, '0', STR_PAD_LEFT); // Generates TR0001, etc.
                
                \DB::table('treasurers')->insert([
                    'id' => $userId,
                    'treasurer_id' => $stringIdentifier,
                    'department' => 'Treasury Department',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                
                $targetStringId = $stringIdentifier;
            } else {
                // Grab the string format (TRXXXX) from the database record
                $targetStringId = $treasurer->treasurer_id;
            }

            // 3. Perform an update-or-insert into block_settings using the matching string foreign key
            \DB::table('block_settings')->updateOrInsert(
                ['treasurer_id' => $targetStringId], // Matches based on the correct string ID relation
                [
                    'block_date' => $formattedDate,
                    'updated_at' => now()
                ]
            );

            return response()->json(['success' => true], 200);

        } catch (\Exception $e) {
            \Log::error("CRITICAL ERROR IN BLOCK SETTINGS: " . $e->getMessage());
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getFeesSummary(Request $request) {
        $perPage = $request->query('per_page', 10);
        $statusFilter = $request->query('status', 'all');
        $search = $request->query('search', '');

        // 1. Start with the User model and JOIN the fees table
        $query = User::query()
            ->join('fees', 'users.student_id', '=', 'fees.student_id') // Link by student_id
            ->select([
                'users.id', 
                'users.name', 
                'users.student_id', 
                'fees.outstanding_amount', // This MUST be selected to show in Flutter
                'fees.status',             // This MUST be selected to show in Flutter
                'users.is_blocked'
            ]);

        // 2. Apply Search logic
        if (!empty($search)) {
            $query->where('users.name', 'like', "%$search%")
                ->orWhere('users.student_id', 'like', "%$search%");
        }

        // 3. Apply Status Filter
        if ($statusFilter !== 'all') {
            $query->where('fees.status', $statusFilter);
        }

        // 4. USE paginate() - This fixes the 1-10 per page and the [ < 1 2 > ] buttons
        $students = $query->paginate($perPage);

        return response()->json([
            'summary' => [
                'paid' => DB::table('fees')->where('status', 'paid')->count(),
                'unpaid' => DB::table('fees')->where('status', 'unpaid')->count(),
                'blocked' => DB::table('users')->where('is_blocked', 1)->count(),
            ],
            'students' => $students
        ]);
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

    public function getFinancialReportTotals()
    {
        try {
            // Calculate total amount collected from students with 'paid' status
            $totalPaid = \DB::table('fees')
                ->where('status', 'paid')
                ->sum('total_invoice'); 

            // Calculate the total sum of all outstanding balances
            $totalOutstanding = \DB::table('fees')
                ->sum('outstanding_amount');

            return response()->json([
                'total_paid' => (float)$totalPaid,
                'total_outstanding' => (float)$totalOutstanding,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}