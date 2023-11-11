from langchain.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings

from dotenv import load_dotenv

load_dotenv()

query = "recent efficient method to produce stainless"

embeddings = OpenAIEmbeddings()
db = FAISS.load_local("faiss_index", embeddings)
# retriever = db.as_retriever()
# docs = retriever.get_relevant_documents(query)
docs_and_scores = db.similarity_search_with_score(query)

for d in docs_and_scores:
    print(d[0].metadata)
    print(f"score: {d[1]}")
    print(d[0].page_content)
    print("\n\n")


