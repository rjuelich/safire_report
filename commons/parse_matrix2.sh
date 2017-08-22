#!/bin/bash

input=$1
output=$2

echo matlab -nojvm -nodesktop -nosplash -nodisplay -r "parse_matrix2('$input', '$output'); quit"
matlab -nojvm -nodesktop -nosplash -nodisplay -r "parse_matrix2('$input', '$output'); quit"
