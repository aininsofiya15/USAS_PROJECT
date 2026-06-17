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
            
            // Get base tuition fee based on program
            $baseTuitionFee = $this->getBaseTuitionFee($program, $courseName);
            
            // ✅ Calculate total invoice for all semesters with proper amounts
            $totalInvoice = 0;
            $semesterAmounts = [];
            
            for ($sem = 1; $sem <= $currentSem; $sem++) {
                if ($sem == 1) {
                    // ✅ Registration + Tuition (RM 2,100 - RM 2,800)
                    $semAmount = $this->getRegistrationAmount($baseTuitionFee);
                } else {
                    $isHostel = $this->isHostelStudent($student->student_id, $sem);
                    if ($isHostel) {
                        // ✅ Tuition + Accommodation (RM 1,600 - RM 2,300)
                        $semAmount = $this->getTuitionWithAccommodationAmount($baseTuitionFee);
                    } else {
                        // ✅ Tuition Only (RM 900 - RM 1,700)
                        $semAmount = $this->getTuitionOnlyAmount($baseTuitionFee);
                    }
                }
                $semesterAmounts[$sem] = $semAmount;
                $totalInvoice += $semAmount;
            }
            
            // ✅ Calculate total paid from payments table
            $totalPaid = DB::table('payments')
                ->where('student_id', $student->student_id)
                ->where('status', 'Success')
                ->sum('total_payment');
            
            // ✅ If no payments exist, use default calculation
            if ($totalPaid == 0 || $totalPaid == null) {
                // Some students have outstanding balance (20%)
                $hasOutstanding = ($index % 5 == 0);
                if ($hasOutstanding && $currentSem > 0) {
                    // ✅ Outstanding should be between RM 900 - RM 2,300
                    $lastSemAmount = $semesterAmounts[$currentSem] ?? $baseTuitionFee;
                    $outstanding = $this->getOutstandingAmount($lastSemAmount);
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
                    'total_invoice'      => $totalInvoice,
                    'paid_amount'        => $totalPaid,
                    'outstanding_amount' => $outstanding,
                    'status'             => $status,
                    'created_at'         => now(),
                    'updated_at'         => now(),
                ]
            );
        }
    }
    
    /**
     * ✅ Get Registration + Tuition amount (RM 2,100 - RM 2,800)
     */
    private function getRegistrationAmount($baseFee)
    {
        $multiplier = rand(130, 170) / 100;
        $amount = $baseFee * $multiplier;
        return round($amount / 10) * 10;
    }

    /**
     * ✅ Get Tuition + Accommodation amount (RM 1,600 - RM 2,300)
     */
    private function getTuitionWithAccommodationAmount($baseFee)
    {
        $multiplier = rand(80, 115) / 100;
        $amount = $baseFee * $multiplier;
        return round($amount / 10) * 10;
    }

    /**
     * ✅ Get Tuition Only amount (RM 900 - RM 1,700)
     */
    private function getTuitionOnlyAmount($baseFee)
    {
        $multiplier = rand(45, 85) / 100;
        $amount = $baseFee * $multiplier;
        return round($amount / 10) * 10;
    }

    /**
     * ✅ Get Outstanding amount (RM 900 - RM 2,300)
     */
    private function getOutstandingAmount($lastSemAmount)
    {
        // If last semester amount is high, outstanding is between 1,600 - 2,300
        // If last semester amount is low, outstanding is between 900 - 1,700
        if ($lastSemAmount >= 2000) {
            $amount = rand(1600, 2300);
        } else {
            $amount = rand(900, 1700);
        }
        return round($amount / 10) * 10;
    }

    /**
     * Get base tuition fee based on program type
     */
    private function getBaseTuitionFee($program, $courseName)
    {
        $fees = [
            'Diploma' => 1500,
            'Bachelor Degree' => 2000,
            'International Dual Degree' => 3500,
        ];
        
        $baseFee = $fees[$program] ?? 2000;
        
        if (str_contains($courseName, 'Engineering')) {
            $baseFee = round($baseFee * 1.15);
        } elseif (str_contains($courseName, 'Computer Science') || str_contains($courseName, 'Cyber Security')) {
            $baseFee = round($baseFee * 1.10);
        }
        
        return round($baseFee / 10) * 10;
    }
    
    /**
     * Determine if student stays in hostel based on student ID and semester
     */
    private function isHostelStudent($studentId, $semester)
    {
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
}