<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Models\Subject;
use App\Models\Section;
use App\Models\Attendance;

class AttendanceController extends Controller
{
    public function getLecturerSubjects(Request $request)
    {
        // Use 'lecturer_id' instead of 'user_id' to match your migration
        $lecturerId = $request->query('user_id'); 

        if (!$lecturerId) {
            return response()->json(['success' => false, 'message' => 'Lecturer ID required'], 400);
        }

        $subjects = Subject::whereHas('sections', function ($query) use ($lecturerId) {
            $query->where('lecturer_id', $lecturerId); 
        })
        ->with(['sections' => function ($query) use ($lecturerId) {
            $query->where('lecturer_id', $lecturerId)
                ->select('section_id', 'subject_id', 'section_no');
        }])
        ->select('subject_id', 'subject_code', 'subject_name')
        ->get();

        return response()->json([
            'success' => true,
            'data'    => $subjects
        ], 200);
    }

    public function store(Request $request) {
    // 1. Validation
    $validated = $request->validate([
        'section_id' => 'required|exists:sections,section_id',
        'geo_lat'    => 'required',
        'geo_long'   => 'required',
        'date'       => 'required|date',
        'time'       => 'required',
    ]);

    // 2. Generate a random unique code
    $code = strtoupper(Str::random(6));
    // Convert 12-hour format (12:00 PM) to 24-hour format (12:00:00)
    $time24 = date('H:i:s', strtotime($request->time));

    // 3. Save to DB
    $attendance = Attendance::create([
        'section_id'      => $request->section_id,
        'attendance_code' => $code,
        'geo_lat'         => $request->geo_lat,
        'geo_long'        => $request->geo_long,
        'geo_radius'      => 500, // Always fixed at 500m
        'date'            => $request->date,
        'time'            => $time24, // converted to 24-hour
    ]);

    // 4. Return response matching your Provider's resData['code']
    return response()->json([
        'success' => true,
        'code'    => $code, 
        'data'    => $attendance
    ], 201);
}
}