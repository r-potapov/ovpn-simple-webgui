class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  # GET /users
  # GET /users.xml
  def index
    # @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    # @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    # @user = User.new
    @current_method = "new"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    # @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    # @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => t('.user_was_created') ) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    # @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => t('.user_was_updated') ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    # @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # Блокировка пользователя и отзыв его сертификатов
  def bann_usr
    # @user = User.find(params[:id])
    @user.banned=1
    certificates = @user.certificates.all
    certificates.each do |certificate|
      certificate.destroy
    end
    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => t('.user_was_banned') ) }
        format.xml  { render :xml => @user}
      else
        format.html { redirect_to(@user, :notice => t('.user_was_not_banned') ) }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Разблокировка пользователя
  def unbann_usr
    # @user = User.find(params[:id])
    @user.banned=nil
    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => t('.user_was_unbanned') ) }
        format.xml  { render :xml => @user}
      else
        format.html { redirect_to(@user, :notice => t('.user_was_not_unbanned') ) }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end
