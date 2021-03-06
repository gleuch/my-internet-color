#
# My Internet Color
# a piece by @gleuch <http://gleu.ch>
# (c)2014, all rights reserved
#
# -----------------------------------------------------------------------------
#
# Process App
# - app for running Sidekiq job workers
#
#


# DEFAULT OPTIONS
APP_ROOT = File.expand_path('..', File.dirname(__FILE__))
DEBUG = false
TIME_START = Time.now

# LOAD CONFIG
%w{billy capybara/poltergeist capybara/dsl color geocoder mini_magick singleton}.each{|r| require r}
require File.join(APP_ROOT, 'config.rb')
require File.join(APP_ROOT, 'lib/modules/webshot.rb')

# LOAD SIDEKIQ SERVER CONNECTION CONFIG
Sidekiq.configure_server do |config|
  config.redis = {namespace: 'mynetcolor', url: 'redis://localhost:6379/1'}
end
