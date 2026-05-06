<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Module extends Model
{
    use HasFactory;

    protected $fillable = [
        'activity_name',
        'date_time',
        'capacity',
        'venue',
        'lecturer_name',
        'description',
        'whatsapp_link',
        'pic_contact',
        'status',
        'current_registration',
    ];
}