<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::create('module_attendances', function (Blueprint $table) {
        $table->id();
        $table->foreignId('attendance_id')->constrained('attendances')->onDelete('cascade'); 
        
        $table->unsignedBigInteger('module_id');  // Tracks the ID from modules table
        $table->date('date')->nullable();
        $table->time('time')->nullable();
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
