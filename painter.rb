#!/usr/bin/env ruby

require 'fileutils'
require 'date'

$profile = "michalzelinka"
$repo_path = "."

$graph_height =  7  # Saturday to Sudnay
$graph_width  = 54  # weeks

FileUtils.cd(File.dirname(File.expand_path(__FILE__)))
FileUtils.cd $repo_path

$columns_from_right = 7
$painting = <<EOF
                    █
██ ██ █ ███ █  █ █  █
█ █ █ █ █   ████ █  █
█ █ █ █ ███ █  █ █
                    █
EOF

painting_lines = $painting.split("\n").count
painting_cols = $painting.split("\n").map{|l| l.length }.max

throw :notEnoughLinesOfPainting if painting_lines > 5 || painting_lines < 1
throw :tooFarRight if $columns_from_right < 1
throw :paintingTooWide if painting_cols + $columns_from_right > $graph_width

start_line = (($graph_height - painting_lines) / 2.0).ceil.to_i
start_column = $graph_width - $columns_from_right - painting_cols

today = Date.today
sunday = today - today.wday
first_day_in_graph = (sunday - ($graph_height * ($graph_width - 1)))
start_col_first_day = (sunday - ($graph_height * (painting_cols + $columns_from_right + 1)))

$painting.split("\n").each_with_index{|l,li|
#	puts l
	chars = l.split ""
#	puts chars
	chars.each_with_index{|c,ci|
		next if c == ' '
		draw_date = start_col_first_day + (ci * $graph_height) + li + start_line
		draw_date_str = draw_date.strftime "%Y-%m-%dT%h:%i:%sZ"
#		puts draw_date
		10.times{|i| `git commit --allow-empty -m "Paint" --date #{draw_date_str}` }
	}
}
