<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class LecturerSeeder extends Seeder
{
    public function run(): void
    {
        $lecturers = [
            ['email' => 'wahidah@umpsa.edu.my', 'faculty' => 'Faculty of Computer Science'],
            ['email' => 'tan@umpsa.edu.my',     'faculty' => 'Faculty of Engineering'],
            ['email' => 'rajesh@umpsa.edu.my',  'faculty' => 'Faculty of Islamic Studies'],
        ];

        foreach ($lecturers as $lect) {
            $user = User::where('email', $lect['email'])->first();

            if ($user) {
                DB::table('lecturers')->insert([
                    'lecturer_id' => $user->id,
                    'faculty'     => $lect['faculty'],
                    'created_at'  => now(),
                    'updated_at'  => now(),
                ]);
            }
        }
    }
}