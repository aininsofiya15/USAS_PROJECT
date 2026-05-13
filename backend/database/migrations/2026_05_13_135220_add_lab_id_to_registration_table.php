<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('registration', function (Blueprint $table) {

            $table->unsignedBigInteger('lab_id')
                  ->nullable()
                  ->after('section_id');

        });
    }

    public function down(): void
    {
        Schema::table('registration', function (Blueprint $table) {

            $table->dropColumn('lab_id');

        });
    }
};