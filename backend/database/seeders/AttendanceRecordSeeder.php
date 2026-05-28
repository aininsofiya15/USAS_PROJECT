<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;

class AttendanceRecordSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Ensure Module ID = 2 exists (ASAS MEMANAH)
        DB::table('modules')->updateOrInsert(
            ['id' => 2],
            [
                'activity_name' => 'ASAS MEMANAH',
                'date_time' => '2026-05-20 08:00:00',
                'venue' => 'Padang Ragbi Pekan',
                'lecturer_name' => 'Sir Fahmi',
                'capacity' => 15,
                'current_registration' => 20,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]
        );

        // 2. Safe cleanup of old data using delete() to fully clear rows safely
        Schema::disableForeignKeyConstraints();
        DB::table('attendance_records')->delete();
        DB::table('attendances')->delete();
        DB::table('module_attendances')->delete();
        DB::table('bookings')->delete();
        Schema::enableForeignKeyConstraints();

        // 3. Insert Bookings dynamically and capture their auto-generated IDs!
        // (Links Module 2 to real students: Sharmila [1], Aqilah [8], Dilla [9])
        $bookingId1 = DB::table('bookings')->insertGetId([
            'student_id' => 1, 'module_id' => 2, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
        ]);
        $bookingId2 = DB::table('bookings')->insertGetId([
            'student_id' => 8, 'module_id' => 2, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
        ]);
        $bookingId3 = DB::table('bookings')->insertGetId([
            'student_id' => 9, 'module_id' => 2, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
        ]);

        // 4. Link captured booking IDs to the module attendance bridge table
        DB::table('module_attendances')->insert([
            ['booking_id' => $bookingId1, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            ['booking_id' => $bookingId2, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            ['booking_id' => $bookingId3, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
        ]);

        // 5. Setup the parent Attendance sheets using the captured booking IDs
        $attendanceId1 = DB::table('attendances')->insertGetId([
            'booking_id' => $bookingId1, 'section_id' => 1, 'attendance_code' => 'ARCH1', 
            'geo_lat' => 3.54, 'geo_long' => 103.43, 'date' => '2026-05-20', 'time' => '08:00:00', 
            'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
        ]);
        $attendanceId2 = DB::table('attendances')->insertGetId([
            'booking_id' => $bookingId2, 'section_id' => 1, 'attendance_code' => 'ARCH2', 
            'geo_lat' => 3.54, 'geo_long' => 103.43, 'date' => '2026-05-20', 'time' => '08:00:00', 
            'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
        ]);
        $attendanceId3 = DB::table('attendances')->insertGetId([
            'booking_id' => $bookingId3, 'section_id' => 1, 'attendance_code' => 'ARCH3', 
            'geo_lat' => 3.54, 'geo_long' => 103.43, 'date' => '2026-05-20', 'time' => '08:00:00', 
            'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
        ]);

        // 6. Inject the matching final check-in records using the generated attendance IDs and matrix numbers
        // ==========================================
        //  6. FIXED CHECK-IN ROWS USING NUMERIC STUDENT IDs
        // ==========================================
        DB::table('attendance_records')->insert([
            [
                'attendance_id' => $attendanceId1, 
                'student_id' => 1, // ◄ Changed from 'CA24000' to 1 (Sharmila)
                'status' => 'Present', 
                'submitted_time' => Carbon::now(), 
                'created_at' => Carbon::now(), 
                'updated_at' => Carbon::now()
            ],
            [
                'attendance_id' => $attendanceId2, 
                'student_id' => 8, // ◄ Changed from 'CF24001' to 8 (Aqilah)
                'status' => 'Present', 
                'submitted_time' => Carbon::now(), 
                'created_at' => Carbon::now(), 
                'updated_at' => Carbon::now()
            ],
            [
                'attendance_id' => $attendanceId3, 
                'student_id' => 9, // ◄ Changed from 'CA24002' to 9 (Dilla)
                'status' => 'Absent', 
                'submitted_time' => Carbon::now(), 
                'created_at' => Carbon::now(), 
                'updated_at' => Carbon::now()
            ],
        ]);

        $this->command->info('Test records generated under AttendanceRecordSeeder dynamically and successfully!');
    }
}