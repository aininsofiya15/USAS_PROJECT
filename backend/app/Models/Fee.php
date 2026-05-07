<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Fee extends Model
{
    protected $fillable = [
    'student_id',
    'total_fee',
    'paid_amount',
    'outstanding_amount',
    'status'
];
}
