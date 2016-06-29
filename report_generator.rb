require 'sinatra'
require 'letter_opener' unless ENV['RACK_ENV'] == 'production'
require 'pry' unless ENV['RACK_ENV'] == 'production'
require 'pony'
require 'json'


class ReportGenerator < Sinatra::Base
  
  post '/kif/?' do
    @kif_info = JSON.parse(params["data"])
    generate_pdf
      Pony.mail(:to => @kif_info["email"],
                :from => 'noreply@receipt-yourself.com',
                :subject => 'hi',
                :body => "Hello there. It is #{DateTime.now}. Enjoy your KIF report.",
                :attachments => {"KIF_report_#{DateTime.now}.pdf" => File.read(@file)})

    status 200
  end

  def generate_pdf
    kit = PDFKit.new(erb :'reports/kif-report-template.html')
    kit.stylesheets << 'views/reports/css/bootstrap-theme.min.css'
    kit.stylesheets << 'views/reports/css/bootstrap.min.css'
    kit.stylesheets << 'views/reports/css/style.css'
    headers['Content-Type'] = 'application/pdf'
    @file_name = "pdf_test#{Time.now.getutc}"
    @file = kit.to_file(@file_name)
  end

end