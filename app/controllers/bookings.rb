Huddl::App.controller do
  
  get '/h/:slug/bookings' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    membership_required!
    erb :bookings
  end  
  
  get '/h/:slug/book' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    membership_required!
    @group.bookings.create :account => current_account, :date => Date.parse(params[:date])
    redirect back
  end    
  
  get '/bookings/:id/destroy' do
    @booking = Booking.find(params[:id])
    @group = @booking.group
    @membership = @group.memberships.find_by(account: current_account)    
    halt unless (@booking.account.id == current_account.id) or @membership.admin?    
    @booking.destroy
    redirect back
  end
  
end