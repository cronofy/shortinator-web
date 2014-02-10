require 'bundler'
Bundler.require(:default)

Dotenv.load

register Hatchet

load 'config/hatchet.rb'

KEY_REGEX = /\A[0-9a-zA-Z]{5,7}\Z/

def html_wrapper(content)
  "<html><body>#{content}</body></html>"
end

def request_params(request)
  {
    :ip => request.ip,
    :referrer => request.referrer,
    :user_agent => request.user_agent
  }
end

def root_redirect
  @_root_redirect ||= ENV['SHORTINATOR_ROOT_REDIRECT']
end

get '/' do
  if root_redirect
    [302, { "Location" => root_redirect }, html_wrapper("<a href=\"#{root_redirect}\">#{root_redirect}</a>")]
  else
    [200, {}, html_wrapper("Shortinator")]
  end
end

get '/ping' do
  [200, {}, html_wrapper("Pong")]
end

get '/:id' do
  halt(404, "Not found") unless KEY_REGEX.match(params[:id])

  begin
    redirect_to_url = Shortinator.click(params[:id], request_params(request))
    log.info { "id=#{params[:id]} => redirect_to_url=#{redirect_to_url}" }
    [302, { "Location" => redirect_to_url }, html_wrapper("<a href=\"#{redirect_to_url}\">#{redirect_to_url}</a>")]
  rescue => e
    log.error "Error for id=#{params[:id]} - #{e.message}", e
    halt(404, "Not found")
  end
end
