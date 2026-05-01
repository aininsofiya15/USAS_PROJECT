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
    Schema::create('sections', function (Blueprint $table) {
        $table->id();
        $table->string('semester_code');
        $table->string('section_name');
        
        // Change these from foreignId() to string()
        $table->string('subject_code');
        $table->string('lecturer_id');
        $table->timestamps();

        // Tell Laravel exactly which columns these link to
        $table->foreign('subject_code')->references('subject_code')->on('subjects')->onDelete('cascade');
        $table->foreign('lecturer_id')->references('lecturer_id')->on('lecturers')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sections');
    }
};
