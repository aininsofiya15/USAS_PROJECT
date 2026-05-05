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
        Schema::create('pusat_adab', function (Blueprint $table) {
            $table->id();
            $table->string('adab_id', 50)->unique();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // This connects to the users table
            $table->timestamps();

            });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pusat_adab');
    }
};
