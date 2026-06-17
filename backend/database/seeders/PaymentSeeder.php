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
        $statuses = ['Success', 'Success', 'Success', 'Success', 'Failed']; // 80% Success, 20% Failed

        foreach ($students as $student) {
            $fee = DB::table('fees')->where('student_id', $student->student_id)->first();
            
            $currentSem = $student->current_semester ?? 1;
            $program = $student->program ?? 'Bachelor Degree';
            $courseName = $student->course_name ?? 'Bachelor Degree';
            
            // Determine base tuition fee based on program type
            $baseTuitionFee = $this->getBaseTuitionFee($program, $courseName);
            
            // Get student's intake year from matric number (e.g., CB23027 -> 23, BTE23029 -> 23)
            preg_match('/\d{2}/', $student->student_id, $matches);
            $intakeYear = isset($matches[0]) ? (int) $matches[0] : 23;
            
            // For each semester, create one payment record
            for ($semLoop = 1; $semLoop <= $currentSem; $semLoop++) {
                $loopYear = (int) ceil($semLoop / 2);
                $semesterNum = ($semLoop % 2 == 0) ? 2 : 1;
                
                // Determine academic year based on student's intake year
                $academicYearStart = $intakeYear + $loopYear - 1;
                $academicYearStr = $academicYearStart . '/' . ($academicYearStart + 1);
                
                // Determine payment amount and description based on semester
                if ($semLoop == 1) {
                    // First semester - Registration + Tuition Fees (most expensive)
                    $amount = $baseTuitionFee * 1.3;
                    $desc = "Registration and Tuition Fees for Year 1 Semester 1 (" . $program . ") Entry " . $academicYearStr;
                } else {
                    // For Year 2 and above, randomly choose between hostel or rental house
                    $isHostel = $this->isHostelStudent($student->student_id, $semLoop);
                    
                    if ($isHostel) {
                        // Stay in hostel (with accommodation fees)
                        $accommodationFee = $this->getAccommodationFee($student->student_id, $semLoop);
                        $amount = $baseTuitionFee + $accommodationFee;
                        $roomDetails = $this->generateRoomDetails();
                        $desc = "Tuition Fees and Accommodation Amenities Payment for Year " . $loopYear . 
                                " Semester " . $semesterNum . " " . $academicYearStr . 
                                " (" . $roomDetails['room_number'] . " - " . $roomDetails['college'] . ")";
                    } else {
                        // Rental house (tuition fees only)
                        $amount = $baseTuitionFee;
                        $desc = $program . " Tuition Fees for Year " . $loopYear . 
                                " Semester " . $semesterNum . " " . $academicYearStr;
                    }
                }

                // Generate payment ID in format: RP2301-09788
                $paymentYearShort = $intakeYear;
                $semesterPadded = str_pad($semLoop, 2, '0', STR_PAD_LEFT);
                $randomNumber = str_pad(rand(1, 99999), 5, '0', STR_PAD_LEFT);
                $paymentId = 'RP' . $paymentYearShort . $semesterPadded . '-' . $randomNumber;

                // Randomly assign status (80% Success, 20% Failed)
                $status = $statuses[array_rand($statuses)];
                
                // If status is Failed, set amount to 0 (or partial payment)
                if ($status == 'Failed') {
                    $amount = rand(0, 1) == 0 ? 0 : round($amount * 0.5, 2);
                }

                // Payment date - older semesters have older dates (6 months apart)
                $paymentDate = now()->subMonths(($currentSem - $semLoop) * 6)->setHour(9)->setMinute(0)->setSecond(0);

                DB::table('payments')->insert([
                    'payment_id'     => $paymentId,
                    'student_id'     => $student->student_id,
                    'fee_id'         => $fee->fee_id ?? 1,
                    'total_payment'  => round($amount, 2),
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
     * Get base tuition fee based on program type
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