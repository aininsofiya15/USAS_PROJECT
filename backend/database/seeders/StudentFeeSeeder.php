<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Student;
use Illuminate\Support\Facades\DB;

class StudentFeeSeeder extends Seeder
{
    public function run(): void
    {
        $students = Student::all();

        foreach ($students as $index => $student) {
            // Generate varied invoice amounts between 3000 and 5000
            $totalInvoice = 3000.00 + ($index * 150.50);
            
            // Every 3rd student has an outstanding balance
            $isPaid = ($index % 3 != 0); 
            $outstanding = $isPaid ? 0.00 : ($totalInvoice * 0.4); // 40% remains unpaid
            $paidAmount = $totalInvoice - $outstanding;

            DB::table('fees')->updateOrInsert(
                ['student_id' => $student->student_id], // Use Matric No (e.g., CA24030)
                [
                    'total_invoice' => $totalInvoice,
                    'paid_amount' => $paidAmount,
                    'outstanding_amount' => $outstanding,
                    'status' => ($outstanding > 0) ? 'unpaid' : 'paid',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}