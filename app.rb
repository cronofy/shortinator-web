require 'bundler'

Bundler.require(:default)

register Hatchet

Hatchet.configure do |config|
  config.level :info
end

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

get '/' do
  [200, {}, html_wrapper("Shortinator")]
end

get '/:id' do
  halt(404, "Not found") unless Shortinator::KEY_FORMAT.match(params[:id])

  begin
    redirect_to_url = Shortinator.click(params[:id], request_params(request))
    log.info { "redirect_to_url=#{redirect_to_url}" }
    [302, { "Location" => redirect_to_url }, html_wrapper("<a href=\"#{redirect_to_url}\">#{redirect_to_url}</a>")]
  rescue => e
    logger.error e.message
    halt(404, "Not found")
  end
end
