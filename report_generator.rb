require 'sinatra'
require 'letter_opener'
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
                :body => "Hello there. It is #{DateTime.now}. This is just a test.")
      redirect '/report_sent'
    else
      redirect '/something_went_wrong'
    end
  end

end