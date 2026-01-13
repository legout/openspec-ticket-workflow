#!/usr/bin/env bash
# ralph.sh — External autonomous execution with full process isolation
#
# Each ticket gets a completely fresh OpenCode process, ensuring:
# - No context pollution from previous tickets
# - Clean slate for each implementation cycle
# - Maximum reliability for long-running autonomous sessions
#
# Usage:
#   ./ralph.sh                    # Process all ready tickets
#   ./ralph.sh --epic <epic-id>   # Process tickets in one epic
#   ./ralph.sh --max-cycles 20    # Limit total iterations
#   ./ralph.sh --dry-run          # Show what would run without executing
#
# Requirements:
#   - opencode CLI installed and in PATH
#   - tk (ticket) CLI installed
#   - jq for JSON parsing

set -euo pipefail

# =============================================================================
# CONFIG
# =============================================================================
MAX_CYCLES=50
EPIC_FILTER=""
DRY_RUN=false
REVIEW_ENABLED=true
LOG_FILE="ralph.log"

# =============================================================================
# PARSE ARGS
# =============================================================================
while [[ $# -gt 0 ]]; do
  case "$1" in
    --epic)
      EPIC_FILTER="$2"
      shift 2
      ;;
    --max-cycles)
      MAX_CYCLES="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-review)
      REVIEW_ENABLED=false
      shift
      ;;
    --help|-h)
      echo "ralph.sh — Autonomous ticket execution with full process isolation"
      echo ""
      echo "Usage: ./ralph.sh [options]"
      echo ""
      echo "Options:"
      echo "  --epic <id>       Process only tickets under this epic"
      echo "  --max-cycles N    Stop after N tickets (default: 50)"
      echo "  --no-review       Skip /tk-review step"
      echo "  --dry-run         Show what would run without executing"
      echo "  --help            Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# =============================================================================
# HELPERS
# =============================================================================
log() {
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$msg"
  echo "$msg" >> "$LOG_FILE"
}

get_next_ticket() {
  if [[ -n "$EPIC_FILTER" ]]; then
    # Get ready tickets under the epic
    tk query ".parent == \"$EPIC_FILTER\" and .status != \"closed\"" 2>/dev/null | \
      jq -r '.[].id' | \
      while read -r id; do
        if tk ready 2>/dev/null | grep -q "^$id "; then
          echo "$id"
          return
        fi
      done
  else
    # Get first ready ticket
    tk ready 2>/dev/null | head -1 | awk '{print $1}'
  fi
}

run_opencode() {
  local cmd="$1"
  if [[ "$DRY_RUN" == "true" ]]; then
    log "[DRY-RUN] Would execute: opencode \"$cmd\""
    return 0
  fi
  
  log "Executing: opencode \"$cmd\""
  
  # Run opencode with the command
  # Using --yes to auto-confirm, --no-input for non-interactive
  if opencode --yes "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
    return 0
  else
    log "ERROR: opencode command failed"
    return 1
  fi
}

check_for_p0_fix() {
  # Check if any P0 fix tickets were just created
  local p0_fixes
  p0_fixes=$(tk query '.priority == 0 and (.tags // []) | any(. == "review-fix")' 2>/dev/null | jq -r '.[].id' || true)
  
  if [[ -n "$p0_fixes" ]]; then
    log "CRITICAL: P0 fix ticket(s) found: $p0_fixes"
    return 0  # true, found P0
  fi
  return 1  # false, no P0
}

# =============================================================================
# MAIN LOOP
# =============================================================================
main() {
  log "=========================================="
  log "ralph.sh starting"
  log "  Max cycles: $MAX_CYCLES"
  log "  Epic filter: ${EPIC_FILTER:-none}"
  log "  Review enabled: $REVIEW_ENABLED"
  log "  Dry run: $DRY_RUN"
  log "=========================================="
  
  local cycles=0
  local processed=()
  
  while [[ $cycles -lt $MAX_CYCLES ]]; do
    # Get next ticket
    local ticket
    ticket=$(get_next_ticket)
    
    if [[ -z "$ticket" ]]; then
      log "Queue empty. Exiting."
      break
    fi
    
    log ""
    log "=== Cycle $cycles: Processing $ticket ==="
    
    # STEP 1: Start (fresh process)
    log "Step 1/3: /tk-start $ticket"
    if ! run_opencode "/tk-start $ticket"; then
      log "ERROR: /tk-start failed for $ticket"
      break
    fi
    
    # STEP 2: Done (fresh process)
    log "Step 2/3: /tk-done $ticket"
    if ! run_opencode "/tk-done $ticket"; then
      log "ERROR: /tk-done failed for $ticket"
      break
    fi
    
    # STEP 3: Review (fresh process, if enabled)
    if [[ "$REVIEW_ENABLED" == "true" ]]; then
      log "Step 3/3: /tk-review $ticket"
      if ! run_opencode "/tk-review $ticket"; then
        log "WARNING: /tk-review failed for $ticket (continuing)"
      fi
      
      # Check for critical issues
      if check_for_p0_fix; then
        log "Stopping for human review of P0 issue."
        break
      fi
    else
      log "Step 3/3: Skipped (review disabled)"
    fi
    
    processed+=("$ticket")
    ((cycles++))
    
    log "Cycle $cycles complete: $ticket"
  done
  
  # Summary
  log ""
  log "=========================================="
  log "ralph.sh complete"
  log "  Cycles: $cycles"
  log "  Processed: ${processed[*]:-none}"
  if [[ $cycles -ge $MAX_CYCLES ]]; then
    log "  Exit reason: Max cycles reached"
  elif [[ -z "$(get_next_ticket)" ]]; then
    log "  Exit reason: Queue empty"
  else
    log "  Exit reason: Error or P0 issue"
  fi
  log "=========================================="
}

main "$@"
