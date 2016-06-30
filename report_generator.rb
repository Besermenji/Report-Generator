require 'sinatra'
require 'letter_opener' unless ENV['RACK_ENV'] == 'production'
require 'pry' unless ENV['RACK_ENV'] == 'production'
require 'pony'
require 'json'


class ReportGenerator < Sinatra::Base
  
  post '/kif/?' do
    @kif_info = JSON.parse(params["data"])
    generate_pdf('reports/kif-report-template.html')
      Pony.mail(:to => @kif_info["email"],
                :from => 'noreply@receipt-yourself.com',
                :subject => 'hi',
                :body => "Hello there. It is #{DateTime.now}. Enjoy your KIF report.",
                :attachments => {"KIF_report_#{DateTime.now}.pdf" => File.read(@file)})

    status 200
  end

  post '/kuf/?' do
    @kuf_info = JSON.parse(params["data"])
    generate_pdf('reports/kuf-report-template.html')
      Pony.mail(:to => @kuf_info["email"],
                :from => 'noreply@receipt-yourself.com',
                :subject => 'hi',
                :body => "Hello there. It is #{DateTime.now}. Enjoy your KUF report.",
                :attachments => {"KUF_report_#{DateTime.now}.pdf" => File.read(@file)})

    status 200
  end

  post '/ios/?' do
    @ios_info = JSON.parse(params["data"])
    # generate_pdf('reports/kuf-report-template.html')
    #   Pony.mail(:to => @kuf_info["email"],
    #             :from => 'noreply@receipt-yourself.com',
    #             :subject => 'hi',
    #             :body => "Hello there. It is #{DateTime.now}. Enjoy your KUF report.",
    #             :attachments => {"KUF_report_#{DateTime.now}.pdf" => File.read(@file)})
    status 200
  end

  post '/partner_card/?' do
    @partner_card = JSON.parse(params["data"])
    # generate_pdf('reports/kuf-report-template.html')
    #   Pony.mail(:to => @kuf_info["email"],
    #             :from => 'noreply@receipt-yourself.com',
    #             :subject => 'hi',
    #             :body => "Hello there. It is #{DateTime.now}. Enjoy your KUF report.",
    #             :attachments => {"KUF_report_#{DateTime.now}.pdf" => File.read(@file)})
    status 200
  end

  def generate_pdf(pdf_path)
    kit = PDFKit.new(erb pdf_path.to_sym)
    kit.stylesheets << 'views/reports/css/bootstrap-theme.min.css'
    kit.stylesheets << 'views/reports/css/bootstrap.min.css'
    kit.stylesheets << 'views/reports/css/style.css'
    headers['Content-Type'] = 'application/pdf'
    @file_name = "pdf_test#{Time.now.getutc}"
    @file = kit.to_file(@file_name)
  end

end