<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('labs', function (Blueprint $table) {

            $table->string('schedule_day')
                  ->nullable();

            $table->string('schedule_time')
                  ->nullable();

        });
    }

    public function down(): void
    {

    }
};