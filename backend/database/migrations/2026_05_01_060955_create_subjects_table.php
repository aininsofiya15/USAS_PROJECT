<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subjects', function (Blueprint $table) {
            $table->id();
            $table->string('subject_code', 10);
            $table->string('subject_name', 100);
            $table->integer('credit_hours');
            $table->integer('total_section');
            $table->integer('total_lab');
            $table->string('subject_status');
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();
            
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subjects');
    }
};