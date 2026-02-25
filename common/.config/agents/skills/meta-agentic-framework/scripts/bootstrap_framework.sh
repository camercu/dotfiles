#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.}"
phase_id="${2:-phase-001}"
root="${target_dir%/}/.meta-framework"
phase_dir="${root}/phases/${phase_id}"

mkdir -p "${phase_dir}"

create_file_if_missing() {
  local path="$1"
  local title="$2"
  if [[ ! -f "${path}" ]]; then
    cat > "${path}" <<EOF
# ${title}

EOF
  fi
}

create_file_if_missing "${root}/PROJECT.md" "project"
create_file_if_missing "${root}/REQUIREMENTS.md" "requirements"
create_file_if_missing "${root}/ROADMAP.md" "roadmap"
create_file_if_missing "${root}/STATE.md" "state"
create_file_if_missing "${root}/DECISIONS.md" "decisions"

create_file_if_missing "${phase_dir}/CONTEXT.md" "${phase_id} context"
create_file_if_missing "${phase_dir}/RESEARCH.md" "${phase_id} research"
create_file_if_missing "${phase_dir}/SPEC.md" "${phase_id} specification"
create_file_if_missing "${phase_dir}/PLAN.md" "${phase_id} plan"
create_file_if_missing "${phase_dir}/SUMMARY.md" "${phase_id} summary"
create_file_if_missing "${phase_dir}/VERIFICATION.md" "${phase_id} verification"

echo "Initialized framework artifacts at: ${root}"
echo "Phase scaffold ready at: ${phase_dir}"
