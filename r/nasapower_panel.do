cls
clear
// Working directory: the folder containing this file (cd to it if needed)

import excel "data/Korea_re.xlsx", sheet("Sheet 1") firstrow clear
browse

egen KIPS = group(city)
rename YYYYMMDD date

sort KIPS date
order KIPS date city

xtset KIPS date


