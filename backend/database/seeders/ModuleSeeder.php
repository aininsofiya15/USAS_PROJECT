<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ModuleSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('modules')->insert([
            [
                'activity_name' => 'KAYAKING ADVENTURE',
                'date_time' => '2026-05-18 08:00:00',
                'capacity' => 20,
                'current_registration' => 5, // Testing logic with existing students
                'venue' => 'Tasik Pekan',
                'lecturer_name' => 'Sir Fahmi',
                'status' => 'published',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'activity_name' => 'ASAS MEMANAH',
                'date_time' => '2026-05-20 08:00:00',
                'capacity' => 15,
                'current_registration' => 15, // Testing "Full" capacity logic
                'venue' => 'Padang Ragbi Pekan',
                'lecturer_name' => 'Sir Fahmi',
                'status' => 'published',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'activity_name' => 'MOBILE PHOTOGRAPHY',
                'date_time' => '2026-06-01 09:00:00',
                'capacity' => 30,
                'current_registration' => 0,
                'venue' => 'Dewan Serbaguna',
                'lecturer_name' => 'Madam Siti',
                'status' => 'draft', // Testing draft visibility
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'activity_name' => 'BASIC ARDUINO',
                'date_time' => '2026-06-05 14:00:00',
                'capacity' => 25,
                'current_registration' => 2,
                'venue' => 'Computer Faculty Lab 1',
                'lecturer_name' => 'Dr. Ahmad',
                'status' => 'published',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'activity_name' => 'PUBLIC SPEAKING 101',
                'date_time' => '2026-06-10 10:00:00',
                'capacity' => 40,
                'current_registration' => 0,
                'venue' => 'DKP 4',
                'lecturer_name' => 'Madam Najihah',
                'status' => 'published',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}