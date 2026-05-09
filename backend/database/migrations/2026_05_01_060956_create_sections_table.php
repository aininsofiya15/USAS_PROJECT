<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sections', function (Blueprint $table) {
            $table->id('section_id');
            $table->foreignId('lecturer_id')->constrained('users', 'id')->onDelete('cascade');
            $table->foreignId('subject_id')->constrained('subjects', 'subject_id')->onDelete('cascade');
            $table->string('section_no');
            $table->string('lab_group')->nullable();
            $table->integer('capacity');
            $table->integer('enrolled')->default(0);
            $table->time('schedule_time')->nullable();
            $table->string('schedule_day')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sections');
    }
};