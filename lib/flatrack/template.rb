require 'tilt'
require 'flatrack/template/erubis'
require 'flatrack/template/rb'
require 'flatrack/template/html'

class Flatrack
  # The default template parser/finder
  class Template
    # @private
    DEFAULT_FORMAT = 'html'

    attr_reader :type, :file, :format
    delegate :render, to: :@renderer

    # Creates a new template instance and invokes find
    # @param type [Symbol] the type of template
    # @param format [String] the format e.g. html
    # @param file [String] the location of the file
    def self.find(type, format, file)
      new(type, format, file)
    end

    # Creates a new template instance
    # @param type [Symbol] the type of template
    # @param format [String] the format e.g. html
    # @param file [String] the location of the file
    def initialize(type, format, file)
      @format      = format || DEFAULT_FORMAT
      @type, @file = type, file.to_s
      @renderer = find
    end

    private

    def find
      template = find_by_type
      fail FileNotFound, "could not find #{file}" unless template
      Tilt.new template, options
    rescue RuntimeError
      raise TemplateNotFound, "could not find a renderer for #{file}"
    end

    def options
      local_options = {}
      super.merge local_options
    rescue NoMethodError
      local_options
    end

    def find_by_type
      if File.exist?(file)
        file
      else
        file_with_format = [file, format].compact.join('.')
        Dir[File.join type.to_s.pluralize, "#{file_with_format}*"].first
      end
    end
  end
end
