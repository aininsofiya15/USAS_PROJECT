<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fees', function (Blueprint $table) {
            $table->id('fee_id'); // Primary Key
            
            // Foreign Key linking to users table (Student Inheritance)
            $table->foreignId('student_id')->constrained('users')->onDelete('cascade');
            
            // Financial Fields
            $table->decimal('total_fee', 10, 2)->default(0.00);
            $table->decimal('paid_amount', 10, 2)->default(0.00);
            $table->decimal('outstanding_amount', 10, 2)->default(0.00);
            
            // Status field for your Flutter "Oval" chips
            $table->string('status')->default('unpaid'); 
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fees');
    }
};