require "bundler/setup"
require 'sinatra'
require 'shortinator'

require 'hatchet'

register Hatchet

Hatchet.configure do |config|
  config.level :info
end

KEY_FORMAT = /^[0-9a-zA-Z]{7}$/

def html_wrapper(content)
  "<html><body>#{content}</body></html>"
end

get '/' do
  [ 200, {}, html_wrapper("Shortinator") ]
end

get '/:id' do
  halt(404, "Not found") unless KEY_FORMAT.match(params[:id])

  begin
    redirect_to_url = Shortinator.click(params[:id], "0.0.0.0")
    logger.info "redirect_to_url=#{redirect_to_url}"
    [ 302, { "Location" => redirect_to_url }, html_wrapper("<a href=\"#{redirect_to_url}\">#{redirect_to_url}</a>")]
  rescue => e
    logger.error e.message
    halt(404, "Not found")
  end
end