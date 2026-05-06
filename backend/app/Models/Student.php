<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $fillable = [
        'student_id',
        'faculty',
        'course_name',
        'current_semester',
        'year',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'student_id');
    }

    /**
     * A student has one Fee record.
     */
    public function fee()
    {
        return $this->hasOne(StudentFee::class, 'student_id', 'student_id');
    }

    /**
     * A student has many Payments.
     */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'student_id', 'student_id');
    }

    /**
     * A student has one Bank Account.
     */
    public function bankAccount()
    {
        return $this->hasOne(BankAccount::class, 'student_id', 'student_id');
    }
}