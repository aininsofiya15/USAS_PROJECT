<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Helper function for random phone numbers
        $generatePhone = function() {
            $prefixes = ['011', '012', '013', '014', '016', '017', '018', '019'];
            return $prefixes[array_rand($prefixes)] . '-' . rand(1000000, 9999999);
        };

        // --- 1. Core Users ---
        $coreUsers = [
            ['name' => 'Sharmila', 'email' => 'sharmila@umpsa.edu.my', 'role' => 'student'],
            ['name' => 'Najihah', 'email' => 'najihah@umpsa.edu.my', 'role' => 'treasury'],
            ['name' => 'Hidayah', 'email' => 'hidayah@umpsa.edu.my', 'role' => 'faculty'],
            ['name' => 'Ainin', 'email' => 'ainin@umpsa.edu.my', 'role' => 'pusat_adab'],
            ['name' => 'Wahidah', 'email' => 'wahidah@umpsa.edu.my', 'role' => 'lecturer'],
            ['name' => 'Tan Wei Meng', 'email' => 'tan@umpsa.edu.my', 'role' => 'lecturer'],
            ['name' => 'Rajesh Kumar', 'email' => 'rajesh@umpsa.edu.my', 'role' => 'lecturer'],
        ];

        foreach ($coreUsers as $u) {
            User::updateOrCreate(
                ['email' => $u['email']], // SEARCH by email only
                [
                    'name' => $u['name'],
                    'password' => Hash::make('123456'),
                    'role' => $u['role'],
                    'phone_num' => $generatePhone(),
                ]
            );
        }

        // --- 2. 15 Prototype Students ---
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

        foreach ($students as $s) {
            User::updateOrCreate(
                ['email' => $s['email']], // SEARCH by email only
                [
                    'name' => $s['name'],
                    'password' => Hash::make('123456'),
                    'role' => 'student',
                    'phone_num' => $generatePhone(),
                ]
            );
        }
    }
}