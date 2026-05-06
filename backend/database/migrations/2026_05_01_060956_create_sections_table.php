<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
<<<<<<< Updated upstream
    public function up(): void
    {
        Schema::create('sections', function (Blueprint $table) {
            $table->id('section_id');
            $table->foreignId('lecturer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('subject_id')->constrained('subjects', 'subject_id')->onDelete('cascade');
            $table->string('section_no');
            $table->string('lab_group')->nullable();
            $table->integer('capacity');
            $table->integer('enrolled')->default(0);
            $table->time('schedule_time')->nullable();
            $table->string('schedule_day')->nullable();
=======
    /**
     * Run the migrations.
     */
        public function up(): void
    {
        Schema::create('sections', function (Blueprint $table) {
            $table->id(); // This table can keep a standard auto-increment ID
            
            // 1. Check your subjects table. If it uses id('subject_id'), change this to:
            // $table->foreignId('subject_id')->references('subject_id')->on('subjects')->onDelete('cascade');
            // If it uses standard $table->id(), keep it like this:
            $table->foreignId('subject_id')->constrained('subjects')->onDelete('cascade');

            // 2. THIS IS THE FIX: Link to 'user_id' instead of 'id'
            $table->foreignId('user_id')->constrained('lecturers', 'user_id')->onDelete('cascade');

            $table->string('semester_code');
            $table->string('section_name');
            $table->string('subject_code');
>>>>>>> Stashed changes
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sections');
    }
};