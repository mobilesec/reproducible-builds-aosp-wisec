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
x_label = "AOSP Tag / Google Build Date"

############
# diff score
set output figure_folder.'/summary-over-time-device.metric.diff-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,5in # default is 5in,3in

data_file = data_folder.'/summary-device.metric.diff-score.dat'
stats data_file using 3 prefix "STATS" nooutput

bm = 0.23
size_overall = 0.35

set multiplot

set format y '%.0f'
set lmargin at screen lm
set logscale y

set border 1+2+4+8
set key autotitle columnhead left top Left reverse height 2
set xlabel x_label offset 0,3
set xtics () nomirror rotate by 90 right
set ylabel "Diff Score (DS)"
set ytics format "10^%T" add ("0" 0.5 2)
set bmargin at screen bm
set tmargin at screen bm + size_overall
set yrange [0.5:]
plot for [i=0:STATS_blocks-2] data_file \
     using 3:xtic(stringcolumn(1)."\n".stringcolumn(2)) index i

unset multiplot
reset

##################
# major diff score
set output figure_folder.'/summary-over-time-device.metric.major-diff-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,5in

data_file = data_folder.'/summary-device.metric.major-diff-score.dat'
stats data_file using 3 prefix "STATS" nooutput

bm = 0.23
size_overall = 0.35

set multiplot

set format y '%.0f'
set lmargin at screen lm
set logscale y

set border 1+2+4+8
set key autotitle columnhead left top Left reverse height 2
set xlabel x_label offset 0,3
set xtics () nomirror rotate by 90 right
set ylabel "Major Diff Score (MDS)"
set ytics format "10^%T" add ("0" 0.5 2)
set bmargin at screen bm
set tmargin at screen bm + size_overall
set yrange [0.5:]
plot for [i=0:STATS_blocks-2] data_file \
     using 3:xticlabel(stringcolumn(1)."\n".stringcolumn(2)) index i

unset multiplot
reset

##############
# weight score
set output figure_folder.'/summary-over-time-device.metric.weight-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 size 5in,5in

data_file = data_folder.'/summary-device.metric.weight-score.dat'
stats data_file using 5 prefix "STATS" nooutput

bm = 0.30

set multiplot

set lmargin at screen lm
unset logscale y

unset key
set border 1+2+4+8
set key autotitle columnhead left bottom Left reverse
set xtics () nomirror rotate by 90 right
set xlabel x_label offset 0,3
set ylabel "Weight Score (WS)"
set bmargin at screen bm
set tmargin at screen bm + size_overall
plot for [i=0:STATS_blocks-2] data_file \
     using 5:xticlabel(stringcolumn(1)."\n".stringcolumn(2)) index i

unset multiplot
reset

####################
# major weight score
set output figure_folder.'/summary-over-time-device.metric.major-weight-score.pdf'
set style data linespoints
set term pdfcairo noenhanced linewidth 1.5 #size 5in,5in

data_file = data_folder.'/summary-device.metric.major-weight-score.dat'
stats data_file using 5 prefix "STATS" nooutput

bm = 0.30
size_overall = 0.35

set multiplot

set lmargin at screen lm
unset logscale y

set border 1+2+4+8
set key autotitle columnhead left bottom Left reverse
set xlabel x_label offset 0,3
set xtics () nomirror rotate by 90 right
set ylabel "Major Weight Score (MWS)"
set bmargin at screen bm
set tmargin at screen bm + size_overall
plot for [i=0:STATS_blocks-2] data_file \
     using 5:xticlabel(stringcolumn(1)."\n".stringcolumn(2)) index i

unset multiplot
reset
