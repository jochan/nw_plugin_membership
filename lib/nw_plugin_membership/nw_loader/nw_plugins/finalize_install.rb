# Registers callbacks for plugin
#
module NwPluginMembership
  module NwLoader
    module NwPlugins
      class FinalizeInstall < Niiwin::NwInteraction

        def execute
          puts "FinalizeInstall for Membership plugin"

          @nw_patch_effects = Niiwin::NwPatch::INITIAL_NW_PATCH_EFFECTS

          update_nw_config
        end

        protected

        def update_nw_config
        end

      end
    end
  end
end
