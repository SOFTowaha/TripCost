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
PROJECT_ID=$(gh project list --owner "$OWNER" --format json | jq -r ".[] | select(.title==\"$PROJECT_NAME\") | .id")
if [[ -z "$PROJECT_ID" ]]; then
  gh project create "$PROJECT_NAME" --owner "$OWNER" --public >/dev/null
  PROJECT_ID=$(gh project list --owner "$OWNER" --format json | jq -r ".[] | select(.title==\"$PROJECT_NAME\") | .id")
  echo "Created project: $PROJECT_NAME ($PROJECT_ID)"
else
  echo "Found project: $PROJECT_NAME ($PROJECT_ID)"
fi

echo "Adding project fields (Iteration, Priority) if missing..."
# Create Iteration field
ITER_FIELD_ID=$(gh project field-list "$PROJECT_ID" --owner "$OWNER" --format json | jq -r '.fields[] | select(.name=="Iteration") | .id' 2>/dev/null || true)
if [[ -z "$ITER_FIELD_ID" || "$ITER_FIELD_ID" == "null" ]]; then
  gh project field-create "$PROJECT_ID" --owner "$OWNER" --name "Iteration" --data-type ITERATION >/dev/null
  ITER_FIELD_ID=$(gh project field-list "$PROJECT_ID" --owner "$OWNER" --format json | jq -r '.fields[] | select(.name=="Iteration") | .id')
fi
# Create Priority field (single-select)
PRIO_FIELD_ID=$(gh project field-list "$PROJECT_ID" --owner "$OWNER" --format json | jq -r '.fields[] | select(.name=="Priority") | .id' 2>/dev/null || true)
if [[ -z "$PRIO_FIELD_ID" || "$PRIO_FIELD_ID" == "null" ]]; then
  gh project field-create "$PROJECT_ID" --owner "$OWNER" --name "Priority" --data-type SINGLE_SELECT --option "P0" --option "P1" --option "P2" >/dev/null
  PRIO_FIELD_ID=$(gh project field-list "$PROJECT_ID" --owner "$OWNER" --format json | jq -r '.fields[] | select(.name=="Priority") | .id')
fi

echo "Creating iterations..."
gh project iteration-create "$PROJECT_ID" --owner "$OWNER" --title "Sprint 1" --duration 14 >/dev/null || true
gh project iteration-create "$PROJECT_ID" --owner "$OWNER" --title "Sprint 2" --duration 14 >/dev/null || true
gh project iteration-create "$PROJECT_ID" --owner "$OWNER" --title "Sprint 3" --duration 14 >/dev/null || true

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
  number=$(gh issue create -R "$OWNER/$REPO" -t "$title" -b "$body" -l "$labels" --json number -q .number)
  echo "  #$number"
  # Add to project backlog
  gh project item-add "$PROJECT_ID" --owner "$OWNER" --url "https://github.com/$OWNER/$REPO/issues/$number" >/dev/null
done

echo "Done. Project: $PROJECT_NAME"
