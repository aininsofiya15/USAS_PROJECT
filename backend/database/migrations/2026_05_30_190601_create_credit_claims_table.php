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
            $table->id(); // Auto-incrementing primary key for the claim itself
            $table->unsignedBigInteger('student_id'); // Foreign key for the student
            $table->unsignedBigInteger('subject_id'); // Foreign key linking to subjects table
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending'); // Status tracker
            $table->timestamps(); // Creates created_at and updated_at

            // ── Relational Foreign Key Constraints ──
            // Cascade delete ensures if a student profile is deleted, their claims are wiped out too
            $table->foreign('student_id')->references('id')->on('users')->onDelete('cascade');
            
            // Link directly to the structural primary key column seen in your phpMyAdmin image
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