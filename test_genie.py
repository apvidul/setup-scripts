import json
from vllm import LLM, SamplingParams



model = LLM(model='THUMedInfo/GENIE_en_8b', tensor_parallel_size=1)
PROMPT_TEMPLATE = "Human:\n{query}\n\n Assistant:"

temperature = 0.7         
max_new_token = 150        

sampling_params = SamplingParams(temperature=temperature, max_tokens=max_new_token)


EHR = [
    "A 45-year-old male presents with fatigue, fever, and sore throat. What is the most likely diagnosis, and what medications should be prescribed?",
    "A 67-year-old female with a history of hypertension and diabetes presents with chest pain and shortness of breath. What should be the diagnosis and recommended medication?",
    "A 30-year-old male presents with severe abdominal pain, nausea, and vomiting. What lab tests should be ordered for diagnosis?",
    "A 56-year-old female with a family history of breast cancer presents with a lump in her breast. What is the diagnosis and what imaging tests should be ordered?"
]


texts = [PROMPT_TEMPLATE.format(query=k) for k in EHR]
outputs = model.generate(texts, sampling_params)
responses=[]

for output in outputs:
	response = output.outputs[0].text
	print(response)
