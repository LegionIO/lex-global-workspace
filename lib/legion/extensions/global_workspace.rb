# frozen_string_literal: true

require 'legion/extensions/global_workspace/version'
require 'legion/extensions/global_workspace/helpers/constants'
require 'legion/extensions/global_workspace/helpers/broadcast'
require 'legion/extensions/global_workspace/helpers/competitor'
require 'legion/extensions/global_workspace/helpers/workspace'
require 'legion/extensions/global_workspace/runners/global_workspace'
require 'legion/extensions/global_workspace/client'

module Legion
  module Extensions
    module GlobalWorkspace
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
