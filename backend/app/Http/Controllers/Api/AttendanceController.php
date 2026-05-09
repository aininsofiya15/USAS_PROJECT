<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use App\Models\Attendance;
use App\Models\AttendanceRecord;
use App\Models\ModuleAttendance;

class AttendanceController extends Controller
{
    /**
     * Get subjects for a specific lecturer
     */
    public function getLecturerSubjects(Request $request)
    {
        $lecturerId = $request->query('user_id');

        if (!$lecturerId) {
            return response()->json(['success' => false, 'message' => 'Lecturer ID required'], 400);
        }

        // Using DB::table for a flatter, simpler structure like your Tuition controller
        $subjects = DB::table('subjects')
            ->join('sections', 'subjects.subject_id', '=', 'sections.subject_id')
            ->where('sections.lecturer_id', $lecturerId)
            ->select(
                'subjects.subject_id',
                'subjects.subject_code',
                'subjects.subject_name',
                'sections.section_id',
                'sections.section_no'
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => $subjects
        ]);
    }

    /**
     * Create a new attendance session
     */
    public function store(Request $request)
    {
        $request->validate([
            'section_id' => 'required',
            'geo_lat'    => 'required',
            'geo_long'   => 'required',
            'date'       => 'required|date',
            'time'       => 'required',
        ]);

        $code = strtoupper(Str::random(6));
        $time24 = date('H:i:s', strtotime($request->time));

        $attendanceId = DB::table('attendances')->insertGetId([
            'section_id'      => $request->section_id,
            'attendance_code' => $code,
            'geo_lat'         => $request->geo_lat,
            'geo_long'        => $request->geo_long,
            'geo_radius'      => 500,
            'date'            => $request->date,
            'time'            => $time24,
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        return response()->json([
            'success' => true,
            'code'    => $code,
            'attendance_id' => $attendanceId
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