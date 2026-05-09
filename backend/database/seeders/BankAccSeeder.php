<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BankAccSeeder extends Seeder
{
    public function run()
    {
        // 1. Fetch all existing student_id values from the students table
        $studentIds = DB::table('students')->pluck('student_id');

        if ($studentIds->isEmpty()) {
            $this->command->info("No students found. Please seed the students table first!");
            return;
        }

        // 2. Loop through the students to create bank records
        foreach ($studentIds as $index => $id) {
            // We use a simple check to assign different banks to different students
            $bankName = ($index % 2 == 0) ? 'RHB Islamic Bank' : 'Maybank';
            $accNo = ($index % 2 == 0) ? '1560827390' . $index : '1640123456' . $index;

            DB::table('bank_accounts')->insert([
                'student_id' => $id, // Inherited from the students table
                'bank_name'  => $bankName,
                'acc_no'     => $accNo,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}