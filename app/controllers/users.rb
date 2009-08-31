class Users < Application
  
  def show
    @user = User.first :username => params[:id]
    @alert_shows = @user.alerts.map{|a| a.show}
    @favorite_shows = @user.favorites.map{|f| f.show}
    render
  end
  
  def mini_register
    @user = session.user!
    attributes = params[:user].slice(:username, :password, :password_confirmation)
    
    if @user.setup(attributes)
      partial "dropmenu/account", :visible => true, :refresh_all => true
    else
      partial "dropmenu/account_new", :register_error => true, :visible => true
    end
  end
  
  def mini_login
    begin
      ensure_authenticated
      partial "dropmenu/account", :refresh_all => true, :visible => true
    rescue Merb::Controller::Unauthenticated => e 
      params[:password] = nil
      partial "dropmenu/account_new", :login_msg => "Login Failed", :login_error => true, :visible => true
    end
  end
  
  def mini_counts
    # TODO
    {:favorites_count => session.user!.favorites_count, :alerts_count => session.user!.alerts_count}.to_json
  end
  
  def mini_account
    partial "dropmenu/account", :visible => (params[:visible] == "true")
  end
  
  def mini_account_update
    @user = session.user!
    
    update_msg = nil
    update_error = false
    password_visible = false
    
    # update stuff
    @user.attributes = params[:user].slice(:password, :password_confirmation)
    
    if @user.save
      update_msg = "Saved"
      @user.password = nil
      @user.password_confirmation = nil
    else
      update_msg = "Error Saving Contact Data"
      password_visible = true
      update_error = true
    end
    
    partial "dropmenu/account", :visible => true, :update_msg => update_msg, :update_error => update_msg, :password_visible => password_visible
  end

  def mini_alerts_update
    @user = session.user!
    
    update_msg = nil
    update_error = false

    # update stuff
    @user.attributes = params[:user].slice(:email, :sms_number, :sms_carrier, :gtalk_id)
    
    if @user.save(:update_contact)
      update_msg = "Saved"
    else
      update_msg = "Error Saving Contact Data"
      update_error = true
    end
    
    partial "dropmenu/alerts", :visible => true, :update_msg => update_msg, :update_error => update_msg
  end
  
  def mini_alerts
    partial "dropmenu/alerts", :visible => (params[:visible] == "true")
  end
  
  def mini_favorites
    partial "dropmenu/favorites", :visible => (params[:visible] == "true")
  end
  
  def profile
    render
  end
  
  def alerts
    render
  end
  
end