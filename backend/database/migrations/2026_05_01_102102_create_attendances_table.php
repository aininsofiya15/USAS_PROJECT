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
            //$table->foreignId('booking_id')->references('id')->on('bookings')->onDelete('cascade');
            $table->string('attendance_code');
            $table->decimal('geo_lat', 10, 8)->nullable();
            $table->decimal('geo_long', 11, 8)->nullable();
            $table->integer('geo_radius')->nullable();
            $table->dateTime('time_validity');  // Changed from integer to dateTime if it's a timestamp
            $table->timestamps();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};