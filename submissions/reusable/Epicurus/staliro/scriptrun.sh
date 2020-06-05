#!/bin/bash  
source /etc/profile

module load base/MATLAB/2018a

cd "/home/users/kgaaloul/Projects/assume1/assume/staliro"

matlab -nodisplay -nosplash -r 'run setup_staliro.m'

exit
