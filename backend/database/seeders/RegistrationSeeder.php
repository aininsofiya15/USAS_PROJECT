<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RegistrationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Define the three registrations for student_id: 1
        $registrations = [
            [
                'student_id' => 1,
                'section_id' => 1,
                'status' => 'active',
                'registered_at' => Carbon::now(),
            ],
            [
                'student_id' => 1,
                'section_id' => 2,
                'status' => 'active',
                'registered_at' => Carbon::now(),
            ],
            [
                'student_id' => 1,
                'section_id' => 3,
                'status' => 'active',
                'registered_at' => Carbon::now(),
            ],
        ];

        // Insert into the 'registration' table
        DB::table('registration')->insert($registrations);
    }
}