<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ModuleController extends Controller
{
    /**
     * Fetch all available co-curricular modules catalog
     */
    public function index()
    {
        try {
            $modules = DB::table('modules')
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
                ->selectSub(function ($query) {
                    $query->from('bookings')
                        ->selectRaw('COUNT(*)')
                        ->whereColumn('bookings.module_id', 'modules.id');
                }, 'current_registration')
                ->get();

            return response()->json(['data' => $modules], 200);
        } catch (\Exception $e) {
            Log::error("Fetch Modules Error: " . $e->getMessage());
            return response()->json(['error' => 'Failed to load modules'], 500);
        }
    }

    /**
     * Update module details (Pusat ADAB Admin)
     */
    public function update(Request $request)
    {
        $id = $request->input('id');

        if (!$id) {
            return response()->json(['message' => 'Module ID is missing!'], 400);
        }

        try {
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

            return response()->json(['message' => 'Module updated successfully!'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Database Error: ' . $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
{
    try {
        DB::table('modules')->insert([
            'activity_name' => $request->activity_name,
            'date_time'     => $request->date_time,
            'capacity'      => $request->capacity,
            'venue'         => $request->venue,
            'lecturer_name' => $request->lecturer_name,
            'status'        => 'published',
            'created_at'    => now(),
            'updated_at'    => now(),
        ]);
        return response()->json(['message' => 'Module Created!'], 201);
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
}
}
