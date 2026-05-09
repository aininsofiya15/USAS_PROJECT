<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BookingSeeder extends Seeder
{
    public function run(): void
    {
        // Student IDs from your phpMyAdmin screenshot: 1, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22
        // Let's fill up several modules to see how the UI handles different counts.
        
        $registrations = [
            // 12 Students in Module 1 (e.g., Kayaking)
            ['student_id' => 1,  'module_id' => 1],
            ['student_id' => 8,  'module_id' => 1],
            ['student_id' => 9,  'module_id' => 1],
            ['student_id' => 10, 'module_id' => 1],
            ['student_id' => 11, 'module_id' => 1],
            ['student_id' => 12, 'module_id' => 1],
            ['student_id' => 13, 'module_id' => 1],
            ['student_id' => 14, 'module_id' => 1],
            ['student_id' => 15, 'module_id' => 1],
            ['student_id' => 16, 'module_id' => 1],
            ['student_id' => 17, 'module_id' => 1],
            ['student_id' => 18, 'module_id' => 1],

            // 5 Students in Module 2 (e.g., Archery)
            ['student_id' => 19, 'module_id' => 2],
            ['student_id' => 20, 'module_id' => 2],
            ['student_id' => 21, 'module_id' => 2],
            ['student_id' => 22, 'module_id' => 2],
            ['student_id' => 1,  'module_id' => 2],

            // 3 Students in Module 4 (e.g., Photography)
            ['student_id' => 8,  'module_id' => 4],
            ['student_id' => 9,  'module_id' => 4],
            ['student_id' => 10, 'module_id' => 4],
        ];

        foreach ($registrations as $reg) {
            // 1. Insert into bookings
            DB::table('bookings')->insert([
                'student_id' => $reg['student_id'],
                'module_id'  => $reg['module_id'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // 2. Sync the registration count for the UI cards
            DB::table('modules')
                ->where('id', $reg['module_id'])
                ->increment('current_registration');
        }
    }
}