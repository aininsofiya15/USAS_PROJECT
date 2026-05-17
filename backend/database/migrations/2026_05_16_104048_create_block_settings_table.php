<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('block_settings', function (Blueprint $table) {
            $table->id('block_id'); // Auto-incrementing Primary Key
            $table->string('treasurer_id'); // String column matching treasurers.treasurer_id
            $table->date('block_date'); // Date column for the selected block date
            $table->timestamps();

            // Setup the Foreign Key constraint pointing to the string column on treasurers
            $table->foreign('treasurer_id')
                  ->references('treasurer_id')
                  ->on('treasurers')
                  ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('block_settings');
    }
};