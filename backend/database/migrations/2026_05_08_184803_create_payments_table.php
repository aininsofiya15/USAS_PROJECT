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
        Schema::create('payments', function (Blueprint $table) {
            $table->id('payment_id');
            // Use the same type as student_id in your students table (likely string/varchar)
            $table->string('student_id'); 
            $table->unsignedBigInteger('fee_id');
            $table->decimal('amount', 10, 2);
            $table->string('payment_method'); // 'Internet Banking' or 'Credit Card/Debit Card'
            $table->string('status')->default('Success');
            $table->timestamp('payment_date');
            $table->timestamps();

            // Foreign Key Constraints
            $table->foreign('student_id')->references('student_id')->on('students')->onDelete('cascade');
            $table->foreign('fee_id')->references('fee_id')->on('fees')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
