Huddl::App.controller do
    
  get '/h/:slug/balance' do        
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    erb :'groups/balance'
  end    
	
  post '/h/:slug/pay' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)    
    membership_required!
    Stripe.api_key = ENV['STRIPE_SK']
    Stripe::Charge.create(
      :source => params[:id],
      :amount => params[:amount].to_i * 100,
      :currency => @group.currency,
      :receipt_email => params[:email],
      :description => "Payment for #{@group.name}"
    )
    @membership.payments.create! :amount => params[:amount].to_i, :currency => @group.currency
    @membership.update_attribute(:paid, @membership.paid + params[:amount].to_i)
    @group.update_attribute(:processed_via_stripe, @group.processed_via_stripe + params[:amount].to_i)
    @group.update_attribute(:balance, @group.balance + params[:amount].to_i*0.95)
    200
  end 
  
  post '/h/:slug/payout' do
    @group = Group.find_by(slug: params[:slug]) || not_found      
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    if @group.update_attributes(params[:group])
    	
    	if ENV['SMTP_ADDRESS']
	      mail = Mail.new
	      mail.to = ENV['ADMIN_EMAIL']
	      mail.from = ENV['BOT_EMAIL']
	      mail.subject = "Payout requested for #{@group.name}"
	      mail.body = "#{current_account.name} (#{current_account.email}) requested a payout for #{@group.name}:\n#{@group.currency_symbol}#{@group.balance} to #{@group.paypal_email}"   
	      mail.deliver
      end

			flash[:notice] = 'The payout was requested. Payouts can take 3-5 working days to process.'    	
      redirect "/h/#{@group.slug}"
    else
      flash.now[:error] = 'Some errors prevented the payout'
      erb :'groups/build'        
    end
  end	  
  
end