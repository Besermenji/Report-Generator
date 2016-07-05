require 'sinatra'
require 'letter_opener' unless ENV['RACK_ENV'] == 'production'
require 'pry' unless ENV['RACK_ENV'] == 'production'
require 'pony'
require 'json'
require 'openssl'
require 'origami'

class ReportGenerator < Sinatra::Base

  include Origami

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    
    if ENV['RACK_ENV'] == 'production'
      @username = ENV["SINATRA_USERNAME"]
      @password = ENV["SINATRA_PASSWORD"]
    else
      @username = "admin"
      @password = "admin"
    end

    username == @username and password == @password
  end
  
  post '/kif/?' do
    @kif_info = JSON.parse(params["data"])
    generate_pdf('reports/kif-report-template.html')
      Pony.mail(:to => @kif_info["email"],
                :from => 'noreply@receipt-yourself.com',
                :subject => 'hi',
                :body => "Hello there. It is #{DateTime.now}. Enjoy your KIF report.",
                :attachments => {"KIF_report_#{DateTime.now}.pdf" => File.read(@output_file)})
    status 200
  end

  post '/kuf/?' do
    @kuf_info = JSON.parse(params["data"])
    generate_pdf('reports/kuf-report-template.html')
      Pony.mail(:to => @kuf_info["email"],
                :from => 'noreply@receipt-yourself.com',
                :subject => 'hi',
                :body => "Hello there. It is #{DateTime.now}. Enjoy your KUF report.",
                :attachments => {"KUF_report_#{DateTime.now}.pdf" => File.read(@output_file)})

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
    sign_pdf
  end

  def sign_pdf
    # Code below is based on documentation available on
    # http://www.ruby-doc.org/stdlib-1.9.3/libdoc/openssl/rdoc/OpenSSL.html
    key = OpenSSL::PKey::RSA.new 2048

    open 'private_key.pem', 'w' do |io| io.write key.to_pem end
    open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

    cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
    pass_phrase = if ENV['RACK_ENV'] == 'production'
                    ENV['PDF_PASSWORD']
                  else
                    "admin"
                  end

    key_secure = key.export cipher, pass_phrase

    open 'private_key.pem', 'w' do |io|
      io.write key_secure
    end

    #Create the certificate

    name = OpenSSL::X509::Name.parse 'CN=PDF_signature'

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 0
    cert.not_before = Time.now
    cert.not_after = Time.now + 3600

    cert.public_key = key.public_key
    cert.subject = name


    @output_file = "pdf_signed_test#{Time.now.getutc}"

    contents = ContentStream.new.setFilter(:FlateDecode)
    contents.write @output_file,
                   :x => 350, 
                   :y => 750, 
                   :rendering => Text::Rendering::STROKE, 
                   :size => 30

    @pdf = PDF.read(@file)

    sigannot = Annotation::Widget::Signature.new
    sigannot.Rect = Rectangle[:llx => 89.0, :lly => 386.0, :urx => 190.0, :ury => 353.0]
    page = @pdf.get_page(1)
    page.add_annot(sigannot)

    # Sign the PDF with the specified keys
    @pdf.sign(cert, key, 
      :method => 'adbe.pkcs7.sha1',
      :annotation => sigannot,
      :location => "Serbia", 
      :contact => "besermenji@receiptyourself.com", 
      :reason => "Proof of Concept"
    )

    # Save the resulting file
    @pdf.save(@output_file)
  end

end