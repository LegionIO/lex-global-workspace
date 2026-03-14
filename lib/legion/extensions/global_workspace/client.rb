# frozen_string_literal: true

require 'legion/extensions/global_workspace/helpers/constants'
require 'legion/extensions/global_workspace/helpers/broadcast'
require 'legion/extensions/global_workspace/helpers/competitor'
require 'legion/extensions/global_workspace/helpers/workspace'
require 'legion/extensions/global_workspace/runners/global_workspace'

module Legion
  module Extensions
    module GlobalWorkspace
      class Client
        include Runners::GlobalWorkspace

        def initialize(workspace: nil, **)
          @workspace = workspace || Helpers::Workspace.new
        end

        private

        attr_reader :workspace
      end
    end
  end
end
