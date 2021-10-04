module NwPluginMembership
  module NwLoader
    module NwPlugins
      class FinalizeUninstall < Niiwin::NwInteraction

        COMMUNITIES_CONCERN_PATH = "app/controllers/i_membership/i_communities_controller/managed_by_niiwin_plugin_membership.rb"

        def execute
          puts "FinalizeUninstall for Membership plugin"

          @system_user = compose(Niiwin::NwInstaller::IUsersAndPermissions::CreateSystemUser)

          # TODO: Provide option to user to:
          # - Remove every plugin-related resource, and set plugin as uninstalled
          # - Remove selected resources, and set plugin as uninstalled

          # Removes every plugin-related resource (including templates, roles and permissions, workspaces, and db tables)
          remove_roles_and_permissions
          remove_workspaces
          remove_tables
          delete_templates
        end

        protected

        def create_nw_patch_item(nw_patch, params)
          Niiwin::NwAppStructure::NwPatchItems::Create.run_returning!(
            apply_nw_patch_immediately: false,
            form_params: params,
            nw_patch_item: nw_patch.nw_patch_items.build,
          )
        end

        def remove_roles_and_permissions
          # Corresponding IPermissions and IRoleAssignment also gets removed automatically
          role = IRole.find_by(name: "Membership Viewer")
          compose(::IUsersAndPermissions::IRoles::Destroy, id: role.id) if role.present?
        end

        def remove_workspaces
          nw_patch = Niiwin::NwPatch.find_or_create_current
          nw_patch_item_params = {
            subject_operation: "remove",
            subject_type: "nw_workspace",
            subject_id: "i_membership",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {},
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          ::Niiwin::NwAppStructure::NwPatches::Apply.run!(id: nw_patch.id, i_user_id: @system_user.id)
        end

        def remove_tables
          nw_patch = Niiwin::NwPatch.find_or_create_current

          nw_patch_item_params = {
            subject_operation: "remove",
            subject_type: "nw_table",
            subject_id: "i_community_membership",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {}
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          nw_patch_item_params = {
            subject_operation: "remove",
            subject_type: "nw_table",
            subject_id: "i_person",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {}
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          nw_patch_item_params = {
            subject_operation: "remove",
            subject_type: "nw_table",
            subject_id: "i_community",
            parent_type: nil,
            parent_id: nil,
            subject_attrs: {}
          }
          create_nw_patch_item(nw_patch, nw_patch_item_params)

          ::Niiwin::NwAppStructure::NwPatches::Apply.run!(id: nw_patch.id, i_user_id: @system_user.id)
        end

        def delete_templates
          template_to_delete = Inject[:file].join(Rails.root, COMMUNITIES_CONCERN_PATH)
          Inject[:file].delete(template_to_delete) if Inject[:file].exist?(template_to_delete)

          nw_patch_effects = Niiwin::NwPatch::INITIAL_NW_PATCH_EFFECTS
          nw_patch_effects[:commit_files_to_git] << template_to_delete
          compose(
            Niiwin::NwAppStructure::ApplySideEffects::CommitFilesToGit,
            nw_patch_effects: nw_patch_effects,
            commit_message: "Remove plugin templates"
          )
        end

      end
    end
  end
end
