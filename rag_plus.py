from langchain.vectorstores import FAISS
from langchain.embeddings import OpenAIEmbeddings
from langchain.prompts import PromptTemplate
from langchain.schema.runnable import RunnablePassthrough
from langchain.llms import OpenAI
from langchain.schema.output_parser import StrOutputParser

from dotenv import load_dotenv

template = """Answer the question in two sentences, based only on the following context:
{context}

Question:{question}
"""

def run(query:str):
    load_dotenv()

    embeddings = OpenAIEmbeddings()
    db = FAISS.load_local("faiss_index", embeddings)
    docs_and_scores = db.similarity_search_with_score(query)

    score = 0
    most_similar_content = ""
    for d in docs_and_scores:
        print(d[0].metadata)
        print(f"score: {d[1]}")
        print(d[0].page_content)
        if d[1] >= score:
            most_similar_content = d[0].page_content
        print("\n\n")
    
    prompt = PromptTemplate(template=template, input_variables=["question"])
    model = OpenAI()

    chain = (
        prompt
        | model
        | StrOutputParser()
    )

    short_answer = chain.invoke({"context": most_similar_content, "question": query})

    print(short_answer)

    return docs_and_scores, short_answer


if __name__ == "__main__":
    query = "what is the recent efficient method to produce stainless?"
    run(query)
