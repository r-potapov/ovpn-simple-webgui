class CertificatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_current_certificates, :only => :index
  load_and_authorize_resource
  # :through => :current_user
  skip_load_resource :only => [:new, :create, :download_ca, :download_ta]
  # , :except => [:some_action_without_auth]
  # GET /certificates
  # GET /certificates.xml
  def index
    # @certificates = current_user.certificates.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @certificates }
    end
  end

  # GET /certificates/1
  # GET /certificates/1.xml
  def show
    # @certificate = current_user.certificates.find(params[:id])
    str = Ip.select("inet_ntoa(subnet*4+1+inet_aton('172.16.0.0')) as str1").where('certificate_id=?', @certificate.id)
    @ip = str[0].str1
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @certificate }
    end
  end

  # GET /certificates/new
  # GET /certificates/new.xml
  def new
    @certificate = Certificate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @certificate }
    end
  end

  # GET /certificates/1/edit
  def edit
    # @certificate = Certificate.find(params[:id])
  end

  # POST /certificates
  # POST /certificates.xml
  def create
    if current_user.certificates.count < current_user.cert_limit
      name = current_user.username + Time.now.to_i.to_s
      # @certificate = Certificate.new()
      @certificate = current_user.certificates.build(:title => name)
      number=File.open("/etc/openvpn/easy-rsa/keys/serial", "r").readline.chomp
      ENV['KEY_CN']=name
      Dir.chdir "/etc/openvpn/easy-rsa/"
      system "sh /etc/openvpn/easy-rsa/build-key " + name
      @certificate.number=number
      @certificate.link_key="/etc/openvpn/easy-rsa/keys/" + name + ".key"
      @certificate.link_crt="/etc/openvpn/easy-rsa/keys/" + name + ".crt"
      respond_to do |format|
        if @certificate.save
          format.html { redirect_to(@certificate, :notice => t('.cert_was_created') ) }
          format.xml  { render :xml => @certificate, :status => :created, :location => @certificate }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @certificate.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to(certificates_url, :notice => t('.cert_was_not_created') )
    end
  end

  # PUT /certificates/1
  # PUT /certificates/1.xml
  def update
    # @certificate = Certificate.find(params[:id])

    respond_to do |format|
      if @certificate.update_attributes(params[:certificate])
        format.html { redirect_to(@certificate, :notice => t('.cert_was_updated') ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @certificate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /certificates/1
  # DELETE /certificates/1.xml
  def destroy
    # @certificate = Certificate.find(params[:id])
    @certificate.destroy

    respond_to do |format|
      format.html { redirect_to(certificates_url) }
      format.xml  { head :ok }
    end
  end
  
  # Передача файла
  def download_key
    # @certificate = Certificate.find(params[:id])
    if File.exist?(@certificate.link_key)
      send_file(@certificate.link_key,
                :filename => "#{@certificate.title}.key",
                :type => "application/pkix-cert")
    else
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  def download_crt
    # @certificate = Certificate.find(params[:id])
    if File.exist?(@certificate.link_crt)
      send_file(@certificate.link_crt,
                :filename => "#{@certificate.title}.crt",
                :type => "application/x-x509-server-cert")
    else
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  def download_config
    # @certificate = Certificate.find(params[:id])
    if !File.exist?("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
      create_config
    end
    if File.exist?("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
      send_file("/etc/openvpn/client_files/#{@certificate.title}.ovpn",
                :filename => "#{@certificate.title}.ovpn",
                :type => "application/x-x509-server-cert")
    else
      # если заготовка отсутствует, то сообщаем об ошибке
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  def download_ca
    if File.exist?('/etc/openvpn/keys/ca.crt')
      send_file('/etc/openvpn/keys/ca.crt',
                :filename => "ca.crt",
                :type => "application/x-x509-server-cert")
    else
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  def download_ta
    if File.exist?('/etc/openvpn/keys/ta.key')
      send_file('/etc/openvpn/keys/ta.key',
                :filename => "ta.key",
                :type => "application/pkix-cert")
    else
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  def download_zip
    # @certificate = Certificate.find(params[:id])
    Dir.chdir "/etc/openvpn/client_files/"
    if !File.exist?("#{@certificate.title}.zip")
      Zip::Archive.open(@certificate.title + '.zip', Zip::CREATE) do |ar|
        # if overwrite: ..., Zip::CREATE | Zip::TRUNC) do |ar|
        # specifies compression level: ..., Zip::CREATE, Zip::BEST_SPEED) do |ar|
      
        # add files to zip archive
        if File.exist?('/etc/openvpn/keys/ca.crt')
          ar.add_file('/etc/openvpn/keys/ca.crt')
        end
        if File.exist?('/etc/openvpn/keys/ta.key')
          ar.add_file('/etc/openvpn/keys/ta.key')
        end
        # if File.exist?('/etc/openvpn/client.ovpn')
        #   ar.add_file('/etc/openvpn/client.ovpn')
        # end
        if !File.exist?("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
          create_config
        end
        if File.exist?("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
          ar.add_file("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
        end
        if File.exist?('/etc/openvpn/ReadMe.txt')
          ar.add_file('/etc/openvpn/ReadMe.txt')
        end
        if File.exist?(@certificate.link_key)
          ar.add_file(@certificate.link_key)
        end
        if File.exist?(@certificate.link_crt)
          ar.add_file(@certificate.link_crt)
        end
      end
      # Zip::Archive.encrypt('file.zip', 'password')
      # Zip::Archive.encrypt(current_user.username + '.zip', current_user.username)
      # File.chmod(0777, current_user.username + '.zip')
    end
    if File.exist?("/etc/openvpn/client_files/#{@certificate.title}.zip")
      send_file("/etc/openvpn/client_files/#{@certificate.title}.zip",
                :filename => "#{@certificate.title}.zip",
                :type => "application/zip")
    else
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  def download_portable_zip
    # @certificate = Certificate.find(params[:id])
    Dir.chdir "/etc/openvpn/client_files/"
    if !File.exist?("#{@certificate.title}_portable.zip")
      if File.exist?('/etc/openvpn/ovpnp.zip')
        # если портабл набор для данного сертификата отсутствует, копируем заготовку и добавляем в нее сведения о сертификате
        FileUtils.cp("/etc/openvpn/ovpnp.zip", "/etc/openvpn/client_files/#{@certificate.title}_portable.zip")
        Zip::Archive.open("#{@certificate.title}_portable.zip") do |ar|
          # if overwrite: ..., Zip::CREATE | Zip::TRUNC) do |ar|
          # specifies compression level: ..., Zip::CREATE, Zip::BEST_SPEED) do |ar|

          # add files to zip archive
          if File.exist?('/etc/openvpn/keys/ca.crt')
            # add_file(<entry name>, <source path>)
            ar.add_file('/data/config/ca.crt', '/etc/openvpn/keys/ca.crt')
          end
          if File.exist?('/etc/openvpn/keys/ta.key')
            ar.add_file('/data/config/ta.key', '/etc/openvpn/keys/ta.key')
          end
          # if File.exist?('/etc/openvpn/client.ovpn')
          #   ar.add_file('/etc/openvpn/client.ovpn')
          # end
          if !File.exist?("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
            create_config
          end
          if File.exist?("/etc/openvpn/client_files/#{@certificate.title}.ovpn")
            ar.add_file("/data/config/#{@certificate.title}.ovpn", "/etc/openvpn/client_files/#{@certificate.title}.ovpn")
          end
          if File.exist?('/etc/openvpn/ReadMe.txt')
            ar.add_file('/etc/openvpn/ReadMe.txt')
          end
          if File.exist?(@certificate.link_key)
            ar.add_file("/data/config/#{@certificate.title}.key", @certificate.link_key)
          end
          if File.exist?(@certificate.link_crt)
            ar.add_file("/data/config/#{@certificate.title}.crt", @certificate.link_crt)
          end
        end
        # Zip::Archive.encrypt('file.zip', 'password')
        # Zip::Archive.encrypt(current_user.username + '.zip', current_user.username)
        # File.chmod(0777, current_user.username + '.zip')
      end
    end
    if File.exist?("/etc/openvpn/client_files/#{@certificate.title}_portable.zip")
      send_file("/etc/openvpn/client_files/#{@certificate.title}_portable.zip",
                :filename => "#{@certificate.title}_portable.zip",
                :type => "application/zip")
    else
      redirect_to(certificates_path, :alert => t(:file_not_found) )
    end
  end

  private

  def find_current_certificates
    if current_user.role? :admin
      if params[:user_id]!=nil
        @certificates = Certificate.where(:user_id => params[:user_id])
      else
        @certificates = Certificate.all
      end
    else
      @certificates = current_user.certificates.all
    end
  end

  def create_config
    if File.exist?('/etc/openvpn/client.ovpn')
      # если файл конфигурации для данного сертификата отсутствует, копируем заготовку и добавляем в нее сведения о сертификате
      FileUtils.cp("/etc/openvpn/client.ovpn", "/etc/openvpn/client_files/#{@certificate.title}.ovpn")
      str1="cert #{@certificate.title}.crt\nkey #{@certificate.title}.key"
      File.open("/etc/openvpn/client_files/" + "#{@certificate.title}.ovpn", "a") { |f| f.write(str1) }
    end
  end
end
