<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth; // <-- CRITICAL: Is this here?

class AuthController extends Controller
{
    public function login(Request $request)
{
    // 1. Get credentials and trim the email just in case
    $credentials = [
        'email' => trim($request->email),
        'password' => $request->password,
    ];

    // 2. DEBUG: Check if the user even exists in the database first
    $user = \App\Models\User::where('email', $credentials['email'])->first();

    if (!$user) {
        return response()->json([
            'success' => false,
            'message' => 'Debug: Email not found in database',
        ], 404);
    }

    // 3. Try to authenticate
    if (Auth::attempt($credentials)) {
        $user = Auth::user();
        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'role' => $user->role,
            ]
        ], 200);
    }

    // 4. If we reach here, the email was found but the password failed
    return response()->json([
        'success' => false,
        'message' => 'Debug: Password does not match',
    ], 401);
}
}