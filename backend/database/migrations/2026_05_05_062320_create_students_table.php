<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->references('id')->on('users')->onDelete('cascade');

            $table->string('faculty');
            $table->string('course_name');
            $table->integer('current_semester');
            $table->integer('year');
            
            $table->timestamps();
            
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};