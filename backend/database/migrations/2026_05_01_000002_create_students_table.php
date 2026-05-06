<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->onDelete('cascade');
            $table->string('faculty');
            $table->string('course_name');
            $table->integer('current_semester');
            $table->integer('year');
<<<<<<< Updated upstream:backend/database/migrations/2026_05_01_000002_create_students_table.php
=======
            $table->string('matric_id')->unique();
            $table->boolean('is_blocked')->default(false);
>>>>>>> Stashed changes:backend/database/migrations/2026_05_05_062320_create_students_table.php
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};