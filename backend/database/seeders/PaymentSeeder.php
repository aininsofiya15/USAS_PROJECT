<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PaymentSeeder extends Seeder
{
    public function run(): void
    {
        // Fetch fees to see who has paid what
        $fees = DB::table('fees')->get();

        if ($fees->isEmpty()) {
            $this->command->error("No fees found! Seed StudentFeeSeeder first.");
            return;
        }

        foreach ($fees as $index => $fee) {
            // Only create a payment record if the student has actually paid something
            if ($fee->paid_amount > 0) {
                DB::table('payments')->insert([
                    'student_id'    => $fee->student_id,
                    'fee_id'         => $fee->fee_id,
                    'amount'         => $fee->paid_amount,
                    'total_payment'  => $fee->paid_amount, // The new column
                    'payment_method' => ($index % 2 == 0) ? 'Internet Banking' : 'Credit Card',
                    'status'         => 'Success',
                    'payment_date'   => now()->subDays(rand(1, 30)),
                    'created_at'     => now(),
                    'updated_at'     => now(),
                ]);
            }
        }
    }
}