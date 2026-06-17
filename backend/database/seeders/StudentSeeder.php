<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class StudentSeeder extends Seeder
{
    public function run(): void
    {
        Schema::disableForeignKeyConstraints();
        DB::table('students')->truncate();
        Schema::enableForeignKeyConstraints();

        $studentUsers = User::where('role', 'student')->get();
        
        $coursesWithPrefixes = [
            'Faculty of Computing' => [
                'Diploma in Computer Science' => 'DCS',
                'Bachelor of Computer Science (Software Engineering) with Honours' => 'CB',
                'Bachelor of Computer Science (Computer Systems & Networking) with Honours' => 'CA',
                'Bachelor of Computer Science (Multimedia Software) with Honours' => 'CD',
                'Bachelor of Computer Science (Cyber Security) with Honours' => 'CF',
                'Dual Degree Program - Bachelor of Computer Science (Software Engineering) with Honors' => 'DC'
            ],
            'Faculty of Industrial Sciences and Technology' => [
                'Diploma in Occupational Safety And Health' => 'DOS',
                'Bachelor of Occupational Safety & Health With Honours' => 'FOS',
                'Bachelor of Applied Science in Material Technology with Honours' => 'FST',
                'Bachelor of Applied Science in Industrial Biotechnology with Honours' => 'FSB',
                'Bachelor of Applied Science in Industrial Chemistry with Honours' => 'FSC'
            ],
            'Faculty of Chemical and Process Engineering Technology' => [
                'Diploma in Chemical Engineering' => 'DCE',
                'Bachelor of Chemical Engineering with Honours' => 'KC',
                'Bachelor of Chemical Engineering Technology with Hons.' => 'KCT',
                'Bachelor Technology of Oil and Gas Facilities Maintenance with Hons.' => 'KOG',
                'Bachelor of Manufacturing Engineering Technology (Pharmaceutical) with Hons.' => 'KPM',
                'Bachelor of Mechanical Engineering Technology (Petroleum) with Hons.' => 'KPE'
            ],
            'Faculty of Electrical and Electronics Engineering Technology' => [
                'Bachelor of Electrical Engineering Technology (Energy) with Honours' => 'BTE',
                'Bachelor of Electrical Engineering (Electronics) with Honours' => 'BHE',
                'Bachelor of Electrical Engineering Technology (Power & Machine) with Honours' => 'BTW',
                'Bachelor of Electronics Engineering Technology (Computer System) with Honours' => 'BTS',
                'Bachelor of Technology in Electrical Systems Maintenance with Honours' => 'BVE'
            ]
        ];

        foreach ($studentUsers as $index => $user) {
            // ✅ Distribute students across faculties
            if ($index < 15) {
                $facultyName = 'Faculty of Computing';
                $facultyCourses = $coursesWithPrefixes[$facultyName];
                $courseName = array_rand($facultyCourses);
                $coursePrefix = $facultyCourses[$courseName];
            } elseif ($index < 30) {
                $facultyName = 'Faculty of Industrial Sciences and Technology';
                $facultyCourses = $coursesWithPrefixes[$facultyName];
                $courseName = array_rand($facultyCourses);
                $coursePrefix = $facultyCourses[$courseName];
            } elseif ($index < 45) {
                $facultyName = 'Faculty of Chemical and Process Engineering Technology';
                $facultyCourses = $coursesWithPrefixes[$facultyName];
                $courseName = array_rand($facultyCourses);
                $coursePrefix = $facultyCourses[$courseName];
            } else {
                $facultyName = 'Faculty of Electrical and Electronics Engineering Technology';
                $facultyCourses = $coursesWithPrefixes[$facultyName];
                $courseName = array_rand($facultyCourses);
                $coursePrefix = $facultyCourses[$courseName];
            }
            
            // ✅ More students with 25 (2025/2026 session) for recent data
            // 60% of students get 25, 30% get 24, 10% get 23
            $yearRand = rand(1, 100);
            if ($yearRand <= 60) {
                $yearIntake = 25; // Most recent session 2025/2026
            } elseif ($yearRand <= 90) {
                $yearIntake = 24; // 2024/2025 session
            } else {
                $yearIntake = 23; // 2023/2024 session
            }
            
            $matricNo = $coursePrefix . $yearIntake . str_pad($index + 1, 3, '0', STR_PAD_LEFT);
            
            $yearPrefix = '0' . rand(1, 4); 
            $month = str_pad(rand(1, 12), 2, '0', STR_PAD_LEFT);
            $day = str_pad(rand(1, 28), 2, '0', STR_PAD_LEFT);
            $stateCode = str_pad(rand(1, 14), 2, '0', STR_PAD_LEFT);
            $randomDigits = rand(1000, 9999);
            $icNo = $yearPrefix . $month . $day . $stateCode . $randomDigits;

            // ✅ For 25 students, set semester to 1 or 2 (Year 1)
            if ($yearIntake == 25) {
                $currentSemester = rand(1, 2); // Year 1 Semester 1 or 2
            } else {
                $currentSemester = rand(1, 6); // Up to Year 3 for older students
            }
            $calculatedYear = (int) ceil($currentSemester / 2);

            DB::table('students')->insert([
                'id' => $user->id,
                'student_id' => $matricNo,
                'ic_no' => $icNo,
                'faculty' => $facultyName,
                'course_name' => $courseName,
                'program' => $this->determineProgramType($courseName),
                'current_semester' => $currentSemester,
                'year' => $calculatedYear,
                'is_blocked' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    private function determineProgramType($courseName)
    {
        if (str_contains($courseName, 'Diploma')) return 'Diploma';
        if (str_contains($courseName, 'Dual Degree')) return 'International Dual Degree';
        return 'Bachelor Degree';
    }
}