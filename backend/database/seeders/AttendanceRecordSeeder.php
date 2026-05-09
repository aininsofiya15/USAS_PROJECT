<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AttendanceRecordSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Link Student ID 1 to Kayaking (Module ID 1)
        DB::table('attendance_records')->insert([
            'attendance_id'  => 1, // Reference to modules.id
            'student_id'     => 1, // Reference to students.id (bigint)
            'submitted_time' => now(),
            'status'         => 'present', // Filter used in image_0ff598.png
            'marks'          => 85.50,
            'created_at'     => now(),
            'updated_at'     => now(),
        ]);

        // Link Student ID 2 to Kayaking (Module ID 1)
        DB::table('attendance_records')->insert([
            'attendance_id'  => 1,
            'student_id'     => 2,
            'submitted_time' => now(),
            'status'         => 'present',
            'marks'          => 0.00,
            'created_at'     => now(),
            'updated_at'     => now(),
        ]);
    }
}