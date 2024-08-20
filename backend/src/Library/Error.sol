// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Error {
    // ERRORS
    error lecture_id_already_used();
    error not_Autorized_Caller();
    error Invalid_Lecture_Id();
    error Lecture_id_closed();
    error Attendance_compilation_started();
    error Already_Signed_Attendance();
    error already_requested();
    error not_valid_student();
    error not_valid_Moderator();
    error not_valid_lecture_id();
    error outside_allowed_hours();
    error NOT_MODERATOR();
    error NOT_MODERATOR_ON_DUTY();
    error NOT_STAFF();
}
