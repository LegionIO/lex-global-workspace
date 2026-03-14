# lex-global-workspace

**Level 3 Documentation** — Parent: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## Purpose

Global Workspace Theory (GWT) modeling for the LegionIO cognitive architecture. Implements Bernard Baars' Global Workspace Theory — the theory of consciousness as a central broadcast medium. A limited-capacity global workspace holds the most salient content and broadcasts it to all specialized cognitive processors simultaneously. Manages competition between candidate items for workspace access, tracks broadcast history, and provides workspace access status to all other extensions.

Based on Baars' Global Workspace Theory and Dehaene's neuronal global workspace model.

## Gem Info

- **Gem name**: `lex-global-workspace`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::GlobalWorkspace`
- **Location**: `extensions-agentic/lex-global-workspace/`

## File Structure

```
lib/legion/extensions/global_workspace/
  global_workspace.rb           # Top-level requires
  version.rb                    # VERSION = '0.1.0'
  client.rb                     # Client class
  helpers/
    constants.rb                # WORKSPACE_CAPACITY, COALITION_THRESHOLD, BROADCAST_LABELS, thresholds
    workspace_item.rb           # WorkspaceItem: candidate for global access with salience
    broadcast.rb                # Broadcast value object: snapshot of workspace content at a moment
    global_workspace_engine.rb  # Engine: competition, selection, broadcast, access tracking
  runners/
    global_workspace.rb         # Runner module: all public methods
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `WORKSPACE_CAPACITY` | 1 | Global workspace holds only the single most salient item (GWT: one spotlight) |
| `COALITION_THRESHOLD` | 0.5 | Minimum salience to form a coalition competing for workspace access |
| `BROADCAST_STRENGTH` | 0.8 | Signal strength of workspace broadcasts to specialized processors |
| `COMPETITION_ROUNDS` | 3 | Rounds of inhibition-of-return in competition |
| `SALIENCE_DECAY` | 0.04 | Candidate item salience lost per cycle |
| `WORKSPACE_DURATION` | 5 | Ticks a single item holds workspace access before forced competition |
| `MAX_CANDIDATES` | 50 | Competition pool size cap |
| `MAX_BROADCAST_HISTORY` | 200 | Broadcast log cap |
| `BROADCAST_LABELS` | range hash | `dominant / strong / moderate / weak / absent` based on broadcast count |
| `SALIENCE_LABELS` | range hash | `highly_salient / salient / moderate / low / background` |

## Runners

All methods in `Legion::Extensions::GlobalWorkspace::Runners::GlobalWorkspace`.

| Method | Key Args | Returns |
|---|---|---|
| `submit_to_workspace` | `content:, source:, salience: 0.5, domain: nil` | `{ success:, item_id:, admitted_to_workspace:, current_occupant: }` |
| `run_competition` | — | `{ success:, winner:, winner_salience:, competition_rounds:, losers_count: }` |
| `broadcast` | — | `{ success:, broadcast_id:, content:, source:, salience:, recipients_count: }` |
| `workspace_content` | — | `{ success:, content:, source:, salience:, ticks_held:, salience_label: }` |
| `candidate_pool` | — | `{ success:, candidates:, count: }` (sorted by salience) |
| `broadcast_history` | `limit: 10` | `{ success:, broadcasts:, count: }` |
| `access_frequency` | `source: nil` | `{ success:, source:, access_count:, access_rate: }` |
| `workspace_load` | — | `{ success:, occupied:, candidate_count:, competition_pressure: }` |
| `update_global_workspace` | — | `{ success:, salience_decayed:, candidates_pruned:, broadcast_triggered: }` |
| `global_workspace_stats` | — | Full stats hash including per-source access statistics |

## Helpers

### `WorkspaceItem`
Competition candidate. Attributes: `id`, `content`, `source`, `salience`, `domain`, `ticks_held`, `submitted_at`. Key methods: `boost_salience!(amount)`, `decay!`, `eligible?` (salience > `COALITION_THRESHOLD`), `salience_label`, `to_h`.

### `Broadcast`
Workspace broadcast snapshot. Attributes: `id`, `item_id`, `content`, `source`, `salience`, `broadcast_at`, `recipients` (array). `to_h`.

### `GlobalWorkspaceEngine`
Central state: `@current_item` (WorkspaceItem or nil), `@candidates` (array), `@broadcasts` (array, rolling). Key methods:
- `submit(content:, source:, salience:, domain:)`: creates WorkspaceItem, adds to candidates if >= `COALITION_THRESHOLD`, challenges current occupant if salience is higher
- `compete`: runs `COMPETITION_ROUNDS` of inhibition-based selection, picks highest-salience candidate as winner, sets as `@current_item`
- `broadcast`: creates Broadcast from current workspace content, increments source access count
- `workspace_duration_exceeded?`: true when `@current_item.ticks_held >= WORKSPACE_DURATION`
- `decay_candidates`: reduces salience on all candidates except current occupant

## Integration Points

- `submit_to_workspace` called from each lex-tick phase to nominate its output for global broadcast
- `workspace_content` provides the current "conscious" content that all other extensions can query
- `broadcast` output is the primary inter-extension communication mechanism for salient content
- `run_competition` drives lex-tick's `action_selection` phase — workspace occupant determines the tick's primary action
- `access_frequency` provides attention distribution metrics for lex-governance oversight
- `update_global_workspace` maps to lex-tick's periodic maintenance; forces re-competition when duration exceeded

## Development Notes

- `WORKSPACE_CAPACITY = 1` is fundamental to GWT: there is only one global spotlight, not multiple
- Competition is salience-based with inhibition-of-return: items that just lost competition are temporarily penalized
- `submitted_at` and `ticks_held` together enable forced competition after `WORKSPACE_DURATION` ticks
- `broadcast` records recipient list but does not actually dispatch messages — callers poll `workspace_content`
- Workspace access without competition (direct `submit_to_workspace` win) is valid when no current occupant exists
