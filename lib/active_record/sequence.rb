# frozen_string_literal: true

require 'active_support/all'
require 'active_record'
require 'active_record/connection_adapters/mysql/schema_dumper'
require 'active_record/migration/command_recorder'
require 'active_record/schema_dumper'

module ActiveRecord
  module Sequence
    require 'active_record/sequence/command_recorder'
    require 'active_record/sequence/adapter'
    require 'active_record/sequence/schema_dumper'
    require 'active_record/sequence/model_methods'
  end
end

ActiveRecord::Migration::CommandRecorder.include(ActiveRecord::Sequence::CommandRecorder)

ActiveRecord::SchemaDumper.prepend(ActiveRecord::Sequence::SchemaDumper)
ActiveRecord::Base.extend(ActiveRecord::Sequence::ModelMethods)
