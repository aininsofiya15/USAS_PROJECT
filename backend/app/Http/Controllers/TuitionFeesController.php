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
use Stripe\Stripe;
    
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
            $blockSetting = DB::table('block_settings')
                ->orderBy('created_at', 'desc')
                ->first();

            $blockDate = '2026-05-18';
            if ($blockSetting) {
                $blockDate = $blockSetting->block_start_date ?? $blockSetting->block_date ?? '2026-05-18';
            }

            $feeRecord = DB::table('fees')
                ->where('student_id', $student_id)
                ->orWhere('user_id', $student_id)
                ->first();

            $paymentStatus = $feeRecord ? strtolower($feeRecord->status) : 'unpaid';
            $outstandingAmount = $feeRecord ? $feeRecord->outstanding_amount : 0;

            // ✅ Check if student is blocked - changed isAfter to gte
            $today = Carbon::now();
            $blockDateParsed = Carbon::parse($blockDate);
            $isUnpaid = $paymentStatus === 'unpaid' && $outstandingAmount > 0;
            $isBlocked = $isUnpaid && $today->gte($blockDateParsed); // ✅ TODAY OR PAST

            return response()->json([
                'success' => true,
                'block_date' => Carbon::parse($blockDate)->format('Y-m-d'),
                'payment_status' => $paymentStatus,
                'total_credits' => 12,
                'curriculum_progress' => 0.70,
                'is_blocked' => $isBlocked,
                'outstanding_amount' => $outstandingAmount,
                'block_message' => $isBlocked ? 'Your academic access has been blocked due to unpaid tuition fees.' : null
            ], 200);

        } catch (\Exception $e) {
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
                    'fees.total_invoice',
                    'fees.outstanding_amount',
                    'fees.status',
                    // ✅ Fixed: Use total_payment instead of amount
                    \DB::raw('(SELECT SUM(total_payment) FROM payments WHERE student_id = students.student_id AND status = "Success") as total_payment')
                )
                ->first();

            if (!$student) {
                return response()->json(['error' => 'Student not found'], 404); 
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

    /**
 * UPDATE BLOCK SETTINGS - Creates Payment Reminder & Block Warning for unpaid students
 */
    public function updateBlockSettings(Request $request) 
    {
        $request->validate([
            'treasurer_id' => 'required',
            'block_start_date' => 'required|date',
        ]);

        try {
            $userId = intval($request->treasurer_id);
            $formattedDate = \Carbon\Carbon::parse($request->block_start_date)->format('Y-m-d');

            // 1. Find the corresponding row in treasurers using the logged-in user's numeric ID
            $treasurer = \DB::table('treasurers')->where('id', $userId)->first();

            // 2. If they don't exist yet, automatically provision them a profile
            if (!$treasurer) {
                $stringIdentifier = 'TR' . str_pad($userId, 4, '0', STR_PAD_LEFT);
                
                \DB::table('treasurers')->insert([
                    'id' => $userId,
                    'treasurer_id' => $stringIdentifier,
                    'department' => 'Treasury Department',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                
                $targetStringId = $stringIdentifier;
            } else {
                $targetStringId = $treasurer->treasurer_id;
            }

            // 3. Perform an update-or-insert into block_settings
            \DB::table('block_settings')->updateOrInsert(
                ['treasurer_id' => $targetStringId],
                [
                    'block_date' => $formattedDate,
                    'updated_at' => now()
                ]
            );

            // ✅ 4. SEND NOTIFICATIONS TO UNPAID STUDENTS
            $notificationsSent = $this->sendNotificationsToUnpaidStudents($formattedDate);

            return response()->json([
                'success' => true,
                'notifications_sent' => $notificationsSent,
                'message' => 'Block settings updated and notifications sent to ' . $notificationsSent . ' students'
            ], 200);

        } catch (\Exception $e) {
            \Log::error("CRITICAL ERROR IN BLOCK SETTINGS: " . $e->getMessage());
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
 * Get the latest block settings
 */
    public function getLatestBlockSettings()
    {
        try {
            $blockSetting = DB::table('block_settings')
                ->orderBy('created_at', 'desc')
                ->first();

            if ($blockSetting) {
                $blockDate = $blockSetting->block_date ?? $blockSetting->block_start_date;
                return response()->json([
                    'success' => true,
                    'block_date' => $blockDate,
                    'block_id' => $blockSetting->block_id,
                    'treasurer_id' => $blockSetting->treasurer_id,
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'No block settings found'
            ], 404);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Send Payment Reminder & Block Warning to unpaid students
     */
    private function sendNotificationsToUnpaidStudents($blockDate)
    {
        $notificationsSent = 0;
        
        try {
            // Get all students with unpaid fees
            $unpaidStudents = DB::table('fees')
                ->join('students', 'fees.student_id', '=', 'students.student_id')
                ->where('fees.status', 'unpaid')
                ->where('fees.outstanding_amount', '>', 0)
                ->select('students.id as user_id', 'fees.outstanding_amount')
                ->get();

            $formattedBlockDate = Carbon::parse($blockDate)->format('d M Y');
            $now = now();

            foreach ($unpaidStudents as $student) {
                // Check if notifications already sent today
                $existingReminder = DB::table('notifications')
                    ->where('id', $student->user_id)
                    ->where('type', 'payment_reminder')
                    ->whereDate('created_at', Carbon::today())
                    ->first();

                $existingWarning = DB::table('notifications')
                    ->where('id', $student->user_id)
                    ->where('type', 'block_warning')
                    ->whereDate('created_at', Carbon::today())
                    ->first();

                $sentForThisStudent = false;

                // ✅ 1. PAYMENT REMINDER (if not sent today)
                if (!$existingReminder) {
                    DB::table('notifications')->insert([
                        'id' => $student->user_id,
                        'title' => 'Payment Reminder',
                        'message' => 'Your tuition fee payment is due on ' . $formattedBlockDate . '. Please settle your balance of RM ' . number_format($student->outstanding_amount, 2) . '.',
                        'is_read' => 0,
                        'type' => 'payment_reminder',
                        'reference_id' => null,
                        'created_at' => $now,
                        'updated_at' => $now
                    ]);
                    $sentForThisStudent = true;
                }

                // ✅ 2. BLOCK WARNING (if not sent today)
                if (!$existingWarning) {
                    DB::table('notifications')->insert([
                        'id' => $student->user_id,
                        'title' => 'Block Warning',
                        'message' => 'Your academic access will be blocked after Week 5 (' . $formattedBlockDate . ') if your balance of RM ' . number_format($student->outstanding_amount, 2) . ' remains unpaid.',
                        'is_read' => 0,
                        'type' => 'block_warning',
                        'reference_id' => null,
                        'created_at' => $now,
                        'updated_at' => $now
                    ]);
                    $sentForThisStudent = true;
                }

                if ($sentForThisStudent) {
                    $notificationsSent++;
                }
            }

            \Log::info('Notifications sent to ' . $notificationsSent . ' unpaid students');

        } catch (\Exception $e) {
            \Log::error('Failed to send notifications: ' . $e->getMessage());
        }

        return $notificationsSent;
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
                    'fees.paid_amount',      
                    'fees.outstanding_amount'      
                )
                ->where('users.id', $userId)
                ->first();

            if (!$data) {
                return response()->json(['message' => 'Student not found'], 404);
            }

            $totalPayment = (float)($data->paid_amount ?? 0.00);
            $totalInvoice = (float)($data->total_invoice ?? 0.00);
            $outstanding = (float)($data->outstanding_amount ?? 0.00);

            $result = (array)$data;
            $result['total_invoice'] = $totalInvoice;
            $result['total_payment'] = $totalPayment;
            $result['outstanding_amount'] = $outstanding;

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

            // 2. Fetch payments - only Success status
            $history = DB::table('payments')
                ->where('student_id', $matricId)
                ->where('status', 'Success')
                ->select('payment_id', 'payment_desc', 'total_payment', 'payment_date', 'status')
                ->orderBy('payment_date', 'desc')
                ->get();

            return response()->json($history);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * COMPLETE PAYMENT - Creates Payment Success Notification
     */
    public function completePayment(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'amount' => 'required|numeric|min:1',
            'method' => 'required|string'
        ]);

        $student = DB::table('students')->where('id', $request->user_id)->first();
        if (!$student) {
            return response()->json(['error' => 'Student record not found'], 404);
        }

        $fee = DB::table('fees')->where('student_id', $student->student_id)->first();

        DB::beginTransaction();
        try {
            // Generate payment ID
            $currentYear = date('y');
            $currentMonth = date('m');
            $semester = ($currentMonth >= 1 && $currentMonth <= 6) ? '01' : '02';
            $randomNumber = str_pad(rand(1, 99999), 5, '0', STR_PAD_LEFT);
            $paymentId = 'RP' . $currentYear . $semester . '-' . $randomNumber;
            
            // Insert payment
            DB::table('payments')->insert([
                'payment_id' => $paymentId,
                'student_id' => $student->student_id,
                'fee_id' => $fee->fee_id ?? null,
                'total_payment' => $request->amount,
                'payment_desc' => 'Tuition Fee Balance Settlement',
                'payment_method' => $request->method, 
                'status' => 'Success', 
                'payment_date' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ]);

            if ($fee) {
                // Calculate new paid amount
                $newPaidAmount = ($fee->paid_amount ?? 0) + $request->amount;
                
                // Calculate new outstanding = total_invoice - paid_amount
                $newOutstanding = max(0, ($fee->total_invoice ?? 0) - $newPaidAmount);
                
                // Determine status
                $newStatus = $newOutstanding <= 0 ? 'paid' : 'unpaid';

                // Update fees table
                DB::table('fees')->where('student_id', $student->student_id)->update([
                    'paid_amount' => $newPaidAmount,
                    'outstanding_amount' => $newOutstanding,
                    'status' => $newStatus,
                    'updated_at' => now()
                ]);
                
                \Log::info('Fee updated - Total Invoice: ' . $fee->total_invoice . ', New Paid: ' . $newPaidAmount . ', New Outstanding: ' . $newOutstanding);

                // Payment Success Notification
                DB::table('notifications')->insert([
                    'id' => $request->user_id,
                    'title' => 'Payment Success',
                    'message' => 'Your payment of RM ' . number_format($request->amount, 2) . ' has been received.',
                    'is_read' => 0,
                    'type' => 'payment_success',
                    'reference_id' => $paymentId,
                    'created_at' => now(),
                    'updated_at' => now()
                ]);

                // If still has outstanding balance, send reminder
                if ($newOutstanding > 0) {
                    $existingReminder = DB::table('notifications')
                        ->where('id', $request->user_id)
                        ->where('type', 'payment_reminder')
                        ->whereDate('created_at', Carbon::today())
                        ->first();

                    if (!$existingReminder) {
                        DB::table('notifications')->insert([
                            'id' => $request->user_id,
                            'title' => 'Payment Reminder',
                            'message' => 'Your remaining balance is RM ' . number_format($newOutstanding, 2) . '. Please settle before Week 5.',
                            'is_read' => 0,
                            'type' => 'payment_reminder',
                            'reference_id' => null,
                            'created_at' => now(),
                            'updated_at' => now()
                        ]);
                    }
                }
            }

            DB::commit();
            \Log::info('Payment inserted successfully: ' . $paymentId);
            return response()->json(['success' => true, 'message' => 'Balances updated successfully']);

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Payment failed: ' . $e->getMessage());
            return response()->json(['error' => 'Transaction tracking breakdown: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Generate random room details
     */
    private function generateRoomDetails()
    {
        $colleges = ['RESIDEN PELAJAR 5 (PEKAN)', 'DHUAM UNIVERSITY VILLAGE'];
        $college = $colleges[array_rand($colleges)];
        
        if ($college == 'RESIDEN PELAJAR 5 (PEKAN)') {
            $blocks = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
            $block = $blocks[array_rand($blocks)];
            $level = rand(1, 3);
            $house = rand(1, 8);
            $room = str_pad(rand(1, 4), 2, '0', STR_PAD_LEFT);
            
            $roomNumber = $block . $level . '-' . $house . str_pad($room, 2, '0', STR_PAD_LEFT);
            
        } else {
            $blocks = ['A', 'B'];
            $block = $blocks[array_rand($blocks)];
            $level = rand(1, 11);
            $room = rand(1, 30);
            
            $roomNumber = $block . '-' . $level . '-' . $room;
        }
        
        return [
            'college' => $college,
            'room_number' => $roomNumber
        ];
    }

    public function checkBlockStatus($userId)
    {
        // 1. Get the latest block setting criteria from the treasurer
        $blockSetting = DB::table('block_settings')
                        ->orderBy('block_date', 'desc')
                        ->first();

        if (!$blockSetting) {
            return response()->json(['is_blocked' => false]);
        }

        // 2. Check if today's date has reached or passed the deadline restriction
        $today = date('Y-m-d');
        $isPastDeadline = ($today >= $blockSetting->block_date);

        // 🌟 FIX: Find the alphanumeric matric string (student_id) using the incoming numerical User ID
        $matricId = DB::table('students')->where('id', $userId)->value('student_id');

        if (!$matricId) {
            return response()->json([
                'is_blocked' => false,
                'message' => 'Student record matching ID context not found.'
            ]);
        }

        // 3. Look up if this student still has remaining balances using the correct Matric ID string
        $studentFee = DB::table('fees')
                        ->where('student_id', $matricId)
                        ->first();

        // 4. Evaluate true block conditions (Case-insensitive match check for safety)
        $hasUnpaidBalance = $studentFee && ($studentFee->outstanding_amount > 0 || strtolower($studentFee->status) !== 'paid');

        if ($isPastDeadline && $hasUnpaidBalance) {
            return response()->json([
                'is_blocked' => true,
                'message' => 'Your academic access has been blocked due to unpaid tuition fees.'
            ]);
        }

        return response()->json(['is_blocked' => false]);
    }

    public function getFinancialReportTotals(Request $request)
    {
        try {
            // ✅ Get date range from request
            $startDate = $request->query('start_date');
            $endDate = $request->query('end_date');
            
            // Build payment query with date filter
            $paymentQuery = DB::table('payments')->where('status', 'Success');
            
            if ($startDate && $endDate) {
                $paymentQuery->whereBetween('payment_date', [$startDate, $endDate]);
            }
            
            // Calculate total paid from payments within date range
            $totalPaid = $paymentQuery->sum('total_payment');
            
            // Calculate outstanding balance (from fees table - not date dependent)
            $totalOutstanding = DB::table('fees')->sum('outstanding_amount');
            
            // Count blocked students
            $blockedCount = DB::table('students')->where('is_blocked', true)->count();
            
            // Count online banking and card payments within date range
            $onlineBankingCount = DB::table('payments')
                ->where('status', 'Success')
                ->where('payment_method', 'Internet Banking');
                
            $cardCount = DB::table('payments')
                ->where('status', 'Success')
                ->where('payment_method', 'Credit Card/Debit Card');
                
            if ($startDate && $endDate) {
                $onlineBankingCount->whereBetween('payment_date', [$startDate, $endDate]);
                $cardCount->whereBetween('payment_date', [$startDate, $endDate]);
            }
            
            $onlineBankingCount = $onlineBankingCount->count();
            $cardCount = $cardCount->count();

            return response()->json([
                'total_paid' => (float)$totalPaid,
                'total_outstanding' => (float)$totalOutstanding,
                'blocked_count' => $blockedCount,
                'online_banking_count' => $onlineBankingCount,
                'card_payment_count' => $cardCount,
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

    public function generateStripeIntent(Request $request)
    {
        try {
            // Set Accept header for JSON response
            $request->headers->set('Accept', 'application/json');
            
            // Validate input
            $validated = $request->validate([
                'amount' => 'required|numeric|min:0.5',
                'user_id' => 'required|string',
                'method' => 'sometimes|string'
            ]);

            // Get Stripe secret key
            $stripeSecret = config('services.stripe.secret');
            if (empty($stripeSecret)) {
                return response()->json([
                    'success' => false,
                    'error' => 'Stripe secret key is not configured'
                ], 500);
            }

            // Set Stripe API key
            \Stripe\Stripe::setApiKey($stripeSecret);

            // Convert amount to cents
            $amountInCents = intval(round(floatval($validated['amount']) * 100));

            // Determine payment methods based on selection
            $paymentMethods = ['card'];
            if (isset($validated['method']) && $validated['method'] === 'fpx') {
                $paymentMethods = ['fpx'];
            }

            // Create PaymentIntent
            $paymentIntent = \Stripe\PaymentIntent::create([
                'amount' => $amountInCents,
                'currency' => 'myr',
                'payment_method_types' => $paymentMethods,
                'metadata' => [
                    'user_id' => $validated['user_id'],
                    'payment_method' => $validated['method'] ?? 'card'
                ],
            ]);

            return response()->json([
                'success' => true,
                'paymentIntentClientSecret' => $paymentIntent->client_secret,
                'paymentIntentId' => $paymentIntent->id
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'messages' => $e->errors()
            ], 422);
        } catch (\Stripe\Exception\ApiErrorException $e) {
            \Log::error('Stripe API Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'error' => 'Stripe error: ' . $e->getMessage()
            ], 500);
        } catch (\Exception $e) {
            \Log::error('Payment Intent Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'error' => 'Server error: ' . $e->getMessage()
            ], 500);
        }
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

    /**
     * Get all notifications for a specific user
     * Only shows Payment Success, Payment Reminder, and Block Warning for that specific user
     */
    public function getUserNotifications($userId)
    {
        try {
            // Get student's matric ID for this specific user
            $student = DB::table('students')->where('id', $userId)->first();
            if (!$student) {
                return response()->json(['notifications' => []]);
            }

            $matricId = $student->student_id;

            // ✅ Call generateNotifications to create notifications if they don't exist
            $this->generateNotifications($userId, $matricId);

            // ✅ Return ONLY this user's notifications
            $notifications = DB::table('notifications')
                ->where('id', $userId)
                ->orderBy('created_at', 'desc')
                ->get();

            $unreadCount = DB::table('notifications')
                ->where('id', $userId)
                ->where('is_read', 0)
                ->count();

            return response()->json([
                'notifications' => $notifications,
                'unread_count' => $unreadCount
            ]);

        } catch (\Exception $e) {
            \Log::error('Notification Error for user ' . $userId . ': ' . $e->getMessage());
            return response()->json([
                'notifications' => [],
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate notifications dynamically and save to database
     */
    private function generateNotifications($userId, $matricId)
    {
        // 1. Get Payment Success notifications from payments table
        $payments = DB::table('payments')
            ->where('student_id', $matricId)
            ->where('status', 'Success')
            ->orderBy('payment_date', 'desc')
            ->get();

        foreach ($payments as $payment) {
            // ✅ Check by type and reference_id instead
            $existing = DB::table('notifications')
                ->where('id', $userId)
                ->where('type', 'payment_success')
                ->where('reference_id', $payment->payment_id)
                ->first();
            
            if (!$existing) {
                // ✅ REMOVE notification_id - let it auto-increment
                DB::table('notifications')->insert([
                    'id' => $userId,
                    'title' => 'Payment Success',
                    'message' => 'Your payment of RM ' . number_format($payment->total_payment, 2) . ' has been received.',
                    'is_read' => 1,
                    'type' => 'payment_success',
                    'reference_id' => $payment->payment_id,
                    'created_at' => $payment->payment_date ?? now(),
                    'updated_at' => $payment->payment_date ?? now()
                ]);
            }
        }

        // 2. Get Payment Reminder and Block Warning ONLY IF block date is in the future
        $blockSetting = DB::table('block_settings')->orderBy('created_at', 'desc')->first();
        
        if ($blockSetting) {
            $blockDate = $blockSetting->block_date ?? $blockSetting->block_start_date;
            $blockDateParsed = Carbon::parse($blockDate);
            
            if ($blockDateParsed->isFuture()) {
                $formattedBlockDate = $blockDateParsed->format('d F Y');
                
                $fee = DB::table('fees')->where('student_id', $matricId)->first();
                
                if ($fee && $fee->status == 'unpaid' && $fee->outstanding_amount > 0) {
                    // ✅ Payment Reminder - REMOVE notification_id
                    $existingReminder = DB::table('notifications')
                        ->where('id', $userId)
                        ->where('type', 'payment_reminder')
                        ->first();
                    
                    if (!$existingReminder) {
                        DB::table('notifications')->insert([
                            'id' => $userId,
                            'title' => 'Payment Reminder',
                            'message' => 'Your tuition fee payment is due on ' . $formattedBlockDate . '.',
                            'is_read' => 0,
                            'type' => 'payment_reminder',
                            'reference_id' => null,
                            'created_at' => now(),
                            'updated_at' => now()
                        ]);
                    }
                    
                    // ✅ Block Warning - REMOVE notification_id
                    $existingWarning = DB::table('notifications')
                        ->where('id', $userId)
                        ->where('type', 'block_warning')
                        ->first();
                    
                    if (!$existingWarning) {
                        DB::table('notifications')->insert([
                            'id' => $userId,
                            'title' => 'Block Warning',
                            'message' => 'Your academic access will be blocked after Week 5 (' . $formattedBlockDate . ') if your balance remains unpaid.',
                            'is_read' => 0,
                            'type' => 'block_warning',
                            'reference_id' => null,
                            'created_at' => now(),
                            'updated_at' => now()
                        ]);
                    }
                }
            }
        }
    }

    /**
     * Mark a notification as read (update is_read to 1)
     */
    public function markNotificationAsRead(Request $request, $notificationId)
    {
        try {
            $userId = $request->input('user_id') ?? auth()->id();
            
            if (!$userId) {
                return response()->json(['error' => 'User ID required'], 400);
            }

            $updated = DB::table('notifications')
                ->where('notification_id', $notificationId)
                ->where('id', $userId)
                ->update(['is_read' => 1]);

            if ($updated) {
                return response()->json(['success' => true]);
            }

            return response()->json(['error' => 'Notification not found'], 404);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Mark all notifications as read for a user
     */
    public function markAllNotificationsAsRead(Request $request)
    {
        try {
            $userId = $request->input('user_id') ?? auth()->id();
            
            if (!$userId) {
                return response()->json(['error' => 'User ID required'], 400);
            }

            DB::table('notifications')
                ->where('id', $userId)
                ->update(['is_read' => 1]);

            return response()->json(['success' => true]);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
