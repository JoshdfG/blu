// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Error {
    // ERRORS
    error not_Autorized_Caller();
    error Attendance_compilation_started();
    error Already_Signed_Attendance();
    error already_requested();
    error not_valid_Moderator();
    error not_valid_lecture_id();
    error outside_allowed_hours();
    error NOT_MODERATOR();
    error NOT_MODERATOR_ON_DUTY();
    error NOT_STAFF();
    error staff_not_found();
    error attendance_cannot_be_closed();
    error attendance_already_closed();
    error NOT_ACTIVE_STAFF();
}
