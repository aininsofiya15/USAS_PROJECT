<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('section_id')->references('section_id')->on('sections')->onDelete('cascade');
            $table->string('attendance_code');
            $table->decimal('geo_lat', 10, 8)->nullable();
            $table->decimal('geo_long', 11, 8)->nullable();
            $table->integer('geo_radius')->default(500); // Fixed at 500m
            $table->date('date');
            $table->time('time');
            $table->timestamps();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};