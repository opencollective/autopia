Autopia::App.controller do
  
  get '/gatherings' do
    sign_in_required!
    erb :'gatherings/gatherings'
  end
    
  get '/a/new' do
    sign_in_required!
    @gathering = Gathering.new(currency: current_account.default_currency)
    Gathering.enablable.each { |x|
      @gathering.send("enable_#{x}=", true)
    }
    @gathering.enable_comments_on_gathering_homepage = false
    discuss 'Create a gathering'
    erb :'gatherings/build'
  end  
    
  post '/a/new' do
    sign_in_required!
    @gathering = Gathering.new(params[:gathering])
    @gathering.account = current_account
    if @gathering.save
      redirect "/a/#{@gathering.slug}"
    else
      flash.now[:error] = 'Some errors prevented the gathering from being created'
      erb :'gatherings/build'
    end
  end
  
  get '/a/:slug' do
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found
    @membership = @gathering.memberships.find_by(account: current_account)
    @notifications = @gathering.notifications_as_circle.order('created_at desc').page(params[:page])
    if !@membership
      case @gathering.privacy
      when 'open'
        redirect "/a/#{@gathering.slug}/join"
      when 'closed'
        redirect "/a/#{@gathering.slug}/apply"        
      when 'secret'
        redirect '/'
      end
    end
    discuss 'Gathering homepage'
    erb :'gatherings/gathering'
  end  
        
  get '/a/:slug/todos' do
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found
    @membership = @gathering.memberships.find_by(account: current_account)
    membership_required!
    partial :'gatherings/todos'
  end   
      
  get '/a/:slug/edit' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    gathering_admins_only!
    discuss 'Gathering settings'
    erb :'gatherings/build'
  end  
    
  post '/a/:slug/edit' do
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    gathering_admins_only!
    if @gathering.update_attributes(params[:gathering])
      redirect "/a/#{@gathering.slug}"
    else
      flash.now[:error] = 'Some errors prevented the gathering from being created'
      erb :'gatherings/build'        
    end
  end
  
  get '/a/:slug/destroy' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    gathering_admins_only!
    @gathering.destroy
    flash[:notice] = 'The gathering was deleted'
    redirect '/'
  end  
  
  get '/a/:slug/subscribe' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!
    partial :'gatherings/subscribe', :locals => {:membership => @membership}
  end
  
  get '/a/:slug/set_subscribe' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:unsubscribed, nil)
    request.xhr? ? 200 : redirect("/a/#{@gathering.slug}")
  end      
  
  get '/a/:slug/unsubscribe' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:unsubscribed, true)
    request.xhr? ? 200 : redirect("/a/#{@gathering.slug}")
  end  
  
  get '/a/:slug/show_in_sidebar' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:hide_from_sidebar, nil)
    redirect "/a/#{@gathering.slug}"
  end      
  
  get '/a/:slug/hide_from_sidebar' do        
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:hide_from_sidebar, true)
    redirect "/a/#{@gathering.slug}"
  end     
  
  get '/a/:slug/joined_facebook_group' do
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:member_of_facebook_group, true)
    redirect "/a/#{@gathering.slug}"
  end   
  
  get '/a/:slug/map' do
    @gathering = Gathering.find_by(slug: params[:slug]) || not_found      
    @membership = @gathering.memberships.find_by(account: current_account)
    confirmed_membership_required!    
    @accounts = @gathering.members
    discuss 'Map'
    erb :'gatherings/map'    
  end
        
end