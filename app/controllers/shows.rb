class Shows < Application
  def index
    @shows = Show.all.paginate(:order => [:sort_key], :page => params[:page], :per_page => 12)
    render
  end
  
  def show
    @show = Show.get(params[:id])
    render
  end
  
  def add
    @show = Show.from_tvrage(params[:showid])
    run_later do
      @show.refresh_all if @show
    end
    render
  end
  
  def dashboard
    @user = session.user!
    @alert_shows = @user.alerts.map{|a| a.show}
    @favorite_shows = @user.favorites.map{|f| f.show}
    @top_shows = Show.top_shows
    render
  end
  
  def search
    @local_results = []
    @rage_results = []
    if params[:q].present?
      @local_results = Show.all(:title.like => "%#{params[:q]}%", :limit => 20, :order => [:favorite_count.desc]).paginate(:page => params[:page])
      @rage_results = TvRage.search(params[:q])[0...10] if @local_results.empty?
    else
      @top_shows = Show.top_shows
    end
    
    render
  end
  
  def tooltip
    @show = Show.get(params[:id])
    partial "shows/tooltip", :show => @show
  end
  
  def set_alert
    @show = Show.get(params[:id])
    
    @alert = Alert.set_alert(session.user!, @show, params[:alert])
    @alert.destroy unless (@alert.email_enabled? || @alert.im_enabled? || @alert.sms_enabled?)
    
    partial "shows/tooltip", :show => @show, :refresh_alerts => true
  end
  
  def toggle_favorite
    @show = Show.get(params[:id])
    
    favorite = Favorite.from_pair(session.user!, @show)
    if favorite.new_record?
      favorite.save
    else
      favorite.destroy
    end
    
    partial "shows/tooltip", :show => @show, :refresh_favorites => true
  end
end