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
        // 1. Ensure all 4 current modules seen in the database image exist with exact details
        $modules = [
            [
                'id' => 2,
                'activity_name' => 'ASAS MEMANAH',
                'date_time' => '2026-05-20 08:00:00',
                'venue' => 'Padang Ragbi Pekan',
                'lecturer_name' => 'Sir Fahmi',
                'capacity' => 15,
                'current_registration' => 3,
                'status' => 'published',
            ],
            [
                'id' => 3,
                'activity_name' => 'MOBILE PHONE PHOTOGRAPHY',
                'date_time' => '2026-06-01 09:00:00',
                'venue' => 'Dewan Serbaguna',
                'lecturer_name' => 'Madam Siti',
                'capacity' => 30,
                'current_registration' => 1,
                'status' => 'published',
            ],
            [
                'id' => 4,
                'activity_name' => 'BASIC ARDUINO',
                'date_time' => '2026-06-05 14:00:00',
                'venue' => 'Computer Faculty Lab 1',
                'lecturer_name' => 'Dr. Ahmad',
                'capacity' => 25,
                'current_registration' => 1,
                'status' => 'published',
            ],
            [
                'id' => 5,
                'activity_name' => 'PUBLIC SPEAKING 101',
                'date_time' => '2026-06-10 10:00:00',
                'venue' => 'DKP 4',
                'lecturer_name' => 'Madam Lee',
                'capacity' => 40,
                'current_registration' => 1,
                'status' => 'published',
            ],
        ];

        foreach ($modules as $mod) {
            DB::table('modules')->updateOrInsert(['id' => $mod['id']], array_merge($mod, [
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]));
        }

        // 2. Safe cleanup of old tracking links using delete()
        Schema::disableForeignKeyConstraints();
        DB::table('attendance_records')->delete();
        DB::table('attendances')->delete();
        DB::table('module_attendances')->delete();
        DB::table('bookings')->delete();
        Schema::enableForeignKeyConstraints();

// ── 1. BOOKINGS SEEDING MATRIX FOR USER ID 9 (Dilla) ──
        // 🎯 TARGET A: Kayaking Adventure (Unclaimed, has marks, present -> Shows active Green "Claim Module" Button)
        $b0 = DB::table('bookings')->insertGetId(['student_id' => 9, 'module_id' => 1, 'is_claimed' => 0, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        
        // Target B: Asas Memanah (Absent)
        $b3 = DB::table('bookings')->insertGetId(['student_id' => 9, 'module_id' => 2, 'is_claimed' => 0, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        
        // Target C: Mobile Phone Photography (Already Claimed)
        $b4 = DB::table('bookings')->insertGetId(['student_id' => 9, 'module_id' => 3, 'is_claimed' => 1, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        
        // Target D: Basic Arduino (Already Claimed)
        $b5 = DB::table('bookings')->insertGetId(['student_id' => 9, 'module_id' => 4, 'is_claimed' => 1, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        
        // Target E: Public Speaking 101 (Already Claimed)
        $b6 = DB::table('bookings')->insertGetId(['student_id' => 9, 'module_id' => 5, 'is_claimed' => 1, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);

        // ── 2. SEED OTHER TEST STUDENTS AS PLACEHOLDERS ──
        $b1 = DB::table('bookings')->insertGetId(['student_id' => 1, 'module_id' => 2, 'is_claimed' => 0, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $b2 = DB::table('bookings')->insertGetId(['student_id' => 8, 'module_id' => 2, 'is_claimed' => 0, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);

        // ── 3. BRIDGE TABLE LINKS (module_attendances) ──
        $allBookingIds = [$b0, $b1, $b2, $b3, $b4, $b5, $b6];
        foreach ($allBookingIds as $bid) {
            DB::table('module_attendances')->insert([
                'booking_id' => $bid, 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()
            ]);
        }

        // ── 4. SHEET SHEET PARENTS (attendances) ──
        $attId0 = DB::table('attendances')->insertGetId(['booking_id' => $b0, 'section_id' => 1, 'attendance_code' => 'KAYAK1', 'date' => '2026-05-18', 'time' => '08:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $attId1 = DB::table('attendances')->insertGetId(['booking_id' => $b1, 'section_id' => 1, 'attendance_code' => 'ARCH1', 'date' => '2026-05-20', 'time' => '08:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $attId2 = DB::table('attendances')->insertGetId(['booking_id' => $b2, 'section_id' => 1, 'attendance_code' => 'ARCH2', 'date' => '2026-05-20', 'time' => '08:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $attId3 = DB::table('attendances')->insertGetId(['booking_id' => $b3, 'section_id' => 1, 'attendance_code' => 'ARCH3', 'date' => '2026-05-20', 'time' => '08:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $attId4 = DB::table('attendances')->insertGetId(['booking_id' => $b4, 'section_id' => 1, 'attendance_code' => 'PHOTO1', 'date' => '2026-06-01', 'time' => '09:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $attId5 = DB::table('attendances')->insertGetId(['booking_id' => $b5, 'section_id' => 1, 'attendance_code' => 'ARDU1', 'date' => '2026-06-05', 'time' => '14:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);
        $attId6 = DB::table('attendances')->insertGetId(['booking_id' => $b6, 'section_id' => 1, 'attendance_code' => 'SPEAK1', 'date' => '2026-06-10', 'time' => '10:00:00', 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()]);

        // ── 5. PERFORMANCE METRICS (attendance_records) ──
        DB::table('attendance_records')->insert([
            // 🎯 KAYAKING ADVENTURE: Present with 85% marks, ready to claim!
            ['attendance_id' => $attId0, 'student_id' => 9, 'status' => 'Present', 'marks' => 85.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            
            // Other Students
            ['attendance_id' => $attId1, 'student_id' => 1, 'status' => 'Present', 'marks' => 90.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            ['attendance_id' => $attId2, 'student_id' => 8, 'status' => 'Present', 'marks' => 85.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            
            // Asas Memanah (Absent)
            ['attendance_id' => $attId3, 'student_id' => 9, 'status' => 'Absent', 'marks' => 0.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            // Mobile Phone Photography (Present, 60%)
            ['attendance_id' => $attId4, 'student_id' => 9, 'status' => 'Present', 'marks' => 60.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            // Basic Arduino (Present, 100%)
            ['attendance_id' => $attId5, 'student_id' => 9, 'status' => 'Present', 'marks' => 100.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
            // Public Speaking 101 (Present, 95%)
            ['attendance_id' => $attId6, 'student_id' => 9, 'status' => 'Present', 'marks' => 95.0, 'submitted_time' => Carbon::now(), 'created_at' => Carbon::now(), 'updated_at' => Carbon::now()],
        ]);
        
        $this->command->info('USAS Curriculum Master Testing Matrix Seeded Cleanly!');
    }
}