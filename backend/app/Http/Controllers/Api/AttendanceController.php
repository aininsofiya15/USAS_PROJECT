<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use App\Models\Attendance;

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
     * Get list of students who signed in for a session
     */
    public function getAttendanceDetails($sectionId)
    {
        // 1. Get the session info
        $session = DB::table('attendances')
            ->join('sections', 'attendances.section_id', '=', 'sections.section_id')
            ->join('subjects', 'sections.subject_id', '=', 'subjects.subject_id')
            ->where('attendances.section_id', $sectionId)
            ->select(
                'subjects.subject_name as activity_name',
                'sections.section_no',
                'attendances.id',
                'attendances.date',
                'attendances.time'
            )
            ->first();

        if (!$session) {
            return response()->json(['message' => 'No session found'], 404);
        }

        // 2. Get the student records via JOIN
        $records = DB::table('attendance_records')
            ->join('students', 'attendance_records.student_id', '=', 'students.id')
            ->join('users', 'students.id', '=', 'users.id')
            ->where('attendance_records.attendance_id', $session->id)
            ->select(
                'users.name',
                'students.student_id as matric_no',
                'attendance_records.status',
                'attendance_records.created_at as check_in_time'
            )
            ->get();

        return response()->json([
            'header' => [
                'activity_name' => $session->activity_name,
                'section'       => $session->section_no,
                'date_time'     => $session->date . ' ' . $session->time,
                'student_count' => $records->count(),
            ],
            'records' => $records
        ]);
    }
}