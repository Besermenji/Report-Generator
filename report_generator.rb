require 'sinatra'
require 'letter_opener' unless ENV['RACK_ENV'] == 'production'
require 'pony'
require 'json'


class ReportGenerator < Sinatra::Base
  
  before do
    unless request.body.read == ""
      request.body.rewind
      @request_payload ||= JSON.parse request.body.read
    end
  end

  get '/' do
    "Hello World! Im just a poor app, nobody loves me."
  end

  get '/report_sent' do
    "Report sent!"
  end

  get '/something_went_wrong' do
    "Oh noes! 
    You don't like the smell? 
    Maybe I don't like the smell that some cars produce? 
    I sure as hell don't like it when 
    people fart near me or if someone has 
    bad body odor. You get a sore throat, 
    maybe I get a headache 
    from prolonged exposure to 
    those smells. Should we make 
    everything that doesn't smell good illegal?"
  end

  post '/send_report' do
    if @request_payload && @request_payload["email"]
      Pony.mail(:to => @request_payload["email"],
                :from => 'noreply@receipt-yourself.com',
                :subject => 'hi',
                :body => "Hello there. It is #{DateTime.now}. This is just a test.",
                :attachments => {"Silly.pdf" => File.read("reports/Silly.pdf")})
      redirect '/report_sent'
    else
      redirect '/something_went_wrong'
    end
  end

  get '/pdf' do
    kit = PDFKit.new(erb :'reports/report-template.html')
    kit.stylesheets << 'views/reports/css/bootstrap-theme.min.css'
    kit.stylesheets << 'views/reports/css/bootstrap.min.css'
    kit.stylesheets << 'views/reports/css/style.css'
    headers['Content-Type'] = 'application/pdf'
    file = kit.to_file("pdf_test#{Time.now.getutc}")
  end

end