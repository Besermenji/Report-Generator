require 'rubygems'
require 'bundler'
require 'pony'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)
if ENV['RACK_ENV'] == 'production'
  Pony.options = { :via         => :smtp,
                   :via_options => { :address   => 'smtp.sendgrid.net',
                                     :port      =>  '587',
                                     :user_name => ENV["SENDGRID_USERNAME"],
                                     :password  => ENV["SENDGRID_PASSWORD"],
                                     :domain    => 'ry-report-generator.herokuapp.com' } }
else
  Pony.options = { :via => LetterOpener::DeliveryMethod,
                   :via_options => { :location => File.expand_path('../tmp/letter_opener', __FILE__)} }
end

require './report_generator'
run ReportGenerator
