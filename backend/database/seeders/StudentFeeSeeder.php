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
            $program = $student->program ?? 'Bachelor Degree';
            $courseName = $student->course_name ?? 'Bachelor Degree';
            
            // Get base tuition fee based on program (same as PaymentSeeder)
            $baseTuitionFee = $this->getBaseTuitionFee($program, $courseName);
            
            // Calculate total invoice for all semesters (same logic as PaymentSeeder)
            $totalInvoice = 0;
            
            for ($sem = 1; $sem <= $currentSem; $sem++) {
                if ($sem == 1) {
                    // Semester 1: Registration + Tuition (30% extra)
                    $semAmount = $baseTuitionFee * 1.3;
                } else {
                    // Subsequent semesters: Base tuition + accommodation (if applicable)
                    $isHostel = $this->isHostelStudent($student->student_id, $sem);
                    
                    if ($isHostel) {
                        $accommodation = $this->getAccommodationFee($student->student_id, $sem);
                        $semAmount = $baseTuitionFee + $accommodation;
                    } else {
                        $semAmount = $baseTuitionFee;
                    }
                }
                $totalInvoice += $semAmount;
            }
            
            // Calculate total paid from payments table (actual payments)
            $totalPaid = DB::table('payments')
                ->where('student_id', $student->student_id)
                ->where('status', 'Success')
                ->sum('total_payment');
            
            // If no payments exist yet, use the calculated amount
            if ($totalPaid == 0 || $totalPaid == null) {
                // Some students have outstanding balance (20%)
                $hasOutstanding = ($index % 5 == 0);
                if ($hasOutstanding && $currentSem > 0) {
                    // Outstanding is 40% of the last semester's amount
                    $lastSemAmount = $this->getLastSemesterAmount($baseTuitionFee, $student->student_id);
                    $outstanding = round($lastSemAmount * 0.4, 2);
                    $totalPaid = $totalInvoice - $outstanding;
                } else {
                    $totalPaid = $totalInvoice;
                }
            }
            
            $outstanding = max(0, $totalInvoice - $totalPaid);
            $status = ($outstanding > 0) ? 'unpaid' : 'paid';

            DB::table('fees')->updateOrInsert(
                ['student_id' => $student->student_id],
                [
                    'total_invoice'      => round($totalInvoice, 2),
                    'paid_amount'        => round($totalPaid, 2),
                    'outstanding_amount' => round($outstanding, 2),
                    'status'             => $status,
                    'created_at'         => now(),
                    'updated_at'         => now(),
                ]
            );
        }
    }
    
    /**
     * Get base tuition fee based on program type (same as PaymentSeeder)
     */
    private function getBaseTuitionFee($program, $courseName)
    {
        $fees = [
            'Diploma' => 1500.00,
            'Bachelor Degree' => 2000.00,
            'International Dual Degree' => 3500.00,
        ];
        
        $baseFee = $fees[$program] ?? 2000.00;
        
        if (str_contains($courseName, 'Engineering')) {
            $baseFee *= 1.15;
        } elseif (str_contains($courseName, 'Computer Science') || str_contains($courseName, 'Cyber Security')) {
            $baseFee *= 1.10;
        }
        
        return round($baseFee, 2);
    }
    
    /**
     * Determine if student stays in hostel based on student ID and semester
     */
    private function isHostelStudent($studentId, $semester)
    {
        // Use a consistent seed based on student ID and semester
        $seed = crc32($studentId . $semester);
        srand($seed);
        return (rand(0, 100) < 60);
    }
    
    /**
     * Get accommodation fee (same as PaymentSeeder)
     */
    private function getAccommodationFee($studentId, $semester = 1)
    {
        $isHostel = $this->isHostelStudent($studentId, $semester);
        
        if ($isHostel) {
            $colleges = ['RESIDEN PELAJAR 5 (PEKANI)', 'DHUAM UNIVERSITY VILLAGE'];
            $college = $colleges[array_rand($colleges)];
            
            if ($college == 'RESIDEN PELAJAR 5 (PEKANI)') {
                return rand(450, 600);
            } else {
                return rand(600, 800);
            }
        } else {
            return rand(250, 400);
        }
    }
    
    /**
     * Get last semester amount for outstanding calculation
     */
    private function getLastSemesterAmount($baseTuitionFee, $studentId)
    {
        $isHostel = $this->isHostelStudent($studentId, 999); // Use a high number for last semester
        if ($isHostel) {
            $accommodation = $this->getAccommodationFee($studentId, 999);
            return $baseTuitionFee + $accommodation;
        }
        return $baseTuitionFee;
    }
}