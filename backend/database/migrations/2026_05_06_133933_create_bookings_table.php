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
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            
            // 1. Define the foreign key columns to match your other tables' data types
            $table->unsignedBigInteger('student_id'); // If your student table primary key is an ID
            $table->unsignedBigInteger('module_id');  // Tracks the ID from modules table
            
            $table->string('attendance')->default('-');
            $table->string('total_marks')->default('-');
            $table->timestamps();

            // 2. Set up the foreign key constraint for the module
            $table->foreign('module_id')
                ->references('id')
                ->on('modules')
                ->onDelete('cascade');

            // 3. Set up the foreign key constraint for the student
            $table->foreign('student_id')
                ->references('id') 
                ->on('students')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
