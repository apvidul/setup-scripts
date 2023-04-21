#!/bin/bash
echo "STATUS CHECK START"

while true; do
    if sinfo  --Format=nodehost,available,memory,statelong,gres:40 -p gpu,gpu_quad,gpu_requeue | grep  "idle"| grep -q -i -E 'v100|RTX'; then
         echo -e  "Time $(date)\n $(sinfo  --Format=nodehost,available,memory,statelong,gres:40 -p gpu,gpu_quad,gpu_requeue | grep "idle")" | mail -s "GPU AVAILABLE" apvidul@gmail.com
         sleep 10
        break
    fi
    sleep 10
done

echo "STATUS CHECK FINISHED"
