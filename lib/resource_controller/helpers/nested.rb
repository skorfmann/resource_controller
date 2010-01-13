# Nested and Polymorphic Resource Helpers
#
module ResourceController
  module Helpers
    module Nested
      protected
      # Returns the relevant association proxy of the parent. (i.e. /posts/1/comments # => @post.comments)
      #
      def parent_association
        @parent_association ||= parent_object.send(model_name.to_s.pluralize.to_sym)
      end

      # Returns the type of the current parent
      #
      def parent_type
        @parent_type ||= parent_type_from_params || parent_type_from_request
      end

      # Returns the type of the current parent extracted from params
      #
      def parent_type_from_params
        [*belongs_to].find { |parent| !params["#{parent}_id".to_sym].nil? }
      end

      # Returns the type of the current parent extracted form a request path
      #
      def parent_type_from_request
        [*belongs_to].find { |parent| request.path.split('/').include? parent.to_s }
      end

      # Returns true/false based on whether or not a parent is present.
      #
      def parent?
        !parent_type.nil?
      end

      # Returns true/false based on whether or not a parent is a singleton.
      #
      def parent_singleton?
        !parent_type_from_request.nil? && parent_type_from_params.nil?
      end

      # Returns the current parent param, if there is a parent. (i.e. params[:post_id])
      def parent_param
        params["#{parent_type}_id".to_sym]
      end

      # Like the model method, but for a parent relationship.
      #
      def parent_model
        parent_type.to_s.camelize.constantize
      end

      # Returns the current parent object if a parent object is present.
      #
      def parent_object
        parent? && !parent_singleton? ? parent_model.find(parent_param) : nil
      end

      # Returns true/false bsed on wether or not a scoping-object is present.
      #
      def scoped?
        scoping_object.present?
      end

      # If there is a parent, returns the relevant scope assocaition proxy. Otherwise returns scope model.
      #
      def scope_association
        parent? ? scope_parent_association : scope_model
      end

      # If there is a parent, returns the relevant association proxy.  Otherwise returns model.
      #
      def end_of_association_chain
        return scope_association if scoped?
        parent? ? parent_association : model
      end

      # Returns model, which is scoped through scoping_object and parent_object
      #
      def scope_parent_association
        @scope_association ||= scoping_object.send(parent_model_to_method_sym).find(parent_param).send(model_name_to_method_sym)
      end

      # Returns model, which is loaded through scoping_object. Caches the return value for further calls
      #
      def scope_model
        @scope_association ||= scoping_object.send(model_name_to_method_sym)
      end

      #Converts parent_model to a valid method symbol
      #
      def parent_model_to_method_sym
        to_method_sym(parent_model)
      end

      #Converts model_name to a valid method symbol
      #
      def model_name_to_method_sym
        to_method_sym(model_name)
      end

      #Returns valid method-symbol of given name
      #
      def to_method_sym(name)
        name.to_s.pluralize.underscore.to_sym
      end
    end
  end
end
