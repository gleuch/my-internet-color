# Modified from https://gist.github.com/awesome/9964231

module MiniMagick
  class Image
    def pixel_at(x, y)
      case run_command("convert", "#{path}[1x1+#{x}+#{y}]", "-depth", "8", "txt:").split("\n")[1]
      when /^0,0:.*(#[\da-fA-F]{6}).*$/ then $1
      else nil
      end
    end
  end
end