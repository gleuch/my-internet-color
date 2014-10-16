# encoding: UTF-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"


APP_ROOT  = File.expand_path(File.dirname(__FILE__)) unless defined?(APP_ROOT)
APP_ENV   = 'development' unless defined?(APP_ENV)
DEBUG     = false unless defined?(DEBUG)


# REQUIRE MODULES/GEMS
%w{yaml json active_record active_support/all addressable/uri paperclip friendly_id geocoder geocoder/models/active_record mysql2}.each{|r| require r}

# INITIALIZERS
Dir.glob("#{APP_ROOT}/initializers/*.rb").each{|r| require r}

# CONFIG
APP_CONFIG = YAML::load(File.open("#{APP_ROOT}/secrets.yml"))[APP_ENV] rescue nil

# SETUP DATABASE
@DB = ActiveRecord::Base.establish_connection( YAML::load(File.open("#{APP_ROOT}/database.yml"))[APP_ENV] )

# REQUIRE DATABASE MODELS
Dir.glob("#{APP_ROOT}/models/**/*.rb").each{|r| require r}
