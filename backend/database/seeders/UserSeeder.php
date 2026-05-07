<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // --- Existing Users ---
       User::create(['name' => 'Sharmila', 'email' => 'sharmila@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'student']);
       User::create(['name' => 'Najihah', 'email' => 'najihah@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'treasury']);
       User::create(['name' => 'Hidayah', 'email' => 'hidayah@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'faculty']);
       User::create(['name' => 'Ainin', 'email' => 'ainin@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'pusat_adab']);
       User::create(['name' => 'Wahidah', 'email' => 'wahidah@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'lecturer']);
       User::create(['name' => 'Tan Wei Meng', 'email' => 'tan@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'lecturer']);
       User::create(['name' => 'Rajesh Kumar', 'email' => 'rajesh@umpsa.edu.my', 'password' => bcrypt('123456'), 'role' => 'lecturer']);

        // --- 15 New Students (from Prototype) ---
        $students = [
            ['name' => 'Nur Aqilah', 'email' => 'aqilah@umpsa.edu.my'],
            ['name' => 'Norfardilla', 'email' => 'dilla@umpsa.edu.my'],
            ['name' => 'Amir Mustaqim', 'email' => 'amir@umpsa.edu.my'],
            ['name' => 'Aqil Wafiq', 'email' => 'wafiq@umpsa.edu.my'],
            ['name' => 'Nurunajihah', 'email' => 'nuruna@umpsa.edu.my'],
            ['name' => 'Wahidah Syarini', 'email' => 'syarini@umpsa.edu.my'],
            ['name' => 'Siti Nur Hidayah', 'email' => 'cthidayah@umpsa.edu.my'],
            ['name' => 'Ainin Sofiya', 'email' => 'sofiya@umpsa.edu.my'],
            ['name' => 'Farhah Natasya', 'email' => 'farhah@umpsa.edu.my'],
            ['name' => 'Alif Asyraf', 'email' => 'alif@umpsa.edu.my'],
            ['name' => 'Zulhelmi', 'email' => 'zul@umpsa.edu.my'],
            ['name' => 'Nurul Izzah', 'email' => 'izzah@umpsa.edu.my'],
            ['name' => 'Khairul Anwar', 'email' => 'anwar@umpsa.edu.my'],
            ['name' => 'Batrisyia', 'email' => 'bat@umpsa.edu.my'],
            ['name' => 'Ahmad Fauzi', 'email' => 'fauzi@umpsa.edu.my'],
        ];

        foreach ($students as $student) {
            User::create([
                'name' => $student['name'],
                'email' => $student['email'],
                'password' => bcrypt('123456'),
                'role' => 'student',
            ]);
        }
    }
}