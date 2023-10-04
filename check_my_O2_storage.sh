#!/bin/bash
#SBATCH -p short 
#SBATCH -t 0-2:00 
#SBATCH -c 1
#SBATCH --mem=4G
#SBATCH -o storage_check.log
# Replace MY_MAIN_FOLDER_PATH with path to your main directory. Eg: /n/data1/hsph/biostat/celehs/lab/va67

find MY_MAIN_FOLDER_PATH -type f -exec du -sh {} + | grep -E "^[0-9.]+G" | sort -rh > my_O2Files_and_sizes.txt       
find MY_MAIN_FOLDER_PATH -type d -exec du -sh {} + | grep -E "^[0-9.]+G" | sort -rh > my_O2Folders_and_sizes.txt
