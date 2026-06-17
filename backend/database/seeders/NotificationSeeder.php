<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class NotificationSeeder extends Seeder
{
    public function run()
    {
        // Get all student user IDs
        $students = DB::table('users')->where('role', 'student')->pluck('id');
        
        // Get block date from block_settings
        $blockSetting = DB::table('block_settings')->orderBy('created_at', 'desc')->first();
        $blockDate = $blockSetting->block_date ?? $blockSetting->block_start_date ?? '2026-05-18';
        $blockDateParsed = Carbon::parse($blockDate);
        $formattedBlockDate = $blockDateParsed->format('d F Y');
        $isBlockFuture = $blockDateParsed->isFuture();
        
        // Clear existing notifications
        DB::table('notifications')->truncate();
        
        foreach ($students as $studentId) {
            // Get student's matric ID
            $student = DB::table('students')->where('id', $studentId)->first();
            if (!$student) continue;
            
            $matricId = $student->student_id;
            
            // ✅ 1. Get all payments for this student - Payment Success
            $payments = DB::table('payments')
                ->where('student_id', $matricId)
                ->where('status', 'Success')
                ->orderBy('payment_date', 'asc')
                ->get();
            
            // Payment Success notification for each payment
            foreach ($payments as $payment) {
                $notificationId = 'payment_success_' . $payment->payment_id;
                
                DB::table('notifications')->insert([
                    'notification_id' => $notificationId,
                    'id' => $studentId,
                    'title' => 'Payment Success',
                    'message' => 'Your payment of RM ' . number_format($payment->total_payment, 2) . ' has been received.',
                    'is_read' => 1,
                    'type' => 'payment_success',
                    'reference_id' => $payment->payment_id,
                    'created_at' => $payment->payment_date ?? now(),
                    'updated_at' => $payment->payment_date ?? now()
                ]);
            }
            
            // ✅ 2. Get fee record to check if student has outstanding balance
            $fee = DB::table('fees')->where('student_id', $matricId)->first();
            
            // ✅ 3. Create Payment Reminder and Block Warning ONLY IF:
            //    - block date is in the future
            //    - student has unpaid fees
            if ($isBlockFuture && $fee && $fee->status == 'unpaid' && $fee->outstanding_amount > 0) {
                // Payment Reminder
                DB::table('notifications')->insert([
                    'notification_id' => 'payment_reminder_' . $studentId,
                    'id' => $studentId,
                    'title' => 'Payment Reminder',
                    'message' => 'Your tuition fee payment is due on ' . $formattedBlockDate . '.',
                    'is_read' => 0,
                    'type' => 'payment_reminder',
                    'reference_id' => null,
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                
                // Block Warning
                DB::table('notifications')->insert([
                    'notification_id' => 'block_warning_' . $studentId,
                    'id' => $studentId,
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