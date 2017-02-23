module ActivateApp
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Helpers
    register WillPaginate::Sinatra
    helpers Activate::DatetimeHelpers
    helpers Activate::ParamHelpers
    helpers Activate::NavigationHelpers
            
    use Dragonfly::Middleware       
    use Airbrake::Rack    
    use OmniAuth::Builder do
      provider :account
      Provider.registered.each { |provider|
        provider provider.omniauth_name, ENV["#{provider.display_name.upcase}_KEY"], ENV["#{provider.display_name.upcase}_SECRET"]
      }
    end 
    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
    
    set :sessions, :expire_after => 1.year    
    set :public_folder, Padrino.root('app', 'assets')
    set :default_builder, 'ActivateFormBuilder'    
    
    Mail.defaults do
      delivery_method :smtp, {
        :user_name => ENV['SMTP_USERNAME'],
        :password => ENV['SMTP_PASSWORD'],
        :address => ENV['SMTP_ADDRESS'],
        :port => 587
      }   
    end
       
    before do
      redirect "http://#{ENV['DOMAIN']}#{request.path}" if ENV['DOMAIN'] and request.env['HTTP_HOST'] != ENV['DOMAIN']
      Time.zone = (current_account and current_account.time_zone) ? current_account.time_zone : 'London'
      fix_params!
      if params[:sign_in_token] and account = Account.find_by(sign_in_token: params[:sign_in_token])
        session[:account_id] = account.id
        account.update_attribute(:sign_in_token, SecureRandom.uuid)
      end      
      @_params = params; def params; @_params; end # force controllers to inherit the fixed params
      @title = 'Huddl'
      @og_desc = 'For co-created gatherings'
      @og_image = "http://#{ENV['DOMAIN']}/images/penguins-link.png"
    end        
                
    error do
      Airbrake.notify(env['sinatra.error'], :session => session)
      erb :error, :layout => :application
    end        
    
    not_found do
      erb :not_found, :layout => :application
    end
    
    get '/' do
      erb :home
    end
    
    get '/h/:slug/diff' do
      halt unless current_account and current_account.admin?
      @group = Group.find_by(slug: params[:slug]) || not_found
      @membership = @group.memberships.find_by(account: current_account)
      group_admins_only!
      erb :diff      
    end
    
    post '/update_facebook_name/:id' do
      halt unless current_account and current_account.admin?
      Account.find(params[:id]).update_attribute(:facebook_name, params[:facebook_name])
      redirect back
    end
                                
    get '/:slug' do
      if @fragment = Fragment.find_by(slug: params[:slug], page: true)
        erb :page
      else
        pass
      end
    end    
     
  end         
end
