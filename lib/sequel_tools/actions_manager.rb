# frozen-string-literal: true

module SequelTools
  class ActionsManager
    attr_reader :actions, :context

    URI_BUILDER = ->(config, dbname = config[:dbname]) do
      c = config
      uri_parts = [ "#{c[:dbadapter]}://" ]
      if user = c[:username]
        uri_parts << user
        uri_parts << ':' << c[:password] if c[:password]
        uri_parts << '@'
      end
      uri_parts << c[:dbhost]
      uri_parts << ':' << c[:dbport] if c[:dbport]
      uri_parts << '/' << dbname
      uri_parts.join('')
    end

    def initialize(config)
      @actions = []
      @context = { config: config, uri_builder: URI_BUILDER }
    end

    def load_all
      @actions.concat Action.registered
    end

    def export_as_rake_tasks(rake_context)
      actions.each do |action|
        ctx = context
        rake_context.instance_eval do
          desc action.description unless action.description.nil?
          task action.name, action.arg_names do |t, args|
            adapter = ctx[:config][:dbadapter]
            hooks = [:before_any, :"before_#{action.name}", :"before_any_#{adapter}",
                     :"before_#{action.name}_#{adapter}"]
            ctx[:current_action] = action
            hooks.each{|h| a = Action[h] and a.run args, ctx }
            action.run args, ctx
          end
        end
      end
    end

    class Action
      attr_reader :name, :description, :arg_names, :block

      def initialize(name, description, arg_names: [], &block)
        @name, @description, @arg_names, @block = name, description, arg_names, block
      end

      def run(args, context)
        @block.call args, context
      end

      @@registered = []
      @@registered_by_name = {}
      class AlreadyRegisteredAction < StandardError; end
      def self.register(name, description, arg_names: [], &block)
        if @@registered_by_name[name]
          raise AlreadyRegisteredAction, "Attempt to register #{name} twice"
        end
        @@registered <<
          (@@registered_by_name[name] = Action.new name, description, arg_names: arg_names, &block)
      end

      def self.registered
        @@registered
      end

      def self.[](name)
        @@registered_by_name[name]
      end

      def self.unregister(name)
        return unless action = @@registered_by_name.delete(name)
        @@registered.delete action
        action
      end

      def self.replace(name, description, arg_names: [], &block)
        unregister name
        register name, description, arg_names: arg_names, &block
      end

      def self.register_action(action)
        register action.name, action.description, arg_names: action.arg_names, &action.block
      end
    end
  end
end
