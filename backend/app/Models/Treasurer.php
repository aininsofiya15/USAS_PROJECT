<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Treasurer extends Model
{
    protected $primaryKey = 'id'; 
    public $incrementing = false; // Because it uses the User ID
    protected $fillable = ['id', 'treasurer_id', 'department'];
}