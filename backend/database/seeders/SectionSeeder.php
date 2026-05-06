<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Section;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class SectionSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Get User records first
        $userWahidah = User::where('email', 'wahidah@umpsa.edu.my')->first();
        $userTan     = User::where('email', 'tan@umpsa.edu.my')->first();

        // 2. Get the corresponding Lecturer IDs from the lecturers table
        // (Assuming you want to link to the lecturer table's ID)
        $wahidahId = DB::table('lecturers')->where('lecturer_id', $userWahidah?->id)->value('id');
        $tanId     = DB::table('lecturers')->where('lecturer_id', $userTan?->id)->value('id');

        // 3. Get the Subjects (matching your SubjectSeeder codes)
        $bcy3083 = Subject::where('subject_code', 'BCY3083')->first();
        $bcy3073 = Subject::where('subject_code', 'BCY3073')->first();

        // Guard Clause: Stops the crash if previous seeders didn't run correctly
        if (!$bcy3083 || !$bcy3073 || !$wahidahId || !$tanId) {
            $this->command->error("Dependency missing! Ensure UserSeeder, SubjectSeeder, and LecturerSeeder ran first.");
            return;
        }

        $sections = [
            [
                'lecturer_id'   => $wahidahId,
                'subject_id'    => $bcy3083->subject_id, 
                'section_no'    => 'BCY3083-A',
                'lab_group'     => 'LAB1',
                'capacity'      => 30,
                'enrolled'      => 0,
                'schedule_time' => '08:00:00',
                'schedule_day'  => 'Monday',
            ],
            [
                'lecturer_id'   => $tanId,
                'subject_id'    => $bcy3073->subject_id,
                'section_no'    => 'BCY3073-A',
                'lab_group'     => 'LAB1',
                'capacity'      => 25,
                'enrolled'      => 0,
                'schedule_time' => '14:00:00',
                'schedule_day'  => 'Tuesday',
            ],
        ];

        foreach ($sections as $data) {
            Section::create($data);
        }
    }
}