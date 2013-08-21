require 'cgi'

module SonicPi
  module Util
    def os
      case RUBY_PLATFORM
      when /.*linux.*/
        :linux
      when /.*darwin.*/
        :osx
      when /.*mswin.*/
        :windows
      else
        raise "Unsupported platform #{RUBY_PLATFORM}"
      end
    end

    def root_path
      File.absolute_path("#{File.dirname(__FILE__)}/../../")
    end

    def etc_path
      File.absolute_path("#{root_path}/etc")
    end

    def log_path
      File.absolute_path("#{root_path}/log")
    end

    def tmp_path
      File.absolute_path("#{root_path}/tmp")
    end

    def synthdef_path
      File.absolute_path("#{etc_path}/synthdefs")
    end

    def log(message)
      File.open("#{log_path}/sonicpi.log", 'a') {|f| f.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} #{message}\n")}
    end

    def web_render(message)
      puts "rendering: #{message}"

      return CGI::escapeHTML(message) if message.instance_of? String

      case message[:kind]
      when :code_list
        "<ul>" + message[:val].inject(""){|res, val| res << "<li><code>" << CGI::escapeHTML(val) << "</code></li>"} + "</ul>"
      when :list
        "<ul>" + message[:val].inject(""){|res, val| res << "<li>" << CGI::escapeHTML(val) << "</li>"} + "</ul>"
      when :code
        "<code>" + CGI::escapeHTML(message[:val]) + "</code>"
      when :error

        '<code> <pre class="expandable">' + CGI::escapeHTML(message[:val]) + "</pre>" + '<pre class="hidden-content" style="display:none;">' + CGI::escapeHTML(message[:backtrace].inject("") {|s, l| s << l << "\n"}) + "</pre> </code>"
      when :image
        puts "rendering image"
        scale = message[:scale] || 1
        height = (message[:height] || 50) * scale
        width = (message[:height] || 80) * scale
        puts "yuo: #{scale}, #{width}, #{height}"
        code = '<img src="' + CGI::escapeHTML(message[:val]) + '" height=' + height.to_s + ' width=' + width.to_s + ' />'
        puts code
        code
      else
        CGI::escapeHTML(message[:val])
      end
    end

  end
end
