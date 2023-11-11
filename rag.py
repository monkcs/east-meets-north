from langchain.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings

from dotenv import load_dotenv

def run(query:str):
    load_dotenv()

    embeddings = OpenAIEmbeddings()
    db = FAISS.load_local("faiss_index", embeddings)
    docs_and_scores = db.similarity_search_with_score(query)

    for d in docs_and_scores:
        print(d[0].metadata)
        print(f"score: {d[1]}")
        print(d[0].page_content)
        print("\n\n")

    return docs_and_scores


if __name__ == "__main__":
    query = "recent efficient method to produce stainless"
    run(query)
