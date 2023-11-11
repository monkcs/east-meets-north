from langchain.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings

from dotenv import load_dotenv

load_dotenv()

query = "what is the efficient llm?"

embeddings = OpenAIEmbeddings()
db = FAISS.load_local("faiss_index", embeddings)
retriever = db.as_retriever()
docs = retriever.get_relevant_documents(query)
print(docs)


