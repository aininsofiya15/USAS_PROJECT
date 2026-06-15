<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class CreditClaimDemoSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        $userId = DB::table('users')->updateOrInsert(
            ['email' => 'claimdemo@umpsa.edu.my'],
            [
                'name' => 'Credit Claim Demo Student',
                'password' => Hash::make('123456'),
                'role' => 'student',
                'phone_num' => '012-3456789',
                'updated_at' => $now,
                'created_at' => $now,
            ]
        );

        $user = DB::table('users')
            ->where('email', 'claimdemo@umpsa.edu.my')
            ->first();

        DB::table('students')->updateOrInsert(
            ['id' => $user->id],
            [
                'student_id' => 'CB24099',
                'ic_no' => '040101060999',
                'faculty' => 'Faculty of Computing',
                'course_name' => 'Bachelor of Computer Science (Software Engineering) with Honours',
                'program' => 'Bachelor Degree',
                'current_semester' => 4,
                'year' => 2,
                'is_blocked' => false,
                'updated_at' => $now,
                'created_at' => $now,
            ]
        );

        $subject = DB::table('subjects')->where('subject_code', 'UQA2002')->first();

        if (!$subject) {
            DB::table('subjects')->insert([
                'subject_code' => 'UQA2002',
                'subject_name' => 'KO-KURIKULUM',
                'credit_hours' => 2,
                'total_section' => 0,
                'total_lab' => 0,
                'subject_status' => 'active',
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $subject = DB::table('subjects')->where('subject_code', 'UQA2002')->first();
        }

        $modules = [
            [
                'activity_name' => 'DEMO KAYAKING ADVENTURE',
                'date_time' => '2026-06-20 08:00:00',
                'capacity' => 30,
                'venue' => 'Tasik Pekan',
                'lecturer_name' => 'Pusat Adab',
            ],
            [
                'activity_name' => 'DEMO BASIC ARCHERY',
                'date_time' => '2026-06-22 09:00:00',
                'capacity' => 30,
                'venue' => 'Padang Ragbi Pekan',
                'lecturer_name' => 'Pusat Adab',
            ],
            [
                'activity_name' => 'DEMO PUBLIC SPEAKING',
                'date_time' => '2026-06-24 10:00:00',
                'capacity' => 30,
                'venue' => 'DKP 4',
                'lecturer_name' => 'Pusat Adab',
            ],
            [
                'activity_name' => 'DEMO COMMUNITY SERVICE',
                'date_time' => '2026-06-26 14:00:00',
                'capacity' => 30,
                'venue' => 'Dewan Serbaguna',
                'lecturer_name' => 'Pusat Adab',
            ],
        ];

        foreach ($modules as $module) {
            DB::table('modules')->updateOrInsert(
                ['activity_name' => $module['activity_name']],
                [
                    'date_time' => $module['date_time'],
                    'capacity' => $module['capacity'],
                    'venue' => $module['venue'],
                    'lecturer_name' => $module['lecturer_name'],
                    'description' => 'Demo module for testing approved credit claims.',
                    'whatsapp_link' => null,
                    'pic_contact' => null,
                    'status' => 'published',
                    'updated_at' => $now,
                    'created_at' => $now,
                ]
            );

            $moduleId = DB::table('modules')
                ->where('activity_name', $module['activity_name'])
                ->value('id');

            DB::table('bookings')->updateOrInsert(
                [
                    'student_id' => $user->id,
                    'module_id' => $moduleId,
                ],
                [
                    'is_claimed' => 1,
                    'updated_at' => $now,
                    'created_at' => $now,
                ]
            );
        }

        DB::table('modules')
            ->whereIn('activity_name', array_column($modules, 'activity_name'))
            ->update(['current_registration' => 1, 'updated_at' => $now]);

        DB::table('credit_claims')->updateOrInsert(
            [
                'student_id' => $user->id,
                'subject_id' => $subject->subject_id,
            ],
            [
                'status' => 'approved',
                'updated_at' => $now,
                'created_at' => $now,
            ]
        );

        DB::table('registration')->updateOrInsert(
            [
                'student_id' => $user->id,
                'subject_id' => $subject->subject_id,
                'status' => 'active',
            ],
            [
                'section_id' => null,
                'lab_id' => null,
                'registered_at' => $now,
            ]
        );
    }
}
