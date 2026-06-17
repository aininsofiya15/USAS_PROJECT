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
            $table->id(); 
            
            // 🎯 FIX: Changed from unsignedBigInteger to string to accept Matric Numbers!
            $table->string('student_id'); 
            
            $table->unsignedBigInteger('subject_id');
            $table->string('status')->default('pending'); 
            $table->timestamps();

            // 🎯 FIX: Comment out or remove this constraint since student_id is now a text string
            // $table->foreign('student_id')->references('id')->on('users')->onDelete('cascade');
            
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