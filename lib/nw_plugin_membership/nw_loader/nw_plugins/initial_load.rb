# Registers callbacks for plugin
#
module NwPluginMembership
  module NwLoader
    module NwPlugins
      class InitialLoad < Niiwin::NwInteraction

        include Niiwin::NwLoader::NwPlugins::InitialLoadMixin

        def execute
          puts "InitialLoad for Membership plugin"
        end

      end
    end
  end
end
