<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subjects', function (Blueprint $table) {
            $table->id('subject_id');
            //$table->foreignId('faculty_registrar_id')->constrained('users')->onDelete('cascade');
            $table->string('subject_code')->unique();
            $table->string('subject_name');
            $table->integer('credit_hours');
            $table->integer('total_section')->default(0);
            $table->integer('total_lab')->default(0);
            $table->enum('subject_status', ['active', 'inactive'])->default('active');
            //$table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subjects');
    }
};