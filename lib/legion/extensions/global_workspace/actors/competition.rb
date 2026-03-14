# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module GlobalWorkspace
      module Actor
        class Competition < Legion::Extensions::Actors::Every
          def runner_class
            Legion::Extensions::GlobalWorkspace::Runners::GlobalWorkspace
          end

          def runner_function
            'update_global_workspace'
          end

          def time
            2
          end

          def run_now?
            false
          end

          def use_runner?
            false
          end

          def check_subtask?
            false
          end

          def generate_task?
            false
          end
        end
      end
    end
  end
end
