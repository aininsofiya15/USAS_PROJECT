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
        Schema::create('registration', function (Blueprint $table) {
            $table->id('registration_id');

            $table->foreignId('student_id')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('cascade');

            $table->foreignId('section_id')
                  ->nullable()
                  ->constrained('sections')
                  ->onDelete('cascade');

            $table->enum('status', ['active', 'dropped'])
                  ->default('active');

            $table->dateTime('registered_at')
                  ->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registration');
    }
};