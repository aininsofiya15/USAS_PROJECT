<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Models\Subject;
use App\Models\Section;
use App\Models\Attendance;
use App\Models\AttendanceRecord;
use App\Models\ModuleAttendance;

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

    /**
     * Fetch attendance details for a specific Pusat ADAB module session.
     * This follows the logic: Booking -> ModuleAttendance -> Attendance -> Records.
     */
    public function getPusatAdabAttendance($bookingId)
    {
        // 1. Find the bridge record linked to your specific booking
        // We load 'attendance' for the session info and 'booking.module' for the name
        $moduleSession = ModuleAttendance::where('booking_id', $bookingId)
            ->with(['attendance', 'booking.module'])
            ->first();

        if (!$moduleSession) {
            return response()->json([
                'message' => 'No attendance session found for this module.'
            ], 404);
        }

        // 2. Fetch the student list from the shared records table
        // We include 'student.user' to get their Name and Matric ID for your Flutter list
        $records = AttendanceRecord::where('attendance_id', $moduleSession->attendance_id)
            ->with(['student.user'])
            ->get();

        // 3. Format the response for your Flutter AttendanceSubject and AttendanceRecord domains
        return response()->json([
            'header' => [
                'id' => $moduleSession->booking->module->id,
                'activity_name' => $moduleSession->booking->module->activity_name,
                'venue' => $moduleSession->booking->module->venue,
                'date_time' => $moduleSession->attendance->created_at->format('d/m/Y h:i A'),
                'lecturer_name' => $moduleSession->booking->module->lecturer->user->name,
            ],

            'records' => $records->map(function ($record) {
                return [
                    'id' => $record->id,
                    'student_id' => $record->student->student_id,
                    'student_name' => $record->student->user->name,
                    'status' => $record->status,
                    'marks' => $record->marks,
                    'grade_category' => $record->grade_category,
                ];
            })
        ]);
    }
    /**
     * Update a student's grade/marks from the Flutter "Grade" button.
     */
    public function updateGrade(Request $request, $recordId)
    {
        $request->validate([
            'marks' => 'required|numeric|min:0|max:100',
        ]);

        $record = AttendanceRecord::findOrFail($recordId);
        $record->update([
            'marks' => $request->marks,
            // Logic to auto-assign category based on marks if needed
            'grade_category' => $request->marks >= 50 ? 'Pass' : 'Fail', 
        ]);

        return response()->json([
            'message' => 'Grade updated successfully',
            'record' => $record
        ]);
    }
}