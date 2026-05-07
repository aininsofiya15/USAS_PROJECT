<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check if the table exists to prevent errors
        if (Schema::hasTable('students')) {
            Schema::table('students', function (Blueprint $table) {
                // 1. Drop the foreign key constraint that links student_id to users.id
                // Because you originally used $table->foreignId('student_id'), 
                // Laravel named the index 'students_student_id_foreign'.
                $table->dropForeign(['student_id']);

                // 2. Now change the column type to string so it accepts 'CA24000'
                $table->string('student_id')->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            // Revert back to integer if needed (will fail if CA24000 data exists)
            $table->integer('student_id')->change();
        });
    }
};