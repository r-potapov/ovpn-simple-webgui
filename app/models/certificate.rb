class Certificate < ActiveRecord::Base
  has_one :ip, :dependent => :destroy
  belongs_to :user
  validates :title, :link_key, :link_crt, :presence => true
  validates :title, :uniqueness => true

  after_save :create_certificate_ip
  before_destroy :delete_files

  private
  def create_certificate_ip
    adress=Ip.find_by_sql("SELECT if (count(subnet)=0, 0, (select min(subnet+1)%16384 FROM ips s1 where not exists (select subnet from ips s2 where s2.subnet=(s1.subnet+1)%16384))) as subnet from ips")
    self.create_ip(:subnet => adress[0].subnet)
    str=Ip.select("inet_ntoa(subnet*4+1+inet_aton('172.16.0.0')) as str1, inet_ntoa(subnet*4+2+inet_aton('172.16.0.0')) as str2").where('certificate_id=?', self.id)
    list="ifconfig-push "+str[0].str1+" "+str[0].str2
    File.open("/etc/openvpn/ccd/" + self.title, "w") { |f| f.write(list) }
  end

  def delete_files
    name = self.title
    number = self.number
    Dir.chdir "/etc/openvpn/easy-rsa/"
    system "sh /etc/openvpn/easy-rsa/revoke-full " + name
    if File.exist?("/etc/openvpn/easy-rsa/keys/" + name + ".crt")
      File.delete("/etc/openvpn/easy-rsa/keys/" + name + ".crt")
    end
    if File.exist?("/etc/openvpn/easy-rsa/keys/" + name + ".csr")
      File.delete("/etc/openvpn/easy-rsa/keys/" + name + ".csr")
    end
    if File.exist?("/etc/openvpn/easy-rsa/keys/" + name + ".key")
      File.delete("/etc/openvpn/easy-rsa/keys/" + name + ".key")
    end
    if File.exist?("/etc/openvpn/easy-rsa/keys/" + number + ".pem")
      File.delete("/etc/openvpn/easy-rsa/keys/" + number + ".pem")
    end
    if File.exist?("/etc/openvpn/ccd/" + name)
      File.delete("/etc/openvpn/ccd/" + name)
    end
    if File.exist?("/etc/openvpn/client_files/" + name + ".ovpn")
      File.delete("/etc/openvpn/client_files/" + name + ".ovpn")
    end
    if File.exist?("/etc/openvpn/client_files/" + name + ".zip")
      File.delete("/etc/openvpn/client_files/" + name + ".zip")
    end
    if File.exist?("/etc/openvpn/client_files/" + name + "_portable.zip")
      File.delete("/etc/openvpn/client_files/" + name + "_portable.zip")
    end
  end
end
