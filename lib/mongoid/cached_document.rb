#--
# Copyright (c) 2010 Matthew Gibbons <mhgibbons@me.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'rubygems'

gem 'mongoid', '>= 2.0.0.beta2'

require 'mongoid'

module Mongoid
  class CachedDocument
    def initialize(attributes)
      @cached_attributes = attributes
    end

    class << self
      def set(value)
        if value.respond_to? :cachable_attributes
          value.cachable_attributes.merge({ '_type' => value.class.to_s, '_id' => value.id })
        else
          { '_type' => value.class.to_s, '_id' => value.id }
        end
      end
  
      def get(value)
        self.new(value)
      end
    end

    def ==(value)
      _document == value
    end

    alias_method :eql?, :==
    alias_method :equal?, :==

    def method_missing(name, *args, &block)
      if @document
        _document.send name, *args, &block
      elsif @cached_attributes.has_key? name.to_s
        @cached_attributes[name.to_s]
      else
        if defined? Rails
          Rails.logger.debug("#{@cached_attributes['_type']}[:#{name}] is not cached (called from #{caller(1).first})")
        end
        
        _document.send name, *args, &block
      end
    end

    private
      def _document
        @document ||= @cached_attributes['_type'].constantize.find(@cached_attributes['_id'])
      end
  end
end
