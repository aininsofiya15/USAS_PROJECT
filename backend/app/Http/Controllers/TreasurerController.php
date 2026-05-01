<?php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class TreasurerController extends Controller
{
    public function getStudentCount()
    {
        // Query to count users where role is 'student'
        $count = User::where('role', 'student')->count();

        return response()->json([
            'total_students' => $count
        ]);
    }
}