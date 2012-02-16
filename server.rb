require 'haml'
require 'sinatra'
require 'sprockets'
require 'coffee-script'
require './lib/ehaml_template.rb'

get '/assets/javascripts/application.js' do
  env = Sprockets::Environment.new
  env.append_path 'assets/javascripts'
  env['application.js'].to_s
end

get '/assets/stylesheets/application.css' do
  env = Sprockets::Environment.new
  env.append_path 'assets/stylesheets'
  headers 'Content-Type' => 'text/css'
  env['application.css'].to_s
end

get '/' do
  haml :index
end
