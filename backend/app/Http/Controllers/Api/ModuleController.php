<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Module; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ModuleController extends Controller
{
    /**
     * Store a newly created module in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'activity_name' => 'required|string|max:255',
            'date_time' => 'required',
            'capacity' => 'required|integer',
            'venue' => 'required|string',
            'lecturer_name' => 'required|string',
            'status' => 'in:draft,published', // Matches your enum!
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $module = Module::create($request->all()); // This works because $fillable is set!

        return response()->json([
            'success' => true,
            'message' => 'Module saved as ' . $module->status,
            'data' => $module
        ], 201);
    }
}