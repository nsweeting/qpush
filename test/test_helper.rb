$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'qpush'
require 'qpush/server'
require 'fakeredis'
require 'byebug'

require 'minitest/autorun'
