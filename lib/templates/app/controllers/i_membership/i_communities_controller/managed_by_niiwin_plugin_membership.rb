# Copied over from the Membership Plugin
module IMembership
  class ICommunitiesController
    module ManagedByNiiwinPluginMembership
      extend ActiveSupport::Concern

      included do
        before_action :load_i_community, only: [:show]
      end

      def index
        Rails.logger.debug "Nw_plugin_membership's controller used"

        authorize([:i_membership, ICommunity])
        @nw_table = Niiwin::NwTable.find(:i_community)
        nw_config = @nw_table.config[:nw_attributes]

        searchable_attrs = nw_config.select { |name, conf| conf[:is_searchable] }

        allowed_attributes = @nw_table.nw_attributes.each_with_object([]) do |attr, accum|
          if attr.action_allowed?(:index)
            accum << {
              name: attr.name,
              display_name: attr.display_name,
              nw_attribute_type: attr.nw_attribute_type.id
            }
          end
        end

        @allowed_attributes = allowed_attributes.to_json

        # build up an array of AR instances converted to hashes
        # with two extra keys (show and update authorization)
        allowed_attribute_names = allowed_attributes
          .select { |attr| %w[belongs_to has_many has_many_through].exclude?(attr[:nw_attribute_type]) }
          .map { |attr| attr[:name] }.concat(["id"])
        allowed_belongs_to_attribute_names = allowed_attributes
          .select { |attr| %w[belongs_to].include?(attr[:nw_attribute_type]) }
          .map { |attr| attr[:name] }
        allowed_has_many_attribute_names = allowed_attributes
          .select { |attr| %w[has_many has_many_through].include?(attr[:nw_attribute_type]) }
          .map { |attr| attr[:name] }
        ar_instances = policy_scope([:i_membership, ICommunity])
          .page(params[:page])
          .map do |instance|
            allowed_belongs_to_attributes = allowed_belongs_to_attribute_names
              .to_h { |attr| [attr, instance.send(attr)&.display_name] }
            allowed_has_many_attributes = allowed_has_many_attribute_names
              .to_h { |attr| [attr, instance.send(attr)&.count] }
            can_show = policy([:i_membership, instance]).show?
            can_update = policy([:i_membership, instance]).update?
            instance
              .attributes
              .slice(*allowed_attribute_names)
              .merge(allowed_belongs_to_attributes)
              .merge(allowed_has_many_attributes)
              .merge({can_show: can_show, can_update: can_update})
          end

        # passwords are hashed but we should hide them anyway
        allowed_attributes.each do |aa|
          if aa[:nw_attribute_type] == "password"
            ar_instances = ar_instances.map do |ai|
              ai[aa[:name]] = nil
              ai
            end
          end
        end

        @ar_instances = ar_instances

        get_attrs = ->(name, confs) do
          return {
            nw_attribute: name,
            display_name_override: confs[:display_name_override],
            nw_attribute_type: confs[:nw_attribute_type],
            selected_filter: confs[:selected_filter],
            filterrific_key: "with_#{name}"
          }
        end

        @filters_list = nw_config
          .select { |name, confs| confs[:selected_filter] }
          .map { |nested_name, confs| get_attrs.call(nested_name, confs) }
          .to_json

        @searchable_attributes = searchable_attrs.map { |name, _| name }.to_json

        respond_to do |format|
          format.html {
            render template: nw_index_template
          }
          format.json {
            render json: {
              ar_instances: @ar_instances
            }
          }
        end
      end

      def show
        authorize([:i_membership, @i_community])
        respond_to do |format|
          format.html {
            @nw_table = Niiwin::NwTable.find(:i_community)
            @ar_instance = @i_community
            render template: nw_show_template
          }
        end
      end

      protected

      def ar_attrs
        params
          .fetch(:i_community, {})
          .to_unsafe_hash
          .transform_values(&:presence) # convert empty strings to nil for interaction input filters
      end

      def load_i_community
        @i_community = ICommunity.find(params[:id])
      end

      def nw_create_interaction
        ::IMembership::ICommunities::Create
      end

      def nw_destroy_interaction
        ::IMembership::ICommunities::Destroy
      end

      def nw_index_template
        "nw_ar_instances/index"
      end

      def nw_show_template
        "nw_ar_instances/show"
      end

      def nw_new_template
        "nw_ar_instances/new"
      end

      def nw_edit_template
        "nw_ar_instances/edit"
      end

      def nw_update_interaction
        ::IMembership::ICommunities::Update
      end
    end
  end
end
