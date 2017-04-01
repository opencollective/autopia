Huddl::App.controller do
  
  post '/h/:slug/add_member' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only! 
      
    if !params[:email] or !params[:name]
      flash[:error] = "Please provide a name and email address"
      redirect back        
    end
            
    if !(@account = Account.find_by(email: /^#{Regexp.escape(params[:email])}$/i))
      @account = Account.new(name: params[:name], email: params[:email], password: Account.generate_password(8))
      if !@account.save
        flash[:error] = "<strong>Oops.</strong> Some errors prevented the account from being saved."
        redirect back
      end
    end
      
    if @group.memberships.find_by(account: @account)
      flash[:notice] = "That person is already a member of the group"
      redirect back
    else
      @group.memberships.create! account: @account, added_by: current_account
      redirect back
    end       
        
  end
            
  get '/memberships/:id/make_admin' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    membership.admin = true
    membership.admin_status_changed_by = current_account
    membership.save!
    membership.notifications.where(:type.in => ['made_admin', 'unadmined']).destroy_all
    membership.notifications.create! :group => @group, :type => 'made_admin'
    redirect back      
  end
    
  get '/memberships/:id/unadmin' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    membership.admin = false
    membership.admin_status_changed_by = current_account
    membership.save!
    membership.notifications.where(:type.in => ['made_admin', 'unadmined']).destroy_all
    membership.notifications.create! :group => @group, :type => 'unadmined'
    redirect back      
  end    
    
  get '/memberships/:id/remove' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    membership.destroy
    redirect back      
  end    
        
  post '/memberships/:id/paid' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    membership.paid = params[:paid]
    membership.save
    200
  end  
      
  post '/memberships/:id/tier' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    @group.tierships.find_by(account: membership.account_id).try(:destroy)
    @group.tierships.create(account: membership.account_id, tier_id: params[:tier_id])
    200
  end    
      
  post '/memberships/:id/accom' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    @group.accomships.find_by(account: membership.account_id).try(:destroy)
    @group.accomships.create(account: membership.account_id, accom_id: params[:accom_id])
    200
  end   
      
  post '/memberships/:id/booking_limit' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    membership.update_attribute(:booking_limit, params[:booking_limit])
    200
  end   
  
  get '/membership_row/:id' do
    membership = Membership.find(params[:id]) || not_found
    @group = membership.group
    @membership = @group.memberships.find_by(account: current_account)
    membership_required!
    partial :'members/membership_row', :locals => {:membership => membership}
  end     
  
    get '/update_facebook_name/:id' do
      halt unless current_account and current_account.admin?
      account = Account.find(params[:id]) || not_found
      partial :'members/update_facebook_name', :locals => {:account => account}
    end    
    
    post '/update_facebook_name/:id' do
      halt unless current_account and current_account.admin?
      Account.find(params[:id]).update_attribute(:facebook_name, params[:facebook_name])
      200
    end  
  
end