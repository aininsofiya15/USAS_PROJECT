<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AttendanceRecordSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create the Module
        $moduleId = DB::table('modules')->insertGetId([
            'activity_name' => 'MOBILE PHONE PHOTOGRAPHY',
            'venue' => 'Dewan Serbaguna (Pekan)',
            'created_at' => now(),
        ]);

        // 2. Create a Test Student (Matches your image CB23024)
        $studentId = DB::table('students')->insertGetId([
            'student_id' => 'CA24000',
            'course_name' => 'NUR WAHIDAH SYARINI',
            'faculty' => 'Faculty of Computing',
            'created_at' => now(),
        ]);

        // 3. Create the Booking
        $bookingId = DB::table('bookings')->insertGetId([
            'student_id' => $studentId,
            'module_id' => $moduleId,
            'is_claimed' => 0,
            'created_at' => now(),
        ]);

        // 4. Create the Attendance Session
        $attendanceId = DB::table('attendances')->insertGetId([
            'booking_id' => $bookingId,
            'attendance_code' => 'USA123',
            'date' => '2026-04-24',
            'time' => '08:00:00',
        ]);

        // 5. Create the Record (This is where your marks live!)
        DB::table('attendance_records')->insert([
            'student_id' => $studentId,
            'attendance_id' => $attendanceId,
            'module_id' => $moduleId, // As we discussed adding this earlier
            'marks' => 85, 
            'status' => 'present',
            'created_at' => now(),
        ]);
    }
}