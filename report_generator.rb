require 'sinatra'

class ReportGenerator < Sinatra::Base
  get '/hi' do
    "Hello World!"
  end
end