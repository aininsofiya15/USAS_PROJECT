<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('block_settings')) {

            Schema::create('block_settings', function (Blueprint $table) {
                $table->id('block_id');
                $table->string('treasurer_id');
                $table->date('block_date');
                $table->timestamps();

                $table->foreign('treasurer_id')
                      ->references('treasurer_id')
                      ->on('treasurers')
                      ->onDelete('cascade');
            });

        }
    }

    public function down(): void
    {
        Schema::dropIfExists('block_settings');
    }
};