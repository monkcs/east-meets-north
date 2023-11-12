# https://python.langchain.com/docs/modules/data_connection/retrievers/vectorstore

# %%
from langchain.document_loaders import TextLoader
from langchain.document_loaders import DirectoryLoader

from langchain.text_splitter import CharacterTextSplitter
from langchain.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings

import os

from dotenv import load_dotenv
load_dotenv()

loader = DirectoryLoader('./docs', glob="*.pdf", show_progress=True, use_multithreading=True)

documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)
embeddings = OpenAIEmbeddings()
db = FAISS.from_documents(texts, embeddings)
db.save_local("faiss_index")

# retriever = db.as_retriever()

# docs = retriever.get_relevant_documents("what is the efficient llm?")
# print(docs)