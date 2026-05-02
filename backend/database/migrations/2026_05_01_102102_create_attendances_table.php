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
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            // Who and What
            $table->string('lecturer_id'); 
            $table->string('subject_code'); 
            $table->string('section_name'); 
            
            // The inputs from your new screen
            $table->string('class_type'); // 'Lecture' or 'Lab'
            $table->date('class_date');
            $table->time('class_time');
            $table->decimal('latitude', 10, 8)->nullable(); // For the Geolocation map
            $table->decimal('longitude', 11, 8)->nullable();
            
            // The final generated code
            $table->string('generated_code')->unique(); 
            
            $table->timestamps();

            // Link them to your existing tables
            $table->foreign('lecturer_id')->references('lecturer_id')->on('lecturers')->onDelete('cascade');
            $table->foreign('subject_code')->references('subject_code')->on('subjects')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
