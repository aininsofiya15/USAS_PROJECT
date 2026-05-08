<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class StudentSeeder extends Seeder
{
    public function run(): void
    {
        // Fetch all users with the role 'student'
        $studentUsers = User::where('role', 'student')->get();
        
        $matricPrefixes = ['CA', 'CB', 'CD', 'CF'];

        foreach ($studentUsers as $index => $user) {
            $matricNo = $matricPrefixes[array_rand($matricPrefixes)] . (24000 + $index);
            
            DB::table('students')->updateOrInsert(
                ['id' => $user->id], // Links students.id to users.id
                [
                    'student_id' => $matricNo, // Matric Number string
                    'faculty' => 'Faculty of Computing',
                    'course_name' => 'Computer Science',
                    'program' => 'Bachelor Degree',
                    'current_semester' => 1,
                    'year' => 2024,
                    'is_blocked' => ($index % 5 == 0), // Blocks every 5th student
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}