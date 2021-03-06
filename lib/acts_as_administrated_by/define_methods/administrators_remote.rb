module ActsAsAdministratedBy
  module DefineMethods
    module AdministratorsRemote

      def define_method_administrators_remote(class_sym, options)
        collection_name = self.name.demodulize.underscore.pluralize

        klass = (options[:class_name] || class_sym.to_s.singularize.camelize).constantize

        define_method(:administrators_url) do 
          @url = app_provider.uri.clone << '/api/' << api_version
          @url = @url << "/#{collection_name}/#{self.id}/related_things?" << {things_type: class_sym, as: :admin}.to_query
        end

        define_method(:administrators) do 
          @called_by = __method__.to_s
          generic('get').
            map{|item| klass.new(item)}
        end

      end

      private :define_method_administrators_remote

    end
  end
end