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
            
            // 1. Seed Students Table
            DB::table('students')->updateOrInsert(
                ['id' => $user->id], // PK is the User ID
                [
                    'student_id' => $matricNo, // This is your FK/Matric column
                    'faculty' => 'FCOM',
                    'course_name' => 'Computer Science',
                    'current_semester' => 1,
                    'year' => 2024,
                    'is_blocked' => ($index % 5 == 0), // Blocks every 5th student for variety
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );

            // 2. Seed Fees Table
            $isPaid = ($index % 3 != 0); // Every 3rd student has outstanding balance
            $total = 2500.00;
            $outstanding = $isPaid ? 0.00 : 1200.00;

            DB::table('fees')->updateOrInsert(
                ['student_id' => $user->id], // student_id column in fees table acts as the FK
                [
                    'total_amount' => $total,
                    'paid_amount' => $total - $outstanding,
                    'outstanding_amount' => $outstanding,
                    'status' => ($outstanding > 0) ? 'unpaid' : 'paid',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}