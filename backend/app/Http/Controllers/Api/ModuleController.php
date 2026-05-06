<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Module; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ModuleController extends Controller
{
    /**
     * Fetch all modules ordered by the latest created.
     * High Cohesion: Only handles reading the module collection.
     */
    public function index()
    {
        $modules = Module::orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'success' => true,
            'data' => $modules
        ], 200);
    }

    /**
     * Store a newly created module in storage.
     * High Cohesion: Only handles validating and creating a new record.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'activity_name' => 'required|string|max:255',
            'date_time' => 'required',
            'capacity' => 'required|integer',
            'venue' => 'required|string',
            'lecturer_name' => 'required|string',
            'status' => 'in:draft,published', 
            'current_registration' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false, 
                'errors' => $validator->errors()
            ], 422);
        }

        $module = Module::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Module saved as ' . $module->status,
            'data' => $module
        ], 201);
    }

    /**
     * Update an existing module using its current activity name as the natural key identifier.
     * Low Coupling: Relies cleanly on request data payload values rather than fragile URL structures.
     */
    public function update(Request $request)
    {
        // 1. Grab the natural key tracking identifier out of the request body
        $currentName = $request->input('current_name');

        // 2. Query for the row instance matching the natural key
        $module = Module::where('activity_name', $currentName)->first();

        if (!$module) {
            return response()->json([
                'success' => false,
                'message' => 'Module not found: ' . $currentName
            ], 404);
        }

        // 3. Complete input field validation validation rules
        $validator = Validator::make($request->all(), [
            'activity_name' => 'required|string|max:255',
            'date_time' => 'required',
            'capacity' => 'required|integer',
            'venue' => 'required|string',
            'lecturer_name' => 'required|string',
            'status' => 'in:draft,published', 
            'current_registration' => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false, 
                'errors' => $validator->errors()
            ], 422);
        }

        // 4. Commit values update directly to database row instance
        $module->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Module updated successfully!',
            'data' => $module
        ], 200);
    }
}