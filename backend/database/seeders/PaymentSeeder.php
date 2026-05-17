<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class PaymentSeeder extends Seeder
{
    public function run(): void
    {
        Schema::disableForeignKeyConstraints();
        DB::table('payments')->truncate();
        Schema::enableForeignKeyConstraints();

        $students = DB::table('students')->get();
        $methods = ['Internet Banking', 'Credit Card/Debit Card'];

        foreach ($students as $studentIndex => $student) {
            $fee = DB::table('fees')->where('student_id', $student->student_id)->first();
            
            $currentSem = $student->current_semester ?? 1;
            $program = $student->program ?? 'Bachelor Degree';
            
            // Re-calculate base single semester fee matching StudentFeeSeeder calculation formula
            $baseSemAmount = 3000.00 + ($studentIndex * 150.50);

            // Loop and build sequential structural receipts in ASCENDING order (Sem 1 -> current)
            for ($semLoop = 1; $semLoop <= $currentSem; $semLoop++) {
                $loopYear = (int) ceil($semLoop / 2);
                $academicYearStr = ($loopYear == 1) ? "2024/2025" : "2025/2026";
                
                if ($semLoop == 1) {
                    $desc = "Registration and tuition fees for Year 1 Semester 1 ($program) entry $academicYearStr";
                } else {
                    $desc = "Tuition fees and accommodation amenities payment for Year $loopYear Semester $semLoop entry $academicYearStr";
                }

                // Default to full payment for historical past semesters
                $allocatedAmount = $baseSemAmount;

                // For the current active semester, apply the calculated paid amount from the fees table
                if ($semLoop == $currentSem && $fee) {
                    $allocatedAmount = $fee->paid_amount;
                }

                // Advance dates forward incrementally so Semester 1 is oldest and stays on top
                $paymentDate = now()->subMonths(($currentSem - $semLoop) * 6)->setHour(9)->setMinute(0);

                DB::table('payments')->insert([
                    'payment_id'     => 'RP' . $paymentDate->format('ym') . '-' . str_pad(rand(1, 99999), 5, '0', STR_PAD_LEFT),
                    'student_id'     => $student->student_id,
                    'fee_id'         => $fee->fee_id ?? 1,
                    'amount'         => $allocatedAmount,
                    'payment_desc'   => $desc,
                    'total_payment'  => $allocatedAmount,
                    'payment_method' => $methods[array_rand($methods)],
                    'status'         => 'Success',
                    'payment_date'   => $paymentDate,
                    'created_at'     => $paymentDate,
                    'updated_at'     => now(),
                ]);
            }
        }
    }
}