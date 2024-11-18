#!/bin/bash
#SBATCH -c 1                               
#SBATCH -t 06-00:00                         # Runtime in D-HH:MM format
#SBATCH -p long                         
#SBATCH --mem=1M                      
#SBATCH -o status.out                
                 

echo "STATUS CHECK START"

while true; do
    if sinfo  --Format=nodehost,available,memory,statelong,gres:40 -p gpu,gpu_quad,gpu_requeue | grep  "idle"| grep -q -i -E 'V100|a100'; then
         echo -e  "Time $(date)\n $(sinfo  --Format=nodehost,available,memory,statelong,gres:40 -p gpu,gpu_quad,gpu_requeue | grep "idle")" | mail -s "GPU AVAILABLE" your_email@gmail.com
         sleep 10
        break
    fi
    sleep 10
done

echo "STATUS CHECK FINISHED"
