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
        Schema::create('modules', function (Blueprint $table) {
            $table->id();
            // Default Fields
            $table->string('activity_name');
            $table->dateTime('date_time');
            $table->integer('capacity');
            $table->string('venue');
            $table->string('lecturer_name');

            // Additional Fields
            $table->text('description')->nullable();
            $table->string('whatsapp_link')->nullable();
            $table->string('pic_contact')->nullable();
            
            // Status for your buttons (Draft or Published)
            $table->enum('status', ['draft', 'published'])->default('draft');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('modules');
    }
};
