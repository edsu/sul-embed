[![Build Status](https://travis-ci.org/sul-dlss/sul-embed.svg?branch=master)](https://travis-ci.org/sul-dlss/sul-embed) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/sul-embed/badge.svg)](https://coveralls.io/r/sul-dlss/sul-embed) |
[![Dependency Status](https://gemnasium.com/sul-dlss/sul-embed.svg)](https://gemnasium.com/sul-dlss/sul-embed) | [![Code Climate](https://codeclimate.com/github/sul-dlss/sul-embed/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/sul-embed)

# SUL-Embed

An [oEmbed](http://oembed.com/) provider for embedding resources from the Stanford University Library.

## Development/Test Sandbox

There is an embedded static page available at `/pages/sandbox` in your development and test environments. Make sure that you use the same host on the service input (first text field) as you are accessing the site from (e.g. localhost or 127.0.0.1).

## oEmbed specification details

URL scheme: `http://purl.stanford.edu/*`

API endpoint: `TBD`

Example: `TBD?url=http://purl.stanford.edu/zw200wd8767&format=json`

## Adding vendor assets with bower

Requires [bower](http://bower.io/) and uses [bower-rails](https://github.com/42dev/bower-rails) gem

    npm install -g bower

Assets can be installed using bower commands

    bower install listjs --save

Make sure to run the clean rake task to remove all of the extra stuff from bower packages (leaves the specified main file)

    rake bower:clean

Assets can now be referenced in the assset pipeline

    //= require listjs/dist/list

Assets used for production should be checked in so that dev and prod servers do not need to depend on nodejs and bower.

## Creating Viewers

You can create a viewer by implementing a class with a pretty simple API.

The viewer class will be instantiated with an Embed::Request object. The `initialize` method is included in the `CommonViewer` mixin but can be overridden

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer

      end
    end

The class must implement a `#body_html` method which will be called on the instance of the viewer class. The results of this method combined with `header_html` and `body_html` from `CommonViewer` and will be returned as the HTML of the oEmbed response object.

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer

        def body_html
          "<p>#{@purl_object.type}</p>"
        end
      end
    end


The class must define a class method returning an array of which types it will support.  These types are derived from the type attribute from the contentMetadata.

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer

        def body_html
          "<p>#{@purl_object.type}</p>"
        end
        def self.supported_types
          [:demo_type]
        end
      end
    end


The file that the class is defined in (or your preferred method) should register itself as a view with the Embed module.

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer

        def body_html
          "<p>#{@purl_object.type}</p>"
        end
        def self.supported_types
          [:demo_type]
        end
      end
    end

    Embed.register_viewer(Embed::DemoViewer) if Embed.respond_to?(:register_viewer)


### Console Example

    $ viewer = Embed.registered_viewers.first
    => Embed::DemoViewer
    $ request = Embed::Request.new({url: 'http://purl.stanford.edu/bb112fp0199'})
    => #<Embed::Request>
    $ viewer.new(request).to_html
    => # your body_html with header and footer html

### Adding Header Tools

Viewers can dynamically add their own elements to the header, change element order, or remove elements from the viewer.  In order to add your own tools to the header you need to append a method (represented by a symbol) to the `header_tools_logic` array.

    def initialize(*args)
      super
      header_tools_logic << :render_demo_tool
    end

The method added to the `header_tools_logic` array should return false if the tool should not display or return a symbol representing a method that will return HTML given the `Nokigiri::HTML` document context.

    def render_demo_tool
      return false if should_render_demo_tool?
      :demo_tool_html
    end
    def domo_tool_html(document)
      document.div(class: 'sul-embed-demo-tool') do
        document.text("ToolText")
      end
    end
