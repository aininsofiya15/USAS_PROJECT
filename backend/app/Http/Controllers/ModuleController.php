<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ModuleController extends Controller
{

    // 1. Fetch all available modules to display
    public function index()
    {
        try {
            
            // Fetch all modules from the database
            $modules = DB::table('modules')
                // Select all main module details to display
                ->select(
                    'modules.id',
                    'modules.activity_name',
                    'modules.date_time',
                    'modules.capacity',
                    'modules.venue',
                    'modules.lecturer_name',
                    'modules.description',
                    'modules.whatsapp_link',
                    'modules.pic_contact',
                    'modules.status',
                    'modules.created_at',
                    'modules.updated_at'
                )

                // Count current registrations for each module
                ->selectSub(function ($query) {
                    $query->from('bookings')
                        ->selectRaw('COUNT(*)')
                        ->whereColumn('bookings.module_id', 'modules.id');
                }, 'current_registration')
                ->get();

            // Return JSON payload response with module data
            return response()->json(['data' => $modules], 200);

        // Handle query execution exceptions and return error message
        } catch (\Exception $e) {
            // Log the error message if database query crashes
            Log::error("Fetch Modules Error: " . $e->getMessage());
            return response()->json(['error' => 'Failed to load modules'], 500);
        }
    }

    // 2. Update existing module details 
    public function update(Request $request)
    {
        // Validate the incoming request data for module update
        $request->validate([
            'id' => 'required|integer|exists:modules,id',
            'activity_name' => 'required|string|max:255',
            'date_time' => 'required|date',
            'capacity' => 'required|integer|min:1',
            'venue' => 'required|string|max:255',
            'lecturer_name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'whatsapp_link' => 'nullable|string|max:255',
            'pic_contact' => 'nullable|string|max:255',
            'status' => 'required|in:draft,published',
        ]);

        // Get the module ID from the request to update
        $id = $request->input('id');

        // Validate the presence of module ID, if missing return error message
        if (!$id) {
            return response()->json(['message' => 'Module ID is missing!'], 400);
        }

        try {
            // Update the module record in the database with the new input values
            DB::table('modules')
                ->where('id', $id)
                ->update([
                    'activity_name' => $request->input('activity_name'),
                    'date_time'     => $request->input('date_time'),
                    'capacity'      => $request->input('capacity'),
                    'venue'         => $request->input('venue'),
                    'lecturer_name' => $request->input('lecturer_name'),
                    'description'   => $request->input('description'),
                    'whatsapp_link' => $request->input('whatsapp_link'),
                    'pic_contact'   => $request->input('pic_contact'),
                    'status'        => $request->input('status'), 
                    'updated_at'    => now(),
                ]);

            // Return success message after successful update
            return response()->json(['message' => 'Module updated successfully!'], 200);

        // Handle query execution exceptions and return error message
        } catch (\Exception $e) {
            return response()->json(['message' => 'Database Error: ' . $e->getMessage()], 500);
        }
    }

    // 3. Create and store a new created module 
    public function store(Request $request)
    {
        // Validate the incoming request data for new module 
        $validated = $request->validate([
            'activity_name' => 'required|string|max:255',
            'date_time' => 'required|date',
            'capacity' => 'required|integer|min:1',
            'venue' => 'required|string|max:255',
            'lecturer_name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'whatsapp_link' => 'nullable|string|max:255',
            'pic_contact' => 'nullable|string|max:255',
            'status' => 'required|in:draft,published',
        ]);

        try {
            // Insert a new module record into the database with the input
            DB::table('modules')->insert([
                'activity_name' => $validated['activity_name'],
                'date_time'     => $validated['date_time'],
                'capacity'      => $validated['capacity'],
                'venue'         => $validated['venue'],
                'lecturer_name' => $validated['lecturer_name'],
                'description'   => $validated['description'] ?? null,
                'whatsapp_link' => $validated['whatsapp_link'] ?? null,
                'pic_contact'   => $validated['pic_contact'] ?? null,
                'status'        => $validated['status'],
                'created_at'    => now(),
                'updated_at'    => now(),
            ]);
            
            // Return success message after successful creation
            return response()->json(['message' => 'Module Created!'], 201);

        // Handle query execution exceptions and return error message
        } catch (\Exception $e) {
            // Return error trace string if fields assignment fails validation
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
