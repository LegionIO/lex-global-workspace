# frozen_string_literal: true

module Legion
  module Extensions
    module GlobalWorkspace
      module Helpers
        class Workspace
          include Constants

          attr_reader :competitors, :broadcast_history, :subscribers, :current_broadcast, :utilization

          def initialize
            @competitors       = []
            @broadcast_history = []
            @subscribers       = {}   # id => { name:, domains: [] }
            @current_broadcast = nil
            @utilization       = 0.0  # EMA of workspace usage
            @competition_count = 0
          end

          # --- Subscriber Management ---

          def register_subscriber(id:, name:, domains: [])
            return false if @subscribers.size >= MAX_SUBSCRIBERS && !@subscribers.key?(id)

            @subscribers[id] = { name: name, domains: Array(domains), registered_at: Time.now.utc }
            true
          end

          def unregister_subscriber(id:)
            !@subscribers.delete(id).nil?
          end

          # --- Competition ---

          def submit(content:, source:, domain:, salience:, coalition: [])
            return nil if salience.to_f < COMPETITION_THRESHOLD

            @competitors.shift while @competitors.size >= MAX_COMPETITORS
            competitor = Competitor.new(
              content: content,
              source: source,
              domain: domain,
              salience: salience,
              coalition: coalition
            )
            @competitors << competitor
            competitor
          end

          def compete
            @competition_count += 1
            expire_current_broadcast
            prune_weak_competitors

            return nil if @competitors.empty?

            sorted = @competitors.sort_by { |c| -c.effective_salience }
            winner = sorted.first

            if sorted.size > 1
              runner_up = sorted[1]
              unless (winner.effective_salience - runner_up.effective_salience) >= DOMINANCE_MARGIN
                boost_losers
                update_utilization(busy: true)
                return nil
              end
            end

            @competitors.delete(winner)
            broadcast = create_broadcast(winner)
            @current_broadcast = broadcast

            boost_losers
            update_utilization(busy: true)

            broadcast
          end

          # --- Query ---

          def conscious?(content)
            return false unless @current_broadcast && !@current_broadcast.expired?

            @current_broadcast.content == content
          end

          def current_content
            return nil unless @current_broadcast && !@current_broadcast.expired?

            @current_broadcast.to_h
          end

          def acknowledge(subscriber_id:)
            return false unless @current_broadcast && !@current_broadcast.expired?

            @current_broadcast.acknowledge(subscriber_id)
            true
          end

          # --- Workspace State ---

          def state
            if @current_broadcast && !@current_broadcast.expired?
              :broadcasting
            elsif @competitors.size > 1
              :contention
            elsif @utilization > 0.7
              :saturated
            else
              :idle
            end
          end

          def subscriber_count
            @subscribers.size
          end

          def competitor_count
            @competitors.size
          end

          # --- Tick / Maintenance ---

          def tick
            expire_current_broadcast
            decay_competitors
            prune_weak_competitors
            update_utilization(busy: !@competitors.empty? || (@current_broadcast && !@current_broadcast.expired?))
          end

          def to_h
            {
              state: state,
              state_label: WORKSPACE_STATE_LABELS[state],
              subscribers: @subscribers.size,
              competitors: @competitors.size,
              broadcast_history: @broadcast_history.size,
              utilization: @utilization.round(4),
              competitions: @competition_count,
              current_broadcast: @current_broadcast&.expired? == false ? @current_broadcast.to_h : nil
            }
          end

          private

          def create_broadcast(winner)
            broadcast = Broadcast.new(
              content: winner.content,
              source: winner.source,
              domain: winner.domain,
              salience: winner.effective_salience,
              coalition: winner.coalition
            )
            @broadcast_history << broadcast
            @broadcast_history.shift while @broadcast_history.size > MAX_BROADCAST_HISTORY
            broadcast
          end

          def expire_current_broadcast
            @current_broadcast = nil if @current_broadcast&.expired?
          end

          def prune_weak_competitors
            @competitors.reject!(&:below_threshold?)
          end

          def decay_competitors
            @competitors.each(&:decay)
          end

          def boost_losers
            @competitors.each(&:boost_urgency)
          end

          def update_utilization(busy:)
            sample = busy ? 1.0 : 0.0
            @utilization += (UTILIZATION_ALPHA * (sample - @utilization))
          end
        end
      end
    end
  end
end
