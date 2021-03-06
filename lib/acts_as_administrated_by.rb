require 'acts_as_administrated_by/instance_methods'
require 'acts_as_administrated_by/class_methods'
require 'acts_as_administrated_by/define_methods'

module ActsAsAdministratedBy

  def acts_as_administrated_by(*classes_array)

    class_eval do
      include InstanceMethods
      extend  ClassMethods
      extend  DefineMethods
    end

    if is_array_of_keys? classes_array
      acts_as_administrated_by_simple classes_array
    else
      acts_as_administrated_by_optioned classes_array
    end


  end

  def acts_as_administrated(*classes_array)
    
    class_eval do
      include InstanceMethods
      extend  ClassMethods
      extend  DefineMethods
    end


    define_method("add_administrator_url") do 
      my_klass.url = "#{my_klass.app_provider.url}/#{my_object_name.pluralize}/#{self.id}/add_administrator/#{@person.id}"
    end

    define_method("add_administrator") do |person|
      @person = person
      if person.class.name == 'BigbeeGraph::Person'
        if self.class.name == "BigbeeAccounts::AppClient"
          my_klass.authenticate_with = {api_key: :in_headers}
          my_klass.called_by = __method__.to_s
          res = generic('post')
        else
          unless is_administrator?(person)
            r = ActsAsRelatingTo::Relationship.create(
              owner_type: 'BigbeeGraph::Person',
              owner_id: person.id,
              in_relation_to_type: self.class.name,
              in_relation_to_id: self.id)
            r.tag_list.add('admin')
            r.save
          end
          is_administrator?(person)
        end
      else
        raise "expected BigbeeGraph::Person, got #{person.class.name}"
      end
    end

  end

end

ActiveRecord::Base.extend ActsAsAdministratedBy