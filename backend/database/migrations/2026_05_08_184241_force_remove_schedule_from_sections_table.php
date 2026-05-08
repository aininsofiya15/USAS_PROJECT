<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement(
            "ALTER TABLE sections
             DROP COLUMN schedule_time"
        );

        DB::statement(
            "ALTER TABLE sections
             DROP COLUMN schedule_day"
        );
    }

    public function down(): void
    {

    }
};