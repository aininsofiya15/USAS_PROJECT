<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Section;

class SectionSeeder extends Seeder
{
    public function run(): void
    {
        // Just insert the strings directly!
        Section::create([
            'semester_code' => '252026 SEM II',
            'section_name' => 'SECTION 01',
            'subject_code' => 'BCY3083',
            'lecturer_id' => '2213455',
        ]);

        Section::create([
            'semester_code' => '252026 SEM II',
            'section_name' => 'SECTION 03',
            'subject_code' => 'BCY3083',
            'lecturer_id' => '2213455',
        ]);

        Section::create([
            'semester_code' => '252026 SEM II',
            'section_name' => 'SECTION 02',
            'subject_code' => 'BCY3073',
            'lecturer_id' => '2213455',
        ]);
    }
}