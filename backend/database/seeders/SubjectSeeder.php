<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB; // <-- This is required!

class SubjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('subjects')->insert([
            [
                'subject_code' => 'BCY3083',
                'subject_name' => 'SECURE SOFTWARE DEVELOPMENT',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'subject_code' => 'BCY3073',
                'subject_name' => 'PENETRATION TESTING',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}