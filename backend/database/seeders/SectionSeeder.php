<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SectionSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('sections')->insert([
            [
                'lecturer_id' => 1,
                'subject_id'  => 1,
                'section_no'  => '02',
                'capacity'    => 30,
                'created_at'  => now(),
                'updated_at'  => now(),
            ],
            [
                'lecturer_id' => 1,
                'subject_id'  => 1,
                'section_no'  => '01',
                'capacity'    => 30,
                'created_at'  => now(),
                'updated_at'  => now(),
            ],
            [
                'lecturer_id' => 1,
                'subject_id'  => 2,
                'section_no'  => '02',
                'capacity'    => 25,
                'created_at'  => now(),
                'updated_at'  => now(),
            ],
        ]);
    }
}