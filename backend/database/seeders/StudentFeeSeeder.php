<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Student;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StudentFeeSeeder extends Seeder
{
    public function run(): void
    {
        Schema::disableForeignKeyConstraints();
        DB::table('fees')->truncate();
        Schema::enableForeignKeyConstraints();

        $students = Student::all();

        foreach ($students as $index => $student) {
            $currentSem = $student->current_semester ?? 1;
            
            // Calculate a single baseline recurring semester charge rate
            $singleSemesterRate = 3000.00 + ($index * 150.50);
            
            // Cumulative Invoice = single semester charge * number of semesters billed
            $totalInvoice = $singleSemesterRate * $currentSem;
            
            // Outstanding balance applies ONLY to the current active semester block if triggered
            $hasActiveOutstanding = ($index % 3 == 0); 
            $outstanding = $hasActiveOutstanding ? ($singleSemesterRate * 0.4) : 0.00; // 40% of current semester unpaid
            
            // Total Paid matches all historical semesters fully paid + whatever remains of current semester
            $paidAmount = $totalInvoice - $outstanding;

            DB::table('fees')->insert([
                'student_id'         => $student->student_id,
                'total_invoice'      => $totalInvoice,
                'paid_amount'        => $paidAmount,
                'outstanding_amount' => $outstanding,
                'status'             => ($outstanding > 0) ? 'unpaid' : 'paid',
                'created_at'         => now(),
                'updated_at'         => now(),
            ]);
        }
    }
}