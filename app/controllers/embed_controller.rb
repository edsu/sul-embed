class EmbedController < ApplicationController
  append_view_path Rails.root.join('app', 'views', 'embed')
  before_action :validate_request
  before_action :set_cache
  before_action :allow_iframe, only: :iframe

  def get
    if @embed_request.format.to_sym == :xml
      render xml: Embed::Response.new(@embed_request).embed_hash.to_xml(root: 'oembed')
    else
      render json: Embed::Response.new(@embed_request).embed_hash
    end
  end

  def iframe
    # Trigger purl object validation (will raise Embed::PURL::ResourceNotAvailable)
    @embed_request.purl_object.valid?
    @embed_response = Embed::Response.new(@embed_request)
    render 'iframe'
  end

  def validate_request
    @embed_request ||= Embed::Request.new(params, request)
  end

  rescue_from Embed::Request::NoURLProvided do |e|
    render body: e.to_s, status: 400
  end

  rescue_from Embed::PURL::ResourceNotEmbeddable do |e|
    render body: e.to_s, status: 400
  end

  rescue_from Embed::Request::InvalidURLScheme do |e|
    render body: e.to_s, status: 404
  end

  rescue_from Embed::PURL::ResourceNotAvailable do |e|
    render body: e.to_s, status: 404
  end

  rescue_from Embed::Request::InvalidFormat do |e|
    render body: e.to_s, status: 501
  end

  private

  def set_cache
    return unless Rails.env.production?
    request.session_options[:skip] = true
    response.headers['Cache-Control'] = "public, max-age=#{Settings.cache_life}"
  end

  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end
end
