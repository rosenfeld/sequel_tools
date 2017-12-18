# frozen-string-literal: true

require_relative '../actions_manager'

class SequelTools::ActionsManager
  description = "Opens an IRB session started as 'sequel uri_to_database' (DB is available to irb)"
  Action.register :irb, description do |args, context|
    config = context[:config]
    uri = context[:uri_builder][config]
    exec "bundle exec sequel #{uri}"
  end
end
