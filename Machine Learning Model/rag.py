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
        if d[1] >= score:
            score = d[1]
            best_doc = d[0]
            most_similar_content = d[0].page_content
    
    prompt = PromptTemplate(template=template, input_variables=["question"])
    model = OpenAI()

    chain = (
        prompt
        | model
        | StrOutputParser()
    )

    short_answer = chain.invoke({"context": most_similar_content, "question": query})

    return best_doc, short_answer


if __name__ == "__main__":
    query = "what is the recent efficient method to produce stainless?"
    run(query)
