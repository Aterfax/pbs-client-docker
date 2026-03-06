#!/bin/bash

# Load the Cron validation functions.
script_dir=$(dirname "${BASH_SOURCE[0]}")

source $script_dir/../s6-services/backup/hooks_include
source $script_dir/../helper_scripts/hooks-validation-functions

create_tmp() {
    mktemp -d
}

cleanup_tmp() {
    rm -rf "$1"
}

print_test() {
    echo "Running: $1"
}


########################################
print_test "nonexistent directory returns success"

tmp=$(create_tmp)

set +e
run_hook_dir "$tmp/missing"
rc=$?
set -e

assert_equals 0 "$rc"

cleanup_tmp "$tmp"


########################################
print_test "empty directory runs successfully"

tmp=$(create_tmp)

set +e
run_hook_dir "$tmp"
rc=$?
set -e

assert_equals 0 "$rc"

cleanup_tmp "$tmp"


########################################
print_test "non executable files are skipped"

tmp=$(create_tmp)

cat > "$tmp/test.sh" <<EOF
#!/usr/bin/env bash
echo hello
EOF

output=$(run_hook_dir "$tmp")

assert_contains "$output" "skip (not executable)"

cleanup_tmp "$tmp"


########################################
print_test "non bash scripts are skipped"

tmp=$(create_tmp)

cat > "$tmp/test.sh" <<EOF
#!/bin/sh
echo hello
EOF

chmod +x "$tmp/test.sh"

output=$(run_hook_dir "$tmp")

assert_contains "$output" "skip (not bash)"

cleanup_tmp "$tmp"


########################################
print_test "bash hook executes successfully"

tmp=$(create_tmp)

cat > "$tmp/test.sh" <<EOF
#!/usr/bin/env bash
echo executed
EOF

chmod +x "$tmp/test.sh"

output=$(run_hook_dir "$tmp")

assert_contains "$output" "executed"
assert_contains "$output" "ok"

cleanup_tmp "$tmp"


########################################
print_test "failing hook does not propagate failure"

tmp=$(create_tmp)

cat > "$tmp/fail.sh" <<EOF
#!/usr/bin/env bash
exit 1
EOF

chmod +x "$tmp/fail.sh"

set +e
run_hook_dir "$tmp"
rc=$?
set -e

assert_equals 0 "$rc"

cleanup_tmp "$tmp"


########################################
print_test "timeout is enforced"

tmp=$(create_tmp)

cat > "$tmp/sleep.sh" <<EOF
#!/usr/bin/env bash
sleep 5
EOF

chmod +x "$tmp/sleep.sh"

export HOOK_TIMEOUT=1

output=$(run_hook_dir "$tmp")

echo "$output"

assert_contains "$output" "Timed out"

cleanup_tmp "$tmp"


########################################
print_test "hooks execute in lexicographic order with mixed names"

tmp=$(create_tmp)

# Standard numeric-prefix hooks
for name in 000 010 110 111; do
    cat > "$tmp/${name}-myscript.sh" <<EOF
#!/usr/bin/env bash
echo $name
EOF
done

# Random other names
for name in alpha beta zeta 001x gamma; do
    cat > "$tmp/${name}.sh" <<EOF
#!/usr/bin/env bash
echo $name
EOF
done

chmod +x "$tmp/"*.sh

# Run hooks
output=$(run_hook_dir "$tmp")

# Extract only lines containing "[user-hooks] run"
executed=$(echo "$output" | grep '\[user-hooks\] run' | awk '{print $NF}')

echo "$executed"

# Convert to basenames without .sh
readarray -t executed_array <<< "$executed"
for i in "${!executed_array[@]}"; do
    executed_array[$i]=$(basename "${executed_array[$i]%.sh}")
done

# Expected lexicographic order (full names, ASCII)
expected_order=(000-myscript 001x 010-myscript 110-myscript 111-myscript alpha beta gamma zeta)

# Compare arrays
for i in "${!expected_order[@]}"; do
    if [[ "${executed_array[$i]}" != "${expected_order[$i]}" ]]; then
        echo "ASSERT FAIL at position $i: expected '${expected_order[$i]}', got '${executed_array[$i]}'"
        cleanup_tmp "$tmp"
        exit 1
    fi
done
echo "Test passed!"
echo

cleanup_tmp "$tmp"

########################################
print_test "filenames with spaces work"

tmp=$(create_tmp)

cat > "$tmp/test hook.sh" <<EOF
#!/usr/bin/env bash
echo spaced
EOF

chmod +x "$tmp/test hook.sh"

output=$(run_hook_dir "$tmp")

assert_contains "$output" "spaced"

cleanup_tmp "$tmp"


########################################

print_test "directories inside hookdir are ignored"

tmp=$(create_tmp)

mkdir "$tmp/subdir"

set +e
run_hook_dir "$tmp"
rc=$?
set -e

assert_equals 0 "$rc"

cleanup_tmp "$tmp"

########################################

echo "All hook validation tests passed"