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
        Schema::create('module_attendances', function (Blueprint $table) {
            $table->id(); // PK: module_attendance_id
            
            // FK: Links to the parent ATTENDANCE table
            $table->foreignId('attendance_id')
                  ->constrained('attendances')
                  ->onDelete('cascade');

            // FK: Links to your Pusat ADAB booking
            $table->foreignId('booking_id')
                  ->constrained('bookings')
                  ->onDelete('cascade');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('module_attendances');
    }
};