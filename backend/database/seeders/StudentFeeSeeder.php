<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Student;
use App\Models\StudentFee;

class StudentFeeSeeder extends Seeder
{
    public function run()
    {
        $students = Student::all();
        
        foreach ($students as $index => $student) {
            $totalFees = 5000.00;
            $paidAmount = $index < 10 ? $totalFees : ($index < 15 ? 2500.00 : 0);
            $status = $paidAmount >= $totalFees ? 'paid' : 'unpaid';
            
            StudentFee::create([
                'student_id' => $student->student_id,
                'total_fees' => $totalFees,
                'paid_amount' => $paidAmount,
                'status' => $status,
                'block_start_date' => ($index >= 15 && $paidAmount == 0) ? now()->subDays(10) : null
            ]);
        }
    }
}