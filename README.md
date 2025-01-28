
#Setting up VLLM for inference on O2

```
srun -n 1 --pty -t 1:00:00 -p gpu_quad --gres=gpu:teslaV100s:1 --mem=32G  bash

conda create -n vllm_inference python=3.10 -y
conda activate vllm_inference
module load  gcc/9.2.0 cuda/12.1

pip install -r vllm_requirements.txt

python test_genie.py
```


