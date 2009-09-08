require "rubygems"
require "sinatra"
require "oauth"
require "oauth/consumer"

enable :sessions

before do
  session[:oauth] ||= {}  
  @consumer ||=OAuth::Consumer.new "YOUR-KEY-GOES-HERE", "YOUR-SECRET-GOES-HERE", {
    :site => "YOUR-URL-GOES-HERE.com"
  }
  
  if !session[:oauth][:request_token].nil? && !session[:oauth][:request_token_secret].nil?
    @request_token = OAuth::RequestToken.new(@consumer, session[:oauth][:request_token], session[:oauth][:request_token_secret])
  end
  
  if !session[:oauth][:access_token].nil? && !session[:oauth][:access_token_secret].nil?
    @access_token = OAuth::AccessToken.new(@consumer, session[:oauth][:access_token], session[:oauth][:access_token_secret])
  end
end

get "/" do
  if @access_token
    erb :ready
  else
    erb :start
  end
end

get "/request" do
  @request_token = @consumer.get_request_token
  session[:oauth][:request_token] = @request_token.token
  session[:oauth][:request_token_secret] = @request_token.secret
  redirect @request_token.authorize_url
end

get "/callback" do
  @access_token = @request_token.get_access_token :oauth_verifier => params[:oauth_verifier]
  session[:oauth][:access_token] = @access_token.token
  session[:oauth][:access_token_secret] = @access_token.secret
  redirect "/"
end

get "/logout" do
  session[:oauth] = {}
  redirect "/"
end

use_in_file_templates!

__END__

@@ start
<a href="/request">PWN OAuth</a>

@@ ready
OAuth PWND. <a href="/logout">Retreat!</a>