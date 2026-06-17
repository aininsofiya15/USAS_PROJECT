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
        Schema::create('credit_claims', function (Blueprint $table) {
            $table->id(); // Primary Key auto-increment (id)
            
            // Foreign Key tracking the integer User Account index
            $table->unsignedBigInteger('student_id');
            
            // Foreign Key tracking the integer Subject index mapping to UQA2002
            $table->unsignedBigInteger('subject_id');
            
            // Status constraint defaulting to 'pending' as defined in CreditController
            $table->string('status')->default('pending'); 
            
            $table->timestamps(); // Generates created_at and updated_at columns

            // Optional: Define Foreign Key Constraints to protect data integrity
            $table->foreign('student_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('subject_id')->references('subject_id')->on('subjects')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('credit_claims');
    }
};