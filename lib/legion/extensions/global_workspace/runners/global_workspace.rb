# frozen_string_literal: true

module Legion
  module Extensions
    module GlobalWorkspace
      module Runners
        module GlobalWorkspace
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def submit_for_broadcast(content:, source:, domain:, salience:, coalition: [], **)
            Legion::Logging.debug "[global_workspace] submit: source=#{source} domain=#{domain} salience=#{salience}"
            competitor = workspace.submit(
              content: content,
              source: source,
              domain: domain,
              salience: salience,
              coalition: coalition
            )
            if competitor
              { success: true, effective_salience: competitor.effective_salience.round(4),
                competitors: workspace.competitor_count }
            else
              { success: false, reason: :below_threshold, competitors: workspace.competitor_count }
            end
          end

          def run_competition(**)
            Legion::Logging.debug '[global_workspace] run_competition'
            broadcast = workspace.compete
            if broadcast
              {
                success: true,
                broadcast: broadcast.to_h,
                state: workspace.state,
                remaining: workspace.competitor_count
              }
            else
              { success: false, reason: :no_winner, state: workspace.state, competitors: workspace.competitor_count }
            end
          end

          def register_subscriber(id:, name:, domains: [], **)
            Legion::Logging.debug "[global_workspace] register_subscriber: id=#{id} name=#{name}"
            registered = workspace.register_subscriber(id: id, name: name, domains: domains)
            { success: registered, subscriber_count: workspace.subscriber_count }
          end

          def unregister_subscriber(id:, **)
            Legion::Logging.debug "[global_workspace] unregister_subscriber: id=#{id}"
            removed = workspace.unregister_subscriber(id: id)
            { success: removed, subscriber_count: workspace.subscriber_count }
          end

          def acknowledge_broadcast(subscriber_id:, **)
            Legion::Logging.debug "[global_workspace] acknowledge: subscriber=#{subscriber_id}"
            ack = workspace.acknowledge(subscriber_id: subscriber_id)
            { success: ack }
          end

          def query_consciousness(content:, **)
            is_conscious = workspace.conscious?(content)
            Legion::Logging.debug "[global_workspace] conscious?(#{content}): #{is_conscious}"
            { success: true, conscious: is_conscious }
          end

          def current_broadcast(**)
            content = workspace.current_content
            Legion::Logging.debug "[global_workspace] current_broadcast: #{content ? 'active' : 'none'}"
            { success: true, broadcast: content }
          end

          def broadcast_history(limit: 10, **)
            history = workspace.broadcast_history.last(limit.to_i).map(&:to_h)
            Legion::Logging.debug "[global_workspace] history: #{history.size} entries"
            { success: true, history: history, total: workspace.broadcast_history.size }
          end

          def update_global_workspace(**)
            Legion::Logging.debug '[global_workspace] tick'
            workspace.tick
            { success: true, state: workspace.state, competitors: workspace.competitor_count,
              utilization: workspace.utilization.round(4) }
          end

          def workspace_stats(**)
            Legion::Logging.debug '[global_workspace] stats'
            { success: true, stats: workspace.to_h }
          end

          private

          def workspace
            @workspace ||= Helpers::Workspace.new
          end
        end
      end
    end
  end
end
