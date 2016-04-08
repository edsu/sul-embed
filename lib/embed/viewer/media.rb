require 'embed/media_tag'
module Embed
  class Viewer
    class Media < CommonViewer
      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(
            class: 'sul-embed-body sul-embed-media',
            'style' => "max-height: #{body_height}px",
            'data-sul-embed-theme' => asset_url('media.css').to_s
          ) do
            Embed::MediaTag.new(doc, self)
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('media.js')}\");" }
          end
        end.to_html
      end

      def self.supported_types
        return [] unless ::Settings.enable_media_viewer?
        [:media]
      end

      private

      def default_body_height
        400 - (header_height + footer_height)
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::Media) if Embed.respond_to?(:register_viewer)
