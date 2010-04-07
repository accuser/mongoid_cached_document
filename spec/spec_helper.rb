$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongoid/cached_document'
require 'spec'
require 'spec/autorun'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('mongoid_cached_document_test')
end

Spec::Runner.configure do |config|
  config.after :suite do
    Mongoid.master.collections.each(&:drop)
  end
end
