module Eiwa
  module Tag
    class Entity < Any
      def add_characters(s)
        code = s.chomp
        set_entity(code, ENTITIES[code])
      end
    end
  end
end

module Eiwa
  module Jmdict
    class Doc < Nokogiri::XML::SAX::Document
      def start_element(name, attrs)
        Rails.logger.info "Start element: #{name}, #{attrs}"
        parent = @current
        @current = (TAGS[name] || Tag::Other).new
        @current.start(name, attrs, parent)
      end

      def end_element(name)
        Rails.logger.info "#{name}"
        raise Eiwa::Error.new("Parsing error. Expected <#{@current.tag_name}> to close before <#{name}>") if @current.tag_name != name
        ending = @current
        ending.end_self
        if ending.is_a?(Tag::Entry)
          @each_entry_block&.call(ending)
        end

        @current = ending.parent
        @current&.end_child(ending)
      end

      def characters(s)
        Rails.logger.info "Characters: #{s}"
        @current.add_characters(s)
      end

      def comment string
        Rails.logger.info "comment #{string}"
      end

      def warning string
        Rails.logger.info "warning #{string}"
      end

      def get_entity name
        p [__method__, name]
      end

      def cdata_block string
        Rails.logger.info "cdata_block #{string}"
      end

      def processing_instruction name, content
        Rails.logger.info "processing_instruction #{name}, #{content}"
      end

      def error(msg)
        Rails.logger.info "Error: #{msg}"
        if (matches = msg.match(/Entity '(\S+)' not defined/))
          # See: http://github.com/sparklemotion/nokogiri/issues/1926
          code = matches[1]
          @current.set_entity(code, ENTITIES[code])
          puts msg
        elsif msg == "Detected an entity reference loop\n"
          # Do nothing and hope this does not matter.
          debugger
          msg
        else
          raise Eiwa::Error.new("Parsing error: #{msg}")
        end
      end
    end
  end
end
