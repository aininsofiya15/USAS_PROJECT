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
        $statuses = ['Success', 'Success', 'Success', 'Success', 'Failed'];

        foreach ($students as $student) {
            $fee = DB::table('fees')->where('student_id', $student->student_id)->first();
            
            $currentSem = $student->current_semester ?? 1;
            $program = $student->program ?? 'Bachelor Degree';
            $courseName = $student->course_name ?? 'Bachelor Degree';
            
            $baseTuitionFee = $this->getBaseTuitionFee($program, $courseName);
            
            preg_match('/\d{2}/', $student->student_id, $matches);
            $intakeYear = isset($matches[0]) ? (int) $matches[0] : 23;
            
            // Determine if student has outstanding balance (20% of students)
            $hasOutstanding = ($student->id % 5 == 0);
            
            // Calculate total semesters to create payments for
            $totalSemestersToCreate = $hasOutstanding ? ($currentSem - 1) : $currentSem;
            
            if ($totalSemestersToCreate < 1) {
                continue;
            }
            
            for ($semLoop = 1; $semLoop <= $totalSemestersToCreate; $semLoop++) {
                $loopYear = (int) ceil($semLoop / 2);
                $semesterNum = ($semLoop % 2 == 0) ? 2 : 1;
                
                $academicYearStart = $intakeYear + $loopYear - 1;
                $academicYearStr = $academicYearStart . '/' . ($academicYearStart + 1);
                
                if ($semLoop == 1) {
                    // ✅ Semester 1: Registration + Tuition (RM 2,100 - RM 2,800)
                    $amount = $this->getRegistrationAmount($baseTuitionFee);
                    $desc = "Registration and Tuition Fees for Year 1 Semester 1 (" . $program . ") Entry " . $academicYearStr;
                } else {
                    $isHostel = $this->isHostelStudent($student->student_id, $semLoop);
                    
                    if ($isHostel) {
                        // ✅ Tuition + Accommodation (RM 1,600 - RM 2,300)
                        $amount = $this->getTuitionWithAccommodationAmount($baseTuitionFee);
                        $roomDetails = $this->generateRoomDetails();
                        $desc = "Tuition Fees and Accommodation Amenities Payment for Year " . $loopYear . 
                                " Semester " . $semesterNum . " " . $academicYearStr . 
                                " (" . $roomDetails['room_number'] . " - " . $roomDetails['college'] . ")";
                    } else {
                        // ✅ Tuition Only (RM 900 - RM 1,700)
                        $amount = $this->getTuitionOnlyAmount($baseTuitionFee);
                        $desc = $program . " Tuition Fees for Year " . $loopYear . 
                                " Semester " . $semesterNum . " " . $academicYearStr;
                    }
                }

                $paymentYearShort = $intakeYear;
                $semesterPadded = str_pad($semLoop, 2, '0', STR_PAD_LEFT);
                $randomNumber = str_pad(rand(1, 99999), 5, '0', STR_PAD_LEFT);
                $paymentId = 'RP' . $paymentYearShort . $semesterPadded . '-' . $randomNumber;

                $status = $statuses[array_rand($statuses)];
                
                if ($status == 'Failed') {
                    $amount = rand(0, 1) == 0 ? 0 : round($amount * 0.5);
                }

                $paymentDate = now()->subMonths(($currentSem - $semLoop) * 6)->setHour(9)->setMinute(0)->setSecond(0);

                DB::table('payments')->insert([
                    'payment_id'     => $paymentId,
                    'student_id'     => $student->student_id,
                    'fee_id'         => $fee->fee_id ?? 1,
                    'total_payment'  => $amount,
                    'payment_desc'   => $desc,
                    'payment_method' => $methods[array_rand($methods)],
                    'status'         => $status,
                    'payment_date'   => $paymentDate,
                    'created_at'     => $paymentDate,
                    'updated_at'     => now(),
                ]);
            }
        }
    }

    /**
     * ✅ Get Registration + Tuition amount (RM 2,100 - RM 2,800)
     */
    private function getRegistrationAmount($baseFee)
    {
        $multiplier = rand(130, 170) / 100; // 1.30 - 1.70
        $amount = $baseFee * $multiplier;
        // Round to nearest 10
        return round($amount / 10) * 10;
    }

    /**
     * ✅ Get Tuition + Accommodation amount (RM 1,600 - RM 2,300)
     */
    private function getTuitionWithAccommodationAmount($baseFee)
    {
        $multiplier = rand(80, 115) / 100; // 0.80 - 1.15
        $amount = $baseFee * $multiplier;
        // Round to nearest 10
        return round($amount / 10) * 10;
    }

    /**
     * ✅ Get Tuition Only amount (RM 900 - RM 1,700)
     */
    private function getTuitionOnlyAmount($baseFee)
    {
        $multiplier = rand(45, 85) / 100; // 0.45 - 0.85
        $amount = $baseFee * $multiplier;
        // Round to nearest 10
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
        
        // Round to nearest 10
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
     * Get accommodation fee based on random college assignment
     */
    private function getAccommodationFee($studentId, $semester = 1)
    {
        $isHostel = $this->isHostelStudent($studentId, $semester);
        
        if ($isHostel) {
            $colleges = ['RESIDEN PELAJAR 5 (PEKAN)', 'DHUAM UNIVERSITY VILLAGE'];
            $college = $colleges[array_rand($colleges)];
            
            if ($college == 'RESIDEN PELAJAR 5 (PEKAN)') {
                return rand(450, 600);
            } else {
                return rand(600, 800);
            }
        } else {
            return rand(250, 400);
        }
    }

    /**
     * Generate random room details
     */
    private function generateRoomDetails()
    {
        $colleges = ['RESIDEN PELAJAR 5 (PEKAN)', 'DHUAM UNIVERSITY VILLAGE'];
        $college = $colleges[array_rand($colleges)];
        
        if ($college == 'RESIDEN PELAJAR 5 (PEKAN)') {
            $blocks = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
            $block = $blocks[array_rand($blocks)];
            $level = rand(1, 3);
            $house = rand(1, 8);
            $room = str_pad(rand(1, 4), 2, '0', STR_PAD_LEFT);
            
            $roomNumber = $block . $level . '-' . $house . str_pad($room, 2, '0', STR_PAD_LEFT);
            
        } else {
            $blocks = ['A', 'B'];
            $block = $blocks[array_rand($blocks)];
            $level = rand(1, 11);
            $room = rand(1, 30);
            
            $roomNumber = $block . '-' . $level . '-' . $room;
        }
        
        return [
            'college' => $college,
            'room_number' => $roomNumber
        ];
    }
}