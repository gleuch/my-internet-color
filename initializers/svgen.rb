module SVGen
  module Element
    class Title
      def initialize(text)
        @text, @attrs = text
      end

      def generate(svg)
        svg.title(@text)
      end
    end

    class Desc
      def initialize(text, attrs = {})
        @text, @attrs = text, attrs
      end

      def generate(svg)
        svg.desc(@text, @attrs)
      end
    end

    class Comment
      def initialize(text)
        @text = text
      end

      def generate(svg)
        svg.comment!(@text)
      end
    end

    class Cdata
      def initialize(text)
        @text = text
      end

      def generate(svg)
        svg.cdata!(@text)
      end
    end
  end

  module Nestable
    def title(text)
      @children << Element::Title.new(text)
    end

    def desc(text, attrs = {})
      @children << Element::Desc.new(text, attrs)
    end

    def comment!(text)
      @children << Element::Comment.new(text)
    end

    def cdata!(text)
      @children << Element::Cdata.new(text)
    end
  end
end