#!/bin/bash

# Load the Cron validation functions.
script_dir=$(dirname "${BASH_SOURCE[0]}")
source $script_dir/../helper_scripts/cron-validation-functions

# Test valid cron expressions
assert_valid_cron "@annually"
assert_valid_cron "@yearly"
assert_valid_cron "@monthly"
assert_valid_cron "@weekly"
assert_valid_cron "@daily"
assert_valid_cron "@hourly"
assert_valid_cron "@reboot"

assert_valid_cron "0 */4 * * *"
assert_valid_cron "*/5 * * * *"
assert_valid_cron "* */5 * * *"
assert_valid_cron "*/5 */5 * * *"
assert_valid_cron "0 0 12 * * ?"
assert_valid_cron "0 15 10 ? * *"
assert_valid_cron "0 15 10 ? * MON-FRI"
assert_valid_cron "0 15 10 ? * 6L"
assert_valid_cron "0 15 10 ? * 6L 2022-2024"
assert_valid_cron "0 15 10 ? * 6#3"
assert_valid_cron "0 11 11 11 11 ?"

# Test invalid cron expressions
assert_invalid_cron "invalid expression"
assert_invalid_cron "@invalid"
assert_invalid_cron "0\15 0 * * ?"