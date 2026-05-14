<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PaymentSeeder extends Seeder
{
    public function run(): void
    {
        // Use TRUNCATE to completely clear the table before seeding
        // This ensures old integer IDs are wiped out
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('payments')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $fees = DB::table('fees')->get();

        if ($fees->isEmpty()) {
            $this->command->error("No fees found! Seed StudentFeeSeeder first.");
            return;
        }

        $methods = ['Internet Banking', 'Credit Card/Debit Card'];

        foreach ($fees as $fee) {
            // Fetch student to get their program
            $student = DB::table('students')->where('student_id', $fee->student_id)->first();

            if ($student && $fee->paid_amount > 0) {
                $program = $student->program ?? 'Unknown Program';
                
                // Logic to pick one of your 3 specific description types
                $type = rand(1, 3);
                $desc = "";

                if ($type == 1) {
                    $desc = "Registration and tuition fees for semester 1 $program entry 2024/2025";
                } elseif ($type == 2) {
                    $desc = "$program tuition fees and dormitory fees for semester 2 entry 2024/2025";
                } else {
                    $desc = "$program tuition fees and dormitory fees for semester 1 entry 2025/2026";
                }

                DB::table('payments')->insert([
                    'payment_id'     => 'RP' . date('ym') . '-' . str_pad(rand(1, 99999), 5, '0', STR_PAD_LEFT),
                    'student_id'     => $fee->student_id,
                    'fee_id'         => $fee->fee_id,
                    'amount'         => $fee->paid_amount,
                    'payment_desc'   => $desc,
                    'total_payment'  => $fee->paid_amount,
                    'payment_method' => $methods[array_rand($methods)],
                    'status'         => 'Success',
                    'payment_date'   => now(),
                    'created_at'     => now(),
                    'updated_at'     => now(),
                ]);
            }
        }
    }
}