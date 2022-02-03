# Copyright 2022 Manuel Pöll
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Plot the SOAP Report summary CSV over time

lm = 0.13
gap = 0.03
x_label = "Google Incremental Build ID / CI Build Date"
x2_label = "Android Major Release"

############
# diff score
set output figure_folder.'/summary-over-time-generic.metric.diff-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,7in

data_file = data_folder.'/summary-generic.metric.diff-score.dat'
stats data_file using 3 prefix "STATS" nooutput

bm = 0.23
size_overall = 0.21

set multiplot

set lmargin at screen lm

set logscale y

set border 1+2+4+8
set key autotitle columnhead left top Left reverse
set xlabel x_label offset 0,0
set xtics () nomirror rotate by 90 right
set x2label x2_label offset -16,-1
set x2tics ("9" 0, "10" 1, "11" 13, "12" 25)
set ylabel "Diff Score (DS)"
set ytics format "10^%T" add ("0" 0.5 2)
set bmargin at screen bm
set tmargin at screen bm + size_overall
set yrange [0.5:]
plot for [i=0:STATS_blocks-2] data_file \
     using 3:xtic(stringcolumn(2)."  ".stringcolumn(1)) index i

unset multiplot
reset

##################
# major diff score
set output figure_folder.'/summary-over-time-generic.metric.major-diff-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,7in

bm = 0.23
size_overall = 0.21

set logscale y
set key autotitle columnhead

set bmargin at screen bm
set tmargin at screen bm + size_overall

set xlabel x_label offset 0,0
set xtics () rotate by 90 right
set x2label x2_label
set x2tics ("9" 0, "10" 1, "11" 13, "12" 25)
set ylabel "Major Diff Score (MDS)"
set ytics format "10^%T" add ("0" 0.5 2)
set yrange [0.5:]

data_file = data_folder.'/summary-generic.metric.major-diff-score.dat'
stats data_file using 3 prefix "STATS" nooutput
plot for [i=0:STATS_blocks-2] data_file \
     using 3:xtic(stringcolumn(2)."  ".stringcolumn(1)) index i
reset

# weight score
set output figure_folder.'/summary-over-time-generic.metric.weight-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,7in

data_file = data_folder.'/summary-generic.metric.weight-score.dat'
stats data_file using 5 prefix "STATS" nooutput

bm = 0.30
size_overall = 0.32
size_subplot_1_rel = 0.30
size_subplot_2_rel = 0.30
y1 = 0.0; y2 = 0.025; y3 = 0.975; y4 = 1.0;

set multiplot

set lmargin at screen lm

unset logscale y

set border 1+2+8
set key autotitle columnhead left bottom Left reverse height 2
set xlabel x_label offset 0,1
set xtics () nomirror rotate by 90 right
unset x2tics
set ylabel "Weight Score (WS)" offset 1,3
set ytics 0.01
set bmargin at screen bm
set tmargin at screen bm + size_overall * size_subplot_1_rel
set yrange [y1:y2]
plot for [i=0:STATS_blocks-2] data_file \
     using 5:xtic(stringcolumn(2)."  ".stringcolumn(1)) index i

set border 2+4+8
unset key
unset xlabel
unset xtics
unset x2label
set x2tics ("9" 0, "10" 1, "11" 13, "12" 25)
unset ylabel
set ytics 0.01
set bmargin at screen bm + size_overall * size_subplot_1_rel + gap
set tmargin at screen bm + size_overall * size_subplot_1_rel + gap + size_overall * size_subplot_2_rel
set yrange [y3:y4]
plot for [i=0:STATS_blocks-2] data_file \
     using 5:xtic(stringcolumn(2)."  ".stringcolumn(1)) index i

unset multiplot
reset

# major weight score
set output figure_folder.'/summary-over-time-generic.metric.major-weight-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,7in

data_file = data_folder.'/summary-generic.metric.major-weight-score.dat'
stats data_file using 5 prefix "STATS" nooutput

bm = 0.30
size_overall = 0.32
size_subplot_1_rel = 0.30
size_subplot_2_rel = 0.30
y1 = 0.0; y2 = 0.025; y3 = 0.975; y4 = 1.0;

set multiplot

set lmargin at screen lm

unset logscale y

set border 1+2+8
set key autotitle columnhead left bottom Left reverse height 2
set xlabel x_label offset 0,0
set xtics () nomirror rotate by 90 right
set ylabel "Major Weight Score (MWS)"
set ytics 0.05
set bmargin at screen bm
set tmargin at screen bm + size_overall * size_subplot_1_rel
set yrange [y1:y2]
plot for [i=0:STATS_blocks-2] data_file \
     using 5:xtic(stringcolumn(2)."  ".stringcolumn(1)) index i

set border 2+4+8
unset key
unset xlabel
unset xtics
unset x2label
set x2tics ("9" 0, "10" 1, "11" 13, "12" 25)
unset ylabel
set ytics 0.05
set bmargin at screen bm + size_overall * size_subplot_1_rel + gap
set tmargin at screen bm + size_overall * size_subplot_1_rel + gap + size_overall * size_subplot_2_rel
set yrange [y3:y4]
plot for [i=0:STATS_blocks-2] data_file \
     using 5:xtic(stringcolumn(2)."  ".stringcolumn(1)) index i

unset multiplot
reset
