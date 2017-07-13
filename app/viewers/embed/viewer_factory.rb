module Embed
  class ViewerFactory
    delegate :height, :width, to: :viewer
    def initialize(request)
      @request = request
      raise Embed::PURL::ResourceNotEmbeddable unless request.purl_object.valid?
    end

    def viewer
      @viewer ||= registered_or_default_viewer.new(@request)
    end

    private

    def registered_or_default_viewer
      registered_viewer || default_viewer
    end

    def default_viewer
      Embed::Viewer::File
    end

    def registered_viewer
      @registered_type ||= Embed.registered_viewers.detect do |type_class|
        type_class.supported_types.include?(@request.purl_object.type.to_sym)
      end
    end
  end
end
