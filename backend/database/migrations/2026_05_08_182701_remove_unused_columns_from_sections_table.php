<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sections', function (Blueprint $table) {

            $table->dropColumn([

                'lab_group',
                'enrolled',

            ]);
        });
    }

    public function down(): void
    {

    }
};