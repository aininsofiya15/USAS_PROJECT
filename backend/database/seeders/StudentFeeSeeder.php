<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Student;
use Illuminate\Support\Facades\DB;

class StudentFeeSeeder extends Seeder
{
    public function run(): void
    {
        // Get all student profiles we just created
        $students = Student::all();

        foreach ($students as $index => $student) {
            $total = 3000.00;
            // Every 3rd student has an outstanding balance
            $isPaid = ($index % 3 != 0); 
            $outstanding = $isPaid ? 0.00 : 1200.00;
            $paid = $total - $outstanding;

            DB::table('fees')->updateOrInsert(
                ['student_id' => $student->id], // Links fees.student_id to students.id (and users.id)
                [
                    'total_fee' => $total,
                    'paid_amount' => $paid,
                    'outstanding_amount' => $outstanding,
                    'status' => ($outstanding > 0) ? 'unpaid' : 'paid',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}