<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class UserSeeder extends Seeder
{
    public function run(): void
    {
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
            $user = User::updateOrCreate(
                ['email' => $u['email']],
                [
                    'name' => $u['name'],
                    'password' => Hash::make('123456'),
                    'role' => $u['role'],
                    'phone_num' => $generatePhone(),
                ]
            );

            if ($u['role'] === 'treasury') {
                $departments = ['Finance', 'Accounts', 'Bursary', 'Administration'];
                $randomDept = $departments[array_rand($departments)];

                $customId = 'TR-' . str_pad($user->id, 3, '0', STR_PAD_LEFT);

                DB::table('treasurers')->updateOrInsert(
                    ['id' => $user->id],
                    [
                        'treasurer_id' => $customId, 
                        'department' => $randomDept, 
                        'created_at' => now(),
                        'updated_at' => now()
                    ]
                );
            }
        }

        // --- 2. 50 Students (35 Original + 15 New) ---
        $students = [
            // Original 35 Students
            ['name' => 'Nur Aqilah', 'email' => 'aqilah@umpsa.edu.my'],
            ['name' => 'Norfardilla', 'email' => 'dilla@umpsa.edu.my'],
            ['name' => 'Amir Mustaqim', 'email' => 'amir@umpsa.edu.my'],
            ['name' => 'Aqil Wafiq', 'email' => 'wafiq@umpsa.edu.my'],
            ['name' => 'Ainul Mardhiah', 'email' => 'ainul@umpsa.edu.my'],
            ['name' => 'Nurin Irdina', 'email' => 'nurin@umpsa.edu.my'],
            ['name' => 'Nor Ain Athirah', 'email' => 'ainathirah@umpsa.edu.my'],
            ['name' => 'Emmirul Iqmal', 'email' => 'emmirul@umpsa.edu.my'],
            ['name' => 'Farhah Natasya', 'email' => 'farhah@umpsa.edu.my'],
            ['name' => 'Alif Asyraf', 'email' => 'alif@umpsa.edu.my'],
            ['name' => 'Zulhelmi', 'email' => 'zul@umpsa.edu.my'],
            ['name' => 'Nurul Izzah', 'email' => 'izzah@umpsa.edu.my'],
            ['name' => 'Khairul Anwar', 'email' => 'anwar@umpsa.edu.my'],
            ['name' => 'Batrisyia', 'email' => 'batrisyia@umpsa.edu.my'],
            ['name' => 'Ahmad Fauzi', 'email' => 'fauzi@umpsa.edu.my'],
            ['name' => 'Siti Aminah', 'email' => 'aminah@umpsa.edu.my'],
            ['name' => 'Muhammad Hafiz', 'email' => 'hafiz@umpsa.edu.my'],
            ['name' => 'Lee Wei Lian', 'email' => 'lian@umpsa.edu.my'],
            ['name' => 'Chong Mei Yee', 'email' => 'meiyee@umpsa.edu.my'],
            ['name' => 'Arif Hamdan', 'email' => 'arif@umpsa.edu.my'],
            ['name' => 'Nurul Huda', 'email' => 'huda@umpsa.edu.my'],
            ['name' => 'Syafiqah Alias', 'email' => 'syafiqah@umpsa.edu.my'],
            ['name' => 'Badrul Hisham', 'email' => 'badrul@umpsa.edu.my'],
            ['name' => 'Zaidatul Akmal', 'email' => 'zaidatul@umpsa.edu.my'],
            ['name' => 'Firdaus Othman', 'email' => 'firdaus@umpsa.edu.my'],
            ['name' => 'Aisha Humaira', 'email' => 'aisha@umpsa.edu.my'],
            ['name' => 'Kavitha Devi', 'email' => 'kavitha@umpsa.edu.my'],
            ['name' => 'Santhosh Nair', 'email' => 'santhosh@umpsa.edu.my'],
            ['name' => 'Hazwan Hashim', 'email' => 'hazwan@umpsa.edu.my'],
            ['name' => 'Puteri Balqis', 'email' => 'puteri@umpsa.edu.my'],
            ['name' => 'Daniel Hakim', 'email' => 'daniel@umpsa.edu.my'],
            ['name' => 'Sarah Natasha', 'email' => 'sarah@umpsa.edu.my'],
            ['name' => 'Haikal Zikri', 'email' => 'haikal@umpsa.edu.my'],
            ['name' => 'Nabila Razali', 'email' => 'nabila@umpsa.edu.my'],
            ['name' => 'Azman Ali', 'email' => 'azman@umpsa.edu.my'],
            
            // --- 15 NEW Students ---
            ['name' => 'Fakhrul Razi', 'email' => 'fakhrul@umpsa.edu.my'],
            ['name' => 'Nurul Ainani', 'email' => 'ainani@umpsa.edu.my'],
            ['name' => 'Chew Kar Heng', 'email' => 'karheng@umpsa.edu.my'],
            ['name' => 'Wan Nurul Izzati', 'email' => 'izzati@umpsa.edu.my'],
            ['name' => 'Muhammad Luqman', 'email' => 'luqman@umpsa.edu.my'],
            ['name' => 'Tan Siew Lan', 'email' => 'siewlan@umpsa.edu.my'],
            ['name' => 'Syed Azmi', 'email' => 'syed@umpsa.edu.my'],
            ['name' => 'Nurul Syuhada', 'email' => 'syuhada@umpsa.edu.my'],
            ['name' => 'Lim Wei Kiat', 'email' => 'weikiat@umpsa.edu.my'],
            ['name' => 'Farah Adiba', 'email' => 'adiba@umpsa.edu.my'],
            ['name' => 'Ahmad Zaki', 'email' => 'zaki@umpsa.edu.my'],
            ['name' => 'Nur Fatihah', 'email' => 'fatihah@umpsa.edu.my'],
            ['name' => 'Muhammad Ikhwan', 'email' => 'ikhwan@umpsa.edu.my'],
            ['name' => 'Siti Khadijah', 'email' => 'khadijah@umpsa.edu.my'],
            ['name' => 'Mohd Faiz', 'email' => 'faiz@umpsa.edu.my'],
        ];

        foreach ($students as $s) {
            User::updateOrCreate(
                ['email' => $s['email']],
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