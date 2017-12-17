# frozen-string-literal: true

require_relative '../actions_manager'

SequelTools::ActionsManager::Action.register :before_task, nil do |args, context|
  config = context[:config]
  adapter = config[:dbadapter]
  action = context[:current_action]
  hooks = [:before_any, :"before_#{action.name}", :"before_any_#{adapter}",
    :"before_#{action.name}_#{adapter}"]
  hooks.each do |h|
    next unless a = SequelTools::ActionsManager::Action[h]
    a.run args, context
    context[:"#{h}_processed"] = true
  end
  config[:maintenancedb] = adapter if context[:maintenancedb] == :default
end
