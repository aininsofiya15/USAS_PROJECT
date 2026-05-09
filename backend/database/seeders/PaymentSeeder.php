<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PaymentSeeder extends Seeder
{
    public function run(): void
    {
        // Fetch existing fees
        $fees = DB::table('fees')->get();

        if ($fees->isEmpty()) {
            $this->command->error("No fees found! Please seed the Fees table first with valid student_ids.");
            return;
        }

        foreach ($fees as $fee) {
            // Verify if this student_id actually exists in the students table
            $studentExists = DB::table('students')->where('student_id', $fee->student_id)->exists();

            if ($studentExists) {
                DB::table('payments')->insert([
                    'student_id'     => $fee->student_id,
                    'fee_id'         => $fee->fee_id,
                    'amount'         => 7500.00,
                    'payment_method' => 'Internet Banking',
                    'status'         => 'Success',
                    'payment_date'   => now(),
                    'created_at'     => now(),
                    'updated_at'     => now(),
                ]);
            } else {
                $this->command->warn("Skipping Fee ID {$fee->fee_id}: Student ID '{$fee->student_id}' not found in students table.");
            }
        }
    }
}