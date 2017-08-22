#!/bin/sh

input=$1
output=$2

echo matlab -nojvm -nodesktop -nosplash -nodisplay -r "PlotIndiv2Group('$input', '$output'); quit"
matlab -nojvm -nodesktop -nosplash -nodisplay -r "PlotIndiv2Group('$input', '$output'); quit"

