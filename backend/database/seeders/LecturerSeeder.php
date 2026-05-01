<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class LecturerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Find Wahidah's user account created by the UserSeeder
        $wahidahUser = User::where('email', 'wahidah@umpsa.edu.my')->first();

        // Create the Lecturer profile and link it using her user_id
        if ($wahidahUser) {
            DB::table('lecturers')->insert([
                'user_id' => $wahidahUser->id,
                'lecturer_id' => '2213455', 
                'full_name' => 'Ts. Dr. Wahidah',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}