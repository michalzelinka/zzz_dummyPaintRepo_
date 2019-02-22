#!/usr/bin/env ruby

require 'fileutils'
require 'date'

##############
## General config

$repo_path = "."

$graph_height =  7  # Saturday to Sudnay
$graph_width  = 54  # weeks

$graph_year = 2009

FileUtils.cd(File.dirname(File.expand_path(__FILE__)))
FileUtils.cd $repo_path

##############
## User config

# nil & nil = centred painting

$columns_from_left = nil
$columns_from_right = 7

# Palette:
#  |█|  #006729
#  |▓|  #00a33e
#  |▒|  #50d270
#  |░|  #b9eb89
#  | |  #ebedf0

$painting = <<EOF
                    ▓
██ ██ █ ███ █  █ █  ▓
█ █ █ █ █   ████ █  ▓
█ █ █ █ ███ █  █ █
                    ▓
EOF

##############
## The code

painting_lines = $painting.split("\n").count
painting_cols = $painting.split("\n").map{|l| l.length }.max

throw :onlyOneInsetIsValid if $columns_from_left != nil && $columns_from_right != nil
throw :invalidNumberOfPaintingLines if painting_lines > 7 || painting_lines < 1
throw :tooFarRight if $columns_from_right != nil && $columns_from_right < 1
throw :tooFarLeft if $columns_from_left != nil && $columns_from_left < 1
throw :paintingTooWide if $columns_from_right != nil && painting_cols + $columns_from_right > $graph_width
throw :paintingTooWide if $columns_from_left != nil && painting_cols + $columns_from_left > $graph_width

start_line = (($graph_height - painting_lines) / 2.0).ceil.to_i

today = Date.today
sunday = today - today.wday
first_day_in_graph = (sunday - ($graph_height * ($graph_width - 1)))

if $graph_year != nil then
	throw :invalidYear if !$graph_year.is_a?(Fixnum) || $graph_year < 1970
	first_day_in_graph = Date.parse("#{$graph_year}-01-01")
	first_day_in_graph = first_day_in_graph - first_day_in_graph.wday
end

start_column = ($graph_width - painting_cols) / 2
start_column = $columns_from_left if $columns_from_left != nil
start_column = $graph_width - $columns_from_right - painting_cols if $columns_from_right != nil

start_col_first_day = first_day_in_graph + 7*start_column

$painting.split("\n").each_with_index{|l,li|
#	puts l
	chars = l.split ""
#	puts chars
	chars.each_with_index{|c,ci|
		next if c == ' '
		draw_date = start_col_first_day + (ci * $graph_height) + li + start_line
		draw_date_str = draw_date.strftime "%Y-%m-%dT%h:%i:%sZ"
		repeat = 0
		repeat = 30 if c == '█'
		repeat = 20 if c == '▓'
		repeat = 3  if c == '▒'
		repeat = 1  if c == '░'
		# puts draw_date
		repeat.times{|i| `git commit --allow-empty -m "Paint" --date #{draw_date_str}` }
	}
}
