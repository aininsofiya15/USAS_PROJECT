<?php
namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB; 
use Illuminate\Support\Str;
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

    public function getStudentDashboardStatus($student_id)
    {
        try {
            // 1. Fetch the latest configuration from block_settings table
            // We use standard column layout matching your saveBlockDate method
            $blockSetting = DB::table('block_settings')
                ->orderBy('created_at', 'desc')
                ->first();

            // Fallback default date string matching your requested layout requirement
            $blockDate = '2026-05-18';
            if ($blockSetting) {
                // Determine if column name uses block_start_date or block_date
                $blockDate = $blockSetting->block_start_date ?? $blockSetting->block_date ?? '2026-05-18';
            }

            // 2. Fetch student payment status profile from fees table
            $feeRecord = DB::table('fees')
                ->where('student_id', $student_id)
                ->orWhere('user_id', $student_id) // Fallback support for primary key lookups
                ->first();

            // Default to 'unpaid' if no table rows exist for this student profile context
            $paymentStatus = $feeRecord ? strtolower($feeRecord->status) : 'unpaid';

            // 3. Return the exact JSON structure required by the Flutter provider
            return response()->json([
                'success' => true,
                'block_date' => Carbon::parse($blockDate)->format('Y-m-d'),
                'payment_status' => $paymentStatus,
                'total_credits' => 12,
                'curriculum_progress' => 0.70
            ], 200);

        } catch (\Exception $e) {
            // If something crashes, log it and return clear debugging context info
            return response()->json([
                'success' => false,
                'message' => 'Backend Error Context: ' . $e->getMessage()
            ], 500);
        }
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
        try {
            // 1. Fetch the profile by joining users, students, fees, and bank accounts
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

            // 2. Check if student records exist
            if (!$data) {
                return response()->json(['message' => 'Student not found'], 404);
            }

            // 3. Calculate Total Payment by summing 'total_payment' from successful payments
            $totalPayment = DB::table('payments')
                ->where('student_id', $data->student_id) 
                ->where('status', 'Success') // Only sum completed transactions
                ->sum('total_payment');       // Explicitly matches your payments table

            // 4. Cast to an array and force float types for stable Flutter parsing
            $result = (array)$data;
            $result['total_invoice'] = (float)($data->total_invoice ?? 0.00);
            $result['total_payment'] = (float)$totalPayment;
            $result['outstanding_amount'] = (float)($data->outstanding_amount ?? 0.00);

            return response()->json($result);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
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
                ->select('payment_id', 'payment_desc', 'total_payment as amount', 'payment_date')
                ->orderBy('payment_date', 'desc')
                ->get();

            return response()->json($history);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function completePayment(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'amount' => 'required|numeric|min:1',
            'method' => 'required|string'
        ]);

        // Find student table matching row
        $student = DB::table('students')->where('id', $request->user_id)->first();
        if (!$student) {
            return response()->json(['error' => 'Student record not found'], 404);
        }

        $fee = DB::table('fees')->where('student_id', $student->student_id)->first();

        DB::beginTransaction();
        try {
            // 1. Create a successful invoice item entry track line
            $paymentId = 'TXN-' . strtoupper(Str::random(8));
            DB::table('payments')->insert([
                'payment_id' => $paymentId,
                'student_id' => $student->student_id,
                'fee_id' => $fee->fee_id ?? null,
                'total_payment' => $request->amount,
                'payment_desc' => 'Tuition Fee Balance Settlement',
                'payment_method' => $request->method,
                'status' => 'Success', // Instantly marked successful
                'payment_date' => now(),
            ]);

            // 2. Adjust outstanding fields on fees table structure
            if ($fee) {
                $newPaidAmount = $fee->paid_amount + $request->amount;
                // Ensure outstanding never drops into negative anomalies
                $newOutstanding = max(0, $fee->total_invoice - $newPaidAmount); 
                $newStatus = $newOutstanding <= 0 ? 'paid' : 'unpaid';

                DB::table('fees')->where('student_id', $student->student_id)->update([
                    'paid_amount' => $newPaidAmount,
                    'outstanding_amount' => $newOutstanding,
                    'status' => $newStatus,
                    'updated_at' => now()
                ]);
            }

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Balances updated successfully']);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Transaction tracking breakdown: ' . $e->getMessage()], 500);
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

    // 1. Calculate dynamic metrics and generate an aesthetic PDF Report layout
    public function downloadFinancialReportPDF()
    {
        // Aggregate absolute sums directly from database transaction columns
        $totalPaid = \DB::table('payments')->where('status', 'Success')->sum('amount');
        $totalOutstanding = \DB::table('fees')->sum('outstanding_amount');
        $blockedCount = \DB::table('students')->where('is_blocked', true)->count();

        $paidStudentsCount = \DB::table('fees')->where('status', 'paid')->count();
        $unpaidStudentsCount = \DB::table('fees')->where('status', 'unpaid')->count();

        // Gather table items to render inside the document
        $records = \DB::table('users')
            ->join('students', 'users.id', '=', 'students.id')
            ->leftJoin('fees', 'students.student_id', '=', 'fees.student_id')
            ->select('students.student_id', 'users.name', 'fees.total_invoice', 'fees.paid_amount', 'fees.outstanding_amount', 'fees.status')
            ->orderBy('students.student_id', 'asc')
            ->get();

        $data = [
            'totalPaid' => $totalPaid,
            'totalOutstanding' => $totalOutstanding,
            'blockedCount' => $blockedCount,
            'paidCount' => $paidStudentsCount,
            'unpaidCount' => $unpaidStudentsCount,
            'records' => $records,
            'generatedAt' => now()->format('d MMMM YYYY H:i:s')
        ];

        // Inline structural HTML with minimal styling optimized specifically for DomPDF engines
        $html = '
        <html>
        <head>
            <style>
                body { font-family: sans-serif; color: #333; margin: 10px; }
                .header { text-align: center; margin-bottom: 30px; }
                .title { font-size: 24px; font-weight: bold; color: #1A5276; }
                .meta-box { width: 100%; margin-bottom: 25px; border-collapse: collapse; }
                .meta-card { background: #F2F4F4; padding: 15px; text-align: center; border: 1px solid #E5E7E9; width: 30%; }
                .meta-label { font-size: 11px; text-transform: uppercase; color: #7F8C8D; margin-bottom: 5px; }
                .meta-value { font-size: 16px; font-weight: bold; color: #2C3E50; }
                .data-table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 12px; }
                .data-table th { background: #1A5276; color: white; padding: 8px; text-align: left; }
                .data-table td { padding: 8px; border-bottom: 1px solid #E5E7E9; }
                .status-badge { font-weight: bold; text-transform: uppercase; font-size: 10px; }
                .paid { color: #27AE60; } .unpaid { color: #E67E22; }
            </style>
        </head>
        <body>
            <div class="header">
                <div class="title">USAS Financial Report Overview</div>
                <div style="font-size: 11px; color: #95A5A6; margin-top: 5px;">Generated on: '.$data['generatedAt'].'</div>
            </div>

            <table class="meta-box" align="center">
                <tr>
                    <td class="meta-card">
                        <div class="meta-label">Total Collections</div>
                        <div class="meta-value">RM '.number_format($totalPaid, 2).'</div>
                    </td>
                    <td style="width: 5%"></td>
                    <td class="meta-card">
                        <div class="meta-label">Outstanding Balances</div>
                        <div class="meta-value">RM '.number_format($totalOutstanding, 2).'</div>
                    </td>
                    <td style="width: 5%"></td>
                    <td class="meta-card">
                        <div class="meta-label">Blocked Accounts</div>
                        <div class="meta-value">'.$blockedCount.' Students</div>
                    </td>
                </tr>
            </table>

            <h3>Account Ledger Summary</h3>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Matric ID</th>
                        <th>Student Name</th>
                        <th>Invoiced</th>
                        <th>Paid</th>
                        <th>Outstanding</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>';
                foreach($records as $row) {
                    $html .= '<tr>
                        <td>'.$row->student_id.'</td>
                        <td>'.$row->name.'</td>
                        <td>RM '.number_format($row->total_invoice, 2).'</td>
                        <td>RM '.number_format($row->paid_amount, 2).'</td>
                        <td>RM '.number_format($row->outstanding_amount, 2).'</td>
                        <td class="status-badge '.strtolower($row->status).'">'.$row->status.'</td>
                    </tr>';
                }
        $html .= '</tbody>
            </table>
        </body>
        </html>';

        $pdf = \Pdf::loadHTML($html);
        return $pdf->download('USAS-Financial-Report-'.now()->format('Ymd').'.pdf');
    }

    // 2. Streams flat structured CSV tracking directly via native PHP output handles
    public function downloadFinancialReportCSV()
    {
        $fileName = 'USAS-Financial-Ledger-'.now()->format('Ymd').'.csv';
        
        $records = \DB::table('users')
            ->join('students', 'users.id', '=', 'students.id')
            ->leftJoin('fees', 'students.student_id', '=', 'fees.student_id')
            ->select('students.student_id', 'users.name', 'fees.total_invoice', 'fees.paid_amount', 'fees.outstanding_amount', 'fees.status')
            ->orderBy('students.student_id', 'asc')
            ->get();

        $headers = [
            "Content-type"        => "text/csv",
            "Content-Disposition" => "attachment; filename=$fileName",
            "Pragma"              => "no-cache",
            "Cache-Control"       => "must-revalidate, post-check=0, pre-check=0",
            "Expires"             => "0"
        ];

        $callback = function() use($records) {
            $file = fopen('php://output', 'w');
            
            // Setup structural column headings
            fputcsv($file, ['Matric ID', 'Student Name', 'Total Invoiced (RM)', 'Total Paid (RM)', 'Outstanding Balance (RM)', 'Fee Status']);

            foreach ($records as $row) {
                fputcsv($file, [
                    $row->student_id,
                    $row->name,
                    number_format($row->total_invoice, 2, '.', ''),
                    number_format($row->paid_amount, 2, '.', ''),
                    number_format($row->outstanding_amount, 2, '.', ''),
                    strtoupper($row->status)
                ]);
            }
            
            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }
}
