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
            $table->foreignId('attendance_id')->references('id')->on('attendances')->onDelete('cascade');
            // FIX: students table PK is 'id' (auto-increment), so FK must reference 'id'
            $table->foreignId('student_id')->references('id')->on('students')->onDelete('cascade');
            $table->dateTime('submitted_time');
            $table->string('status');
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