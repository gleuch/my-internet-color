# encoding: UTF-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"


# APP DEFAULTS
APP_ROOT  = File.expand_path(File.dirname(__FILE__)) unless defined?(APP_ROOT)
APP_ENV   = 'development' unless defined?(APP_ENV)
DEBUG     = false unless defined?(DEBUG)

# WEB CRAWLER DEFAULTS
CRAWLER_VERSION = '1.1' unless defined?(CRAWLER_VERSION)
CRAWLER_USER_AGENT = "WhatColor.IsTheInter.net/#{CRAWLER_VERSION} (http://whatcolor.istheinter.net)" unless defined?(CRAWLER_USER_AGENT)


# REQUIRE MODULES/GEMS
  %w{active_record active_support/all addressabler color friendly_id geocoder json mysql2 paperclip sidekiq webshot yaml}.each{|r| require r}

# INITIALIZERS
Dir.glob("#{APP_ROOT}/initializers/*.rb").each{|r| require r}

# CONFIG
APP_CONFIG = YAML::load(File.open("#{APP_ROOT}/secrets.yml"))[APP_ENV] rescue nil

# SETUP DATABASE
@DB = ActiveRecord::Base.establish_connection( YAML::load(File.open("#{APP_ROOT}/database.yml"))[APP_ENV] )

# REQUIRE DATABASE MODELS
Dir.glob("#{APP_ROOT}/models/**/*.rb").each{|r| require r}
