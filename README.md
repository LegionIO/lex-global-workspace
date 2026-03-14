# lex-global-workspace

Global Workspace Theory modeling for the LegionIO brain-modeled cognitive architecture.

## What It Does

Implements Bernard Baars' Global Workspace Theory — the theory that consciousness operates as a central broadcast medium. A single-item global workspace holds the most salient content and broadcasts it to all specialized cognitive processors. Candidate items compete for workspace access based on salience. Once an item wins access, it is broadcast globally and held for a limited duration before re-competition begins.

Based on Baars' Global Workspace Theory and Dehaene's neuronal global workspace model.

## Usage

```ruby
client = Legion::Extensions::GlobalWorkspace::Client.new

# Submit candidate content to compete for workspace access
client.submit_to_workspace(
  content: { event: 'authentication_failure', severity: :high },
  source: :error_monitor,
  salience: 0.9,
  domain: :security
)
# => { success: true, item_id: "...", admitted_to_workspace: true, current_occupant: nil }

# Multiple candidates compete for the single workspace slot
client.submit_to_workspace(
  content: { task: 'pending_code_review' },
  source: :task_queue,
  salience: 0.5
)

# Run competition to determine the workspace occupant
client.run_competition
# => { winner: { content: {...}, source: :error_monitor }, winner_salience: 0.9,
#      competition_rounds: 3, losers_count: 1 }

# Broadcast current workspace content to all processors
client.broadcast
# => { broadcast_id: "...", content: { event: 'authentication_failure' },
#      source: :error_monitor, salience: 0.9, recipients_count: 8 }

# Query the current workspace content
client.workspace_content
# => { content: {...}, source: :error_monitor, salience: 0.9, ticks_held: 2 }

# Check competition pressure
client.workspace_load
# => { occupied: true, candidate_count: 3, competition_pressure: :high }

# Periodic tick: decay candidates, re-compete if duration exceeded
client.update_global_workspace
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
