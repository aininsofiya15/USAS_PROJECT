<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $primaryKey = 'payment_id';
    protected $keyType = 'string';

    public $incrementing = false;

    protected $fillable = [
        'payment_id',
        'student_id',
        'fee_id',
        'total_payment',
        'amount',
        'payment_desc',
        'payment_method',
        'status',
        'payment_date'
    ];
}