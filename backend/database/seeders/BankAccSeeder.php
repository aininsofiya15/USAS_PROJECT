<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class BankAccSeeder extends Seeder
{
    public function run()
    {
        Schema::disableForeignKeyConstraints();
        DB::table('bank_accounts')->truncate(); 
        Schema::enableForeignKeyConstraints();

        $studentIds = DB::table('students')->pluck('student_id');

        if ($studentIds->isEmpty()) {
            $this->command->info("No students found. Please seed the students table first!");
            return;
        }

        foreach ($studentIds as $index => $id) {
            // Left-pad the index so it doesn't break string positioning (e.g., "001", "012")
            $paddedIndex = str_pad($index + 1, 3, '0', STR_PAD_LEFT); 
            
            // Cycle dynamically from 0 to 3 using modulo
            $bankCycle = $index % 4;

            switch ($bankCycle) {
                case 0:
                    $bankName = 'Maybank';
                    // Maybank Standard: 12 Digits
                    $accNo = '1640123' . str_pad($index + 1, 5, '0', STR_PAD_LEFT);
                    break;

                case 1:
                    $bankName = 'CIMB Bank';
                    // CIMB Bank Standard: 14 Digits
                    $accNo = '80012345' . str_pad($index + 1, 6, '0', STR_PAD_LEFT);
                    break;

                case 2:
                    $bankName = 'Bank Islam';
                    // Bank Islam Standard: 14 Digits
                    $accNo = '14012010' . str_pad($index + 1, 6, '0', STR_PAD_LEFT);
                    break;

                case 3:
                default:
                    $bankName = 'RHB Islamic Bank';
                    // RHB Islamic Bank Standard: 14 Digits
                    $accNo = '26210100' . str_pad($index + 1, 6, '0', STR_PAD_LEFT);
                    break;
            }

            DB::table('bank_accounts')->insert([
                'student_id' => $id,
                'bank_name'  => $bankName,
                'acc_no'     => $accNo,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}