<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Student - Sharmila
        \App\Models\User::create([
            'name' => 'Sharmila',
            'email' => 'sharmila@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'student',
        ]);

        // 2. Treasury - Najihah
        \App\Models\User::create([
            'name' => 'Najihah',
            'email' => 'najihah@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'treasury',
        ]);

        // 3. Faculty - Hidayah
        \App\Models\User::create([
            'name' => 'Hidayah',
            'email' => 'hidayah@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'faculty',
        ]);

        // 4. Pusat Adab - Ainin
        \App\Models\User::create([
            'name' => 'Ainin',
            'email' => 'ainin@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'pusat_adab',
        ]);

        // 5. Lecturer - Wahidah (Malay)
        \App\Models\User::create([
            'name' => 'Wahidah',
            'email' => 'wahidah@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'lecturer',
        ]);

        // 6. Lecturer - Tan (Chinese)
        \App\Models\User::create([
            'name' => 'Tan Wei Meng',
            'email' => 'tan@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'lecturer',
        ]);

        // 7. Lecturer - Raj (Indian)
        \App\Models\User::create([
            'name' => 'Rajesh Kumar',
            'email' => 'rajesh@umpsa.edu.my',
            'password' => bcrypt('123456'),
            'role' => 'lecturer',
        ]);
    }
}
