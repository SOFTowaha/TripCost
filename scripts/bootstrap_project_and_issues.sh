#!/usr/bin/env bash
set -euo pipefail

# Bootstrap GitHub labels, a Project (Kanban) with Iterations, and issues
# Requires: GitHub CLI (gh) authenticated with repo and project permissions.

OWNER="SOFTowaha"
REPO="TripCost"
PROJECT_NAME="TripCost Roadmap"

echo "Checking GitHub CLI authentication..."
gh auth status -h github.com >/dev/null || {
  echo "Please run: gh auth login" >&2; exit 1;
}

echo "Creating labels (idempotent)..."
gh label create "type:feature" -c "#1D76DB" -d "New feature" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "triage"        -c "#BFD4F2" -d "Needs triage" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:map"      -c "#0E8A16" -d "Map & routing" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:notes"    -c "#5319E7" -d "Notes & lists" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:camping"  -c "#FBCA04" -d "Camping & outdoor" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:expenses" -c "#F7C6C7" -d "Expenses & budget" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:gear"     -c "#0052CC" -d "Gear & equipment" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:group"    -c "#D93F0B" -d "Group features" -R "$OWNER/$REPO" 2>/dev/null || true
gh label create "area:core"     -c "#CCCCCC" -d "Core app" -R "$OWNER/$REPO" 2>/dev/null || true

echo "Creating Project (user-level) if missing..."
# Helper to find the newest project number matching title (handles different JSON shapes)
get_project_number() {
  local title="$1"
  # Shape 1: { "projects": [ ... ] }
  gh project list --owner "$OWNER" --format json 2>/dev/null \
    | jq -r --arg t "$title" '.projects[]? | select(.title==$t) | .number' \
    | sort -nr | head -n1
}

# Prefer project number for subsequent CLI commands
PROJECT_NUMBER=$(get_project_number "$PROJECT_NAME" || true)
if [[ -z "${PROJECT_NUMBER:-}" ]]; then
  # Create the project and derive number from returned URL or by re-listing
  create_out=$(gh project create --owner "$OWNER" --title "$PROJECT_NAME" 2>/dev/null || true)
  # Attempt to parse URL for number, e.g., https://github.com/users/OWNER/projects/123
  if [[ -n "${create_out:-}" && "$create_out" =~ /projects/([0-9]+) ]]; then
    PROJECT_NUMBER="${BASH_REMATCH[1]}"
  fi
  # Fallback: re-list to get the newest one by title
  if [[ -z "${PROJECT_NUMBER:-}" ]]; then
    PROJECT_NUMBER=$(get_project_number "$PROJECT_NAME")
  fi
  echo "Created project: $PROJECT_NAME (#$PROJECT_NUMBER)"
else
  echo "Found project: $PROJECT_NAME (#$PROJECT_NUMBER)"
fi

echo "Adding project fields (Iteration, Priority) if missing..."
# Create Iteration field (use SINGLE_SELECT since ITERATION type is not supported in all gh CLI versions)
ITER_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json 2>/dev/null | jq -r '.fields[]? | select(.name=="Iteration") | .id' || true)
if [[ -z "${ITER_FIELD_ID:-}" || "$ITER_FIELD_ID" == "null" ]]; then
  echo "  Creating Iteration field as SINGLE_SELECT with Sprint options"
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" --name "Iteration" --data-type SINGLE_SELECT --single-select-options "Sprint 1,Sprint 2,Sprint 3" >/dev/null 2>&1 || true
  ITER_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json 2>/dev/null | jq -r '.fields[]? | select(.name=="Iteration") | .id')
fi
# Create Priority field (single-select)
PRIO_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json 2>/dev/null | jq -r '.fields[]? | select(.name=="Priority") | .id' || true)
if [[ -z "${PRIO_FIELD_ID:-}" || "$PRIO_FIELD_ID" == "null" ]]; then
  echo "  Creating Priority field as SINGLE_SELECT"
  gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" --name "Priority" --data-type SINGLE_SELECT --single-select-options "P0,P1,P2" >/dev/null 2>&1 || true
  PRIO_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json 2>/dev/null | jq -r '.fields[]? | select(.name=="Priority") | .id')
fi

echo "Skipping CLI iteration creation (gh project iteration-create not supported in all versions)"
echo "  Sprints are available as Iteration field options: Sprint 1, Sprint 2, Sprint 3"

echo "Creating issues from README Future Plans..."
# Define issues (title|labels|body)
issues=(
  "Favorite routes and destinations|type:feature,area:map|Let users star/favorite routes and destinations for quick access."
  "Export trip data to PDF/CSV|type:feature,area:core|Export trips to PDF/CSV with summary, route, and cost breakdown."
  "Nearby attractions and Food|type:feature,area:map|Show nearby attractions and food options along the route."
  "Notes feature for trip planning|type:feature,area:notes|Add notes to trips and general planning notes with formatting."
  "Packing lists (food, clothing, gear)|type:feature,area:notes|Create reusable packing lists; check-off items."
  "Camping checklist templates|type:feature,area:notes|Provide templates for camping checklists."
  "Trail-specific notes and tips|type:feature,area:notes|Allow adding notes scoped to a trail with tips and cautions."
  "Campground finder integration|type:feature,area:camping|Integrate campground search APIs and show availability."
  "Trail difficulty ratings|type:feature,area:camping|Display trail difficulty and recommend gear accordingly."
  "Weather forecasts for destinations|type:feature,area:camping|Show weather forecasts for trip destinations."
  "Hiking distance and elevation tracking|type:feature,area:camping|Track hiking distance and elevation profiles."
  "Wildlife and safety alerts|type:feature,area:camping|Provide safety alerts and wildlife notices for areas."
  "Camping gear costs|type:feature,area:expenses|Track camping gear purchase costs for trip budgeting."
  "Park entrance fees|type:feature,area:expenses|Add park entrance fees into trip expenses."
  "Equipment rental tracking|type:feature,area:expenses|Track rental equipment costs with dates and vendors."
  "Per-day expense breakdown|type:feature,area:expenses|View expenses per-day for multi-day trips."
  "Gear checklist manager|type:feature,area:gear|Manage gear checklists and statuses."
  "Equipment weight calculator|type:feature,area:gear|Calculate total carry weight based on gear list."
  "Gear recommendations by trip type|type:feature,area:gear|Recommend gear for camping/hiking road trips."
  "Shared gear tracking for group trips|type:feature,area:gear|Track which person carries which shared gear."
  "Task assignments|type:feature,area:group|Assign tasks to group members (shopping, setup, driving)."
  "Real-time trip updates|type:feature,area:group|Share live updates for route/status (if online)."
  "Offline maps support|type:feature,area:map|Allow maps to be cached for offline usage."
  "Weather Forecast|type:feature,area:camping|General weather forecast widgets in the app."
  "Image Upload/Save|type:feature,area:core|Attach photos to trips; store references locally."
  "GPS tracking during trips|type:feature,area:map|Log GPS tracks during trips for later review."
  "Photo gallery per trip|type:feature,area:core|Gallery view for photos associated with a trip."
  "Trip timeline/itinerary builder|type:feature,area:core|Build a day-by-day trip itinerary and timeline."
  "Emergency contacts and info|type:feature,area:core|Store emergency contacts and key info per trip."
)

for spec in "${issues[@]}"; do
  IFS='|' read -r title labels body <<<"$spec"
  echo "Creating issue: $title"
  # Try JSON-friendly creation first (newer gh versions), then fall back to parsing URL output (older gh versions)
  number=""
  # Attempt JSON mode (ignore errors)
  json_out=$(gh issue create -R "$OWNER/$REPO" -t "$title" -b "$body" -l "$labels" --json number --jq .number 2>/dev/null || true)
  if [[ -n "$json_out" ]]; then
    number="$json_out"
  else
    # Fallback: create issue and parse the returned URL for the number
    url_out=$(gh issue create -R "$OWNER/$REPO" -t "$title" -b "$body" -l "$labels" 2>/dev/null | tail -n1 || true)
    if [[ -n "$url_out" ]]; then
      # Expect something like: https://github.com/OWNER/REPO/issues/123
      if [[ "$url_out" =~ /issues/([0-9]+) ]]; then
        number="${BASH_REMATCH[1]}"
      fi
    fi
  fi

  if [[ -n "$number" ]]; then
    echo "  #$number"
    # Add to project backlog
    gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "https://github.com/$OWNER/$REPO/issues/$number" >/dev/null || true
  else
    echo "  Warning: could not determine issue number for '$title'. It may still have been created." >&2
  fi
done

echo "Done. Project: $PROJECT_NAME"
