# Registers callbacks for plugin
#
module NwPluginMembership
  module NwLoader
    module NwPlugins
      class FinalizeInstall < Niiwin::NwInteraction

        def execute
          puts "FinalizeInstall for Membership plugin"

          @system_user = compose(Niiwin::NwInstaller::IUsersAndPermissions::CreateSystemUser)

          create_person_and_community_tables
          create_community_membership_table
          create_table_relationships
          create_workspaces
          create_resources
          copy_templates
        end

        protected

        def create_nw_patch_item(nw_patch, params)
          Niiwin::NwAppStructure::NwPatchItems::Create.run_returning!(
            apply_nw_patch_immediately: false,
            form_params: params,
            nw_patch_item: nw_patch.nw_patch_items.build,
          )
        end

        def create_person_and_community_tables
          nw_patch = Niiwin::NwPatch.find_or_create_current
          nw_patch_item_params = {
            subject_operation: "add",
            subject_type: "nw_table",
            subject_id: "",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {
              id: "i_person",
              display_name_override: "Person",
              nw_attributes: {},
            }
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          nw_patch_item_params = {
            subject_operation: "add",
            subject_type: "nw_table",
            subject_id: "",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {
              id: "i_community",
              display_name_override: "Community",
              nw_attributes: [
                {
                  id: "i_name",
                  display_name_override: "Name",
                  nw_attribute_type: "string",
                  nw_action_ids: Niiwin::RAILS_REST_ACTION_NAMES,
                  index: true,
                },
                {
                  id: "i_number",
                  display_name_override: "Number",
                  nw_attribute_type: "string",
                  nw_action_ids: Niiwin::RAILS_REST_ACTION_NAMES,
                  index: false,
                },
                {
                  id: "i_nickname",
                  display_name_override: "Nickname",
                  nw_attribute_type: "string",
                  nw_action_ids: Niiwin::RAILS_REST_ACTION_NAMES,
                  index: false,
                },
                {
                  id: "i_description",
                  display_name_override: "Description",
                  nw_attribute_type: "string",
                  nw_action_ids: Niiwin::RAILS_REST_ACTION_NAMES,
                  index: false,
                },
              ],
            }
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          ::Niiwin::NwAppStructure::NwPatches::Apply.run!(id: nw_patch.id, i_user_id: @system_user.id)
        end

        def create_community_membership_table
          nw_patch = Niiwin::NwPatch.find_or_create_current
          nw_patch_item_params = {
            subject_operation: "add",
            subject_type: "nw_table",
            subject_id: "",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {
              id: "i_community_membership",
              display_name_override: "CommunityMembership",
              nw_attributes: [
                {
                  id: "i_person",
                  display_name_override: "Person",
                  index: true,
                  required: true,
                  nw_attribute_type: "belongs_to",
                  nw_action_ids: Niiwin::RAILS_REST_ACTION_NAMES,
                  foreign_key: "i_person_id",
                  inverse_of: "i_community_memberships",
                  related_nw_table_id: "i_person",
                },
                {
                  id: "i_community",
                  display_name_override: "Community",
                  index: true,
                  required: true,
                  nw_attribute_type: "belongs_to",
                  nw_action_ids: Niiwin::RAILS_REST_ACTION_NAMES,
                  foreign_key: "i_community_id",
                  inverse_of: "i_community_memberships",
                  related_nw_table_id: "i_community",
                },
              ],
            }
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          ::Niiwin::NwAppStructure::NwPatches::Apply.run!(id: nw_patch.id, i_user_id: @system_user.id)
        end

        def create_table_relationships
          nw_patch = Niiwin::NwPatch.find_or_create_current
          nw_patch_item_params = {
            subject_operation: "add",
            subject_type: "nw_attribute",
            subject_id: "",
            parent_type: "nw_table",
            parent_id: "i_community",
            subject_attrs: {
              nw_second_and_first_nw_attribute_ids: "i_person#{Niiwin::NW_HMT_NW_ATTR_ID_SEPARATOR}i_community_memberships",
              nw_action_ids: Niiwin::RAILS_READ_REST_ACTION_NAMES,
              nw_attribute_type: "has_many_through",
            }
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          nw_patch_item_params = {
            subject_operation: "add",
            subject_type: "nw_attribute",
            subject_id: "",
            parent_type: "nw_table",
            parent_id: "i_person",
            subject_attrs: {
              nw_second_and_first_nw_attribute_ids: "i_community#{Niiwin::NW_HMT_NW_ATTR_ID_SEPARATOR}i_community_memberships",
              nw_action_ids: Niiwin::RAILS_READ_REST_ACTION_NAMES,
              nw_attribute_type: "has_many_through",
            }
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          ::Niiwin::NwAppStructure::NwPatches::Apply.run!(id: nw_patch.id, i_user_id: @system_user.id)
        end

        def create_workspaces
          nw_patch = Niiwin::NwPatch.find_or_create_current
          nw_patch_item_params = {
            subject_operation: "add",
            subject_type: "nw_workspace",
            subject_id: "",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {
              display_name_override: "Membership",
              nw_resources: [
                {
                  concern_paths: ["i_membership/i_communities_controller/managed_by_niiwin_plugin_membership.rb"],
                  nw_action_ids: Niiwin::RAILS_READ_REST_ACTION_NAMES,
                  source_id: "i_community",
                  source_type: "nw_table",
                },
                {
                  nw_action_ids: Niiwin::RAILS_READ_REST_ACTION_NAMES,
                  source_id: "i_person",
                  source_type: "nw_table",
                },
                {
                  nw_action_ids: Niiwin::RAILS_READ_REST_ACTION_NAMES,
                  source_id: "i_community_membership",
                  source_type: "nw_table",
                },
              ],
            },
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          ::Niiwin::NwAppStructure::NwPatches::Apply.run!(id: nw_patch.id, i_user_id: @system_user.id)
        end

        def create_resources
          # TODO: Clean up Niiwin IRole creation interactions
          role = ::IUsersAndPermissions::IRoles::Create.run_returning!(name: "Membership Viewer")
          # role = IRole.find("95b8ef84-d128-41c5-ba88-21614974c158")

          %w[i_community i_person i_community_membership].each do |nw_resource_id|
            ::IUsersAndPermissions::IPermissions::Create.run_returning!(
              i_role_id: role.id,
              nw_workspace_id: "i_membership",
              nw_resource_id: nw_resource_id,
              nw_action_ids: Niiwin::RAILS_READ_REST_ACTION_NAMES,
              updated_by: @system_user.id,
            )
          end

          # Assign role to test app user
          app_user = IUser.find_by(email: "app-user@niiwin.dev")
          ::IUsersAndPermissions::IRoleAssignments::Create.run_returning!(
            i_role_id: role.id,
            i_user_id: app_user.id,
          )
        end

        def copy_templates
          # Copy over template files
          COMMUNITIES_PATH = "app/controllers/i_membership/i_communities_controller/managed_by_niiwin_plugin_membership.rb"
          FileUtils.cp(
            File.join("#{Gem.loaded_specs['nw_plugin_membership'].full_gem_path}/lib/templates", COMMUNITIES_PATH),
            File.join(Rails.root, COMMUNITIES_PATH)
          )
        end

      end
    end
  end
end
