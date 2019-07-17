Autopia::App.controller do
  
  get '/map' do
    sign_in_required!
    @place = Place.new
    @accounts = current_account.network + [current_account]
    @places = Place.all
    discuss 'Map'
    erb :'places/map'
  end
    
  get '/point/:model/:id' do
    partial "maps/#{params[:model].downcase}".to_sym, :object => params[:model].constantize.find(params[:id])
  end   
  
  get '/places' do
    redirect '/map'
  end

  post '/places/new' do
    sign_in_required!
    @place = current_account.places.build(params[:place])
    if @place.save
      redirect '/places'
    else
      flash[:error] = 'There was an error saving the place.'
      erb :'places/places'
    end
  end  
  
  get '/places/:id' do
    sign_in_required!
    @place = Place.find(params[:id]) || not_found   
    erb :'places/place'
  end  
  
  get '/places/:id/edit' do
    sign_in_required!
    @place = current_account.places.find(params[:id]) || not_found
    erb :'places/build'
  end
      
  post '/places/:id/edit' do
    sign_in_required!
    @place = current_account.places.find(params[:id]) || not_found
    if @place.update_attributes(params[:place])
      redirect "/places/#{@place.id}"
    else
      flash[:error] = 'There was an error saving the place.'
      erb :'places/build'
    end
  end 
  
  get '/places/:id/destroy' do
    sign_in_required!
    @place = current_account.places.find(params[:id]) || not_found
    @place.destroy
    redirect '/places'
  end    
         
  
end