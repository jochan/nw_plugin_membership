require_relative 'nw_loader/nw_plugins/initial_load'
require_relative 'nw_loader/nw_plugins/finalize_install'

module NwPluginMembership
  class Engine < ::Rails::Engine
    puts "NwPluginMembership::Engine"
  end
end
