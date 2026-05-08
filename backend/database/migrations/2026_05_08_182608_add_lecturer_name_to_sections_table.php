<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sections', function (Blueprint $table) {

            $table->string('lecturer_name')
                  ->after('section_no');

        });
    }

    public function down(): void
    {
        Schema::table('sections', function (Blueprint $table) {

            $table->dropColumn('lecturer_name');

        });
    }
};