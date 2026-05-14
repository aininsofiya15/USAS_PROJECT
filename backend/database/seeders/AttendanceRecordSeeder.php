<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AttendanceRecordSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('attendance_records')->insert([

            [
                'attendance_id' => 1,
                'student_id' => 1,
                'submitted_time' => Carbon::now(),
                'status' => 'Present',
                'marks' => 10.00,
                'grade_category' => 'A',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 1,
                'student_id' => 8,
                'submitted_time' => Carbon::now(),
                'status' => 'Late',
                'marks' => 8.50,
                'grade_category' => 'B',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 1,
                'student_id' => 9,
                'submitted_time' => Carbon::now(),
                'status' => 'Absent',
                'marks' => 0.00,
                'grade_category' => 'F',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 3,
                'student_id' => 10,
                'submitted_time' => Carbon::now(),
                'status' => 'Present',
                'marks' => 9.00,
                'grade_category' => 'A',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 3,
                'student_id' => 11,
                'submitted_time' => Carbon::now(),
                'status' => 'Present',
                'marks' => 7.50,
                'grade_category' => 'B',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 4,
                'student_id' => 12,
                'submitted_time' => Carbon::now(),
                'status' => 'Late',
                'marks' => 6.00,
                'grade_category' => 'C',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 4,
                'student_id' => 13,
                'submitted_time' => Carbon::now(),
                'status' => 'Present',
                'marks' => 10.00,
                'grade_category' => 'A',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 5,
                'student_id' => 14,
                'submitted_time' => Carbon::now(),
                'status' => 'Absent',
                'marks' => 0.00,
                'grade_category' => 'F',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 5,
                'student_id' => 15,
                'submitted_time' => Carbon::now(),
                'status' => 'Present',
                'marks' => 8.00,
                'grade_category' => 'B',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'attendance_id' => 5,
                'student_id' => 16,
                'submitted_time' => Carbon::now(),
                'status' => 'Late',
                'marks' => 5.50,
                'grade_category' => 'C',
                'created_at' => now(),
                'updated_at' => now(),
            ],

        ]);
    }
}