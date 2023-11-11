# https://python.langchain.com/docs/integrations/llms/huggingface_hub

# 1. Setup
from getpass import getpass

# HUGGINGFACEHUB_API_TOKEN = getpass()
HUGGINGFACEHUB_API_TOKEN = "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"

import os

os.environ["HUGGINGFACEHUB_API_TOKEN"] = HUGGINGFACEHUB_API_TOKEN


# 2. Prepare Examples
from langchain.llms import HuggingFaceHub
from langchain.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("tell me a joke about {foo}")

repo_id = "HuggingFaceH4/zephyr-7b-beta"  
model = HuggingFaceHub(
    repo_id=repo_id, model_kwargs={"temperature": 0.5}
)

chain = prompt | model
result = chain.invoke({"foo": "bears"})
print(result)