Autopia::App.controller do
    
  get '/a/new' do
    sign_in_required!
    @group = Group.new
    Group.enablable.each { |x|
      @group.send("enable_#{x}=", true)
    }
    discuss 'Create a group'
    erb :'groups/build'
  end  
    
  post '/a/new' do
    sign_in_required!
    @group = Group.new(params[:group])
    @group.account = current_account
    if @group.save
      redirect "/a/#{@group.slug}"
    else
      flash.now[:error] = 'Some errors prevented the group from being created'
      erb :'groups/build'
    end
  end
  
  get '/a/:slug' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    @notifications = @group.notifications_as_circle.order('created_at desc').page(params[:page])
    if !@membership
      if @group.enable_applications
        redirect "/a/#{@group.slug}/apply"
      else
        redirect "/a/#{@group.slug}/join"
      end
    end
    discuss 'Group homepage'
    erb :'groups/group'
  end  
      
  get '/a/:slug/todos' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    partial :'groups/todos'
  end   
      
  get '/a/:slug/edit' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    discuss 'Group settings'
    erb :'groups/build'
  end  
    
  post '/a/:slug/edit' do
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    if @group.update_attributes(params[:group])
      redirect "/a/#{@group.slug}"
    else
      flash.now[:error] = 'Some errors prevented the group from being created'
      erb :'groups/build'        
    end
  end
  
  get '/a/:slug/destroy' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    @group.destroy
    flash[:notice] = 'The group was deleted'
    redirect '/'
  end  
  
  get '/a/:slug/subscribe' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    partial :'groups/subscribe', :locals => {:membership => @membership}
  end
  
  get '/a/:slug/set_subscribe' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:unsubscribed, nil)
    request.xhr? ? 200 : redirect("/a/#{@group.slug}")
  end      
  
  get '/a/:slug/unsubscribe' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:unsubscribed, true)
    request.xhr? ? 200 : redirect("/a/#{@group.slug}")
  end  
  
  get '/a/:slug/show_in_sidebar' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:hide_from_sidebar, nil)
    redirect "/a/#{@group.slug}"
  end      
  
  get '/a/:slug/hide_from_sidebar' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:hide_from_sidebar, true)
    redirect "/a/#{@group.slug}"
  end     
  
  get '/a/:slug/joined_facebook_group' do
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!
    @membership.update_attribute(:member_of_facebook_group, true)
    redirect "/a/#{@group.slug}"
  end   
  
  get '/a/:slug/map' do
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    confirmed_membership_required!    
    @accounts = @group.members
    discuss 'Map'
    erb :'groups/map'    
  end
        
end