class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  has_many :certificates, :dependent => :destroy
  has_and_belongs_to_many :roles
  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable, :trackable, :validatable
  validates :username, :presence => true
  validates :username, :uniqueness => true
  validates :username, :format => { :with => %r{^[^@/\\'`~"+*#^;:<>\s"\]\[\{\}]*\z$}i }
  validates :cert_limit, :numericality => { :only_integer => true }, :on => :update

  before_create :setup_role, :setup_cert_limit

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :role_ids, :banned, :cert_limit

  def role?(role)
    return !!self.roles.find_by_name(role.to_s)
    # self.roles.exists?(:name => role.to_s)
  end
  
  private
  def setup_role
    if self.role_ids.empty?
      self.role_ids = [Role.select("id").find_by_name("customer").id]
      # self.role_ids = [2]
    end
  end
  def setup_cert_limit
    if self.cert_limit==nil
      self.cert_limit = 3
    end
  end
end
