<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attendance_records', function (Blueprint $table) {
            $table->id(); 
            $table->foreignId('attendance_id')->references('id')->on('attendances');
            $table->foreignId('student_id')->references('id')->on('students');
            
            $table->dateTime('submitted_time');
            $table->string('status'); // e.g., 'Present', 'Absent', 'Late'
            $table->decimal('marks', 5, 2)->nullable();
            $table->string('grade_category')->nullable();
            
            $table->timestamps();
            
           
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendance_records');
    }
};