<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SubjectSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('subjects')->insert([
            [
                'subject_code'   => 'BCY3083',
                'subject_name'   => 'SECURE SOFTWARE DEVELOPMENT',
                'credit_hours'   => 3,
                'total_section'  => 3,
                'total_lab'      => 1,
                'subject_status' => 'active',
                'created_at'     => now(),
                'updated_at'     => now(),
            ],
            [
                'subject_code'   => 'BCY3073',
                'subject_name'   => 'PENETRATION TESTING',
                'credit_hours'   => 3,
                'total_section'  => 2,
                'total_lab'      => 1,
                'subject_status' => 'active',
                'created_at'     => now(),
                'updated_at'     => now(),
            ],
            [
                'subject_code'   => 'UQA2002',
                'subject_name'   => 'KO-KURIKULUM',
                'credit_hours'   => 2,
                'total_section'  => 0,
                'total_lab'      => 0,
                'subject_status' => 'active',
                'created_at'     => now(),
                'updated_at'     => now(),
            ],
        ]);
    }
}