#
# My Internet Color
# a piece by @gleuch <http://gleu.ch>
# (c)2014, all rights reserved
#
# -----------------------------------------------------------------------------
#
# SVG Generate App
# - create SVG for date
#
#


# DEFAULT OPTIONS
APP_ROOT = File.expand_path('..', File.dirname(__FILE__))
DEBUG = false
TIME_START = Time.now

# LOAD CONFIG
%w{color optparse optparse/date svgen}.each{|r| require r}
require File.join(APP_ROOT, 'config.rb')

# PARSE OPTS, DEFAULTS
start_date, end_date = Date.yesterday, nil
OptionParser.new do |opts|
  opts.banner = ['',"SVG Generate",'-'*80,"Generate SVG pixel image of browse history color data",'',"Usage: #{__FILE__} [options]"].join("\n")
  opts.on("-d date", "--start-date", Date, "Begin Date [YYYY-MM-DD]"){|v| start_date = v} # start date
  opts.on("-e date", "--end-date", Date, "End Date (optional) [YYYY-MM-DD]"){|v| end_date = v} # end date
end.parse!

# CHECK IF END_DATE IS BEFORE BEGIN DATE, EXIT IF SO.
if end_date.present? && start_date > end_date
  puts "End Date must be after Begin Date"
  exit
end

# DATE AND FILE SETUP
formatted_dates = [start_date.strftime('%d %b %Y'),(end_date.present? ? end_date.strftime('%d %b %Y') : nil)].compact.join(' - ')
fname = File.join(APP_ROOT, 'files/svg', "colors-#{[start_date.to_s, end_date.present? ? end_date.to_s : nil].compact.join('-thru-')}.svg")

# SETUP DB QUERY
hist = (end_date.present? ? BrowseHistory.between_dates(start_date, end_date) : BrowseHistory.on_date(start_date))
ct = hist.with_color.count

# CHECK IF ANY RECORDS
unless ct > 0
  puts "There are no results for #{formatted_dates}."
  exit
end

# SVG SETUP
scale, width, height = 50, Math.sqrt(ct).floor, Math.sqrt(ct).ceil
info = "My Internet color, #{formatted_dates}. Average color: ##{hist.avg_hex_color}. Pages browsed: #{hist.count}"
puts '',info

# CREATE SVG STRUCTURE
x, y, i = 0, 0, 0
svg = SVGen::SVG.new(width: (width * scale), height: (height * scale)) do |svg|
  # Add title and description
  svg.title "My Internet Color, #{formatted_dates}"
  svg.desc("\n\n#{info}.\n\nA piece by Greg Leuch [http://gleu.ch]. (c) 2014, all rights reserved.\n\n")

  # Loop through each browse history with page color
  hist.with_color.find_each do |b|
    x, y = (i % width), (i / width).floor
    svg.rect(id: [b.id,b.web_page.uuid].join('/'), fill: "##{b.web_page.hex_color}", x: (x * scale), y: (y * scale), width: scale, height: scale)
    i += 1 # find_each necessary, but does not support .each_with_index :|
  end

  # comment again in footer, for those really looking
  svg.comment! "My Internet Color, #{formatted_dates}. A piece by @gleuch <http://gleu.ch>. (c) 2014, all rights reserved."

  # timestamp when generated
  svg.comment! "SVG generated #{Time.now.strftime('%d %b %Y %H:%I:%S.%L %Z')}."
end

# SAVE FILE
File.open(fname, 'w') {|f| f << svg.generate}
puts "  SVG file:  #{fname}",'',"...done! (#{Time.now - TIME_START} secs)",""
