<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class LabSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('labs')->insert([
            [
                'section_id' => 1,
                'lab_name'   => '01A',
                'capacity'   => 30,
                'enrolled'   => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'section_id' => 1,
                'lab_name'   => '01B',
                'capacity'   => 25,
                'enrolled'   => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'section_id' => 2,
                'lab_name'   => '02A',
                'capacity'   => 20,
                'enrolled'   => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}