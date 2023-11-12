#!/usr/bin/env python3

import cgi
import json
import subprocess
import sys

from thefuzz import fuzz

sys.path.append('/var/www/ml')
from rag_plus import run

form = cgi.FieldStorage()

class Metadata:
    reliability = 0.0
    doi = ""
    author = ""
    organization = ""
    publication_date = ""
    source = ""
    def __init__(self, reliability, doi, author, organization, publication_date, source):
        self.reliability = reliability
        self.doi = doi
        self.author = author
        self.organization = organization
        self.publication_date = publication_date
        self.source = source

hardcoded_lookup = [
    Metadata(0.81,"10.3390_met10030327","Andrea Di Schino", "Università di Perugia", "March 2020", "https://www.researchgate.net/publication/339637238_Manufacturing_and_Applications_of_Stainless_Steels/fulltext/5e5dab6f299bf1bdb84cbdc5/Manufacturing-and-Applications-of-Stainless-Steels.pdf?origin=publicationDetail&_sg%5B0%5D=bY8Hu2sk11ydh99I55GlhHSIFAIIssXBy7NUWsRUxLaSU6OGTSvokUjGEbE6mZr7yf58TcmVs_E47tDWru-rwQ.tLqRwfFdTnG7pn8D72MiOwmSzpHMFs_L5PN8YJj-_GsSVVsN_JYk4f6oETTXXhrN0woqqyQzxu9ztsOhjIcotw&_sg%5B1%5D=SmW13hyJO4zOfHE3DafTmss7qcvY3Qq4KWxuUMZHEb72yiV90fryP5ZHVigfvHUhOZXj2kn_FUi5rhtXF98WJnoR_DJjkDCB_70PGBckUqSe.tLqRwfFdTnG7pn8D72MiOwmSzpHMFs_L5PN8YJj-_GsSVVsN_JYk4f6oETTXXhrN0woqqyQzxu9ztsOhjIcotw&_iepl=&_rtd=eyJjb250ZW50SW50ZW50IjoibWFpbkl0ZW0ifQ%3D%3D&_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6Il9kaXJlY3QiLCJwYWdlIjoiX2RpcmVjdCIsInBvc2l0aW9uIjoicGFnZUhlYWRlciJ9fQ"),
    Metadata(0.6,"10.1103_PhysRevB.68.104301","L. Brizhik* and A. Eremko", "Bogolyubov Institute for Theoretical Physics", "September 2003", "https://www.researchgate.net/profile/A-Eremko/publication/228437333_Spontaneous_localization_of_electrons_in_lattices_with_nonlocal_interactions/links/00b7d51820a34017a5000000/Spontaneous-localization-of-electrons-in-lattices-with-nonlocal-interactions.pdf?origin=publicationDetail&_sg%5B0%5D=hMdJzCxphUBsTp0vzBaW71pZ2FcGyeB-jJtlUcQ_LgigY2BKWEirI0ztirvJ9bD508p4T0lh5zDBOlQ1BH6cTg.ZTq7J6HwdzZTDPANul_vrmsSEA6TFdPgz4z_Qgis9RV4IMgWTTiw4eUpP407rfMFKoAfoN7OuZIBXfBX4inL0A&_sg%5B1%5D=c6l7jbxWvRNvkhG5FDlHtNSi4tuV0hkQ8sl6jGQXslNDK7fXkTZboRkNTvIjCrab9jWcx8JpAzQy9u7tL0-XSQcbBZy72_o_4Y0El-UfYxEu.ZTq7J6HwdzZTDPANul_vrmsSEA6TFdPgz4z_Qgis9RV4IMgWTTiw4eUpP407rfMFKoAfoN7OuZIBXfBX4inL0A&_iepl=&_rtd=eyJjb250ZW50SW50ZW50IjoibWFpbkl0ZW0ifQ%3D%3D&_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6Il9kaXJlY3QiLCJwYWdlIjoicHVibGljYXRpb24iLCJwb3NpdGlvbiI6InBhZ2VIZWFkZXIifX0"),
    Metadata(0.4,"22(4):508-516","Seifedine Kadry", "Noroff University College", "January 2008", "https://www.researchgate.net/profile/Seifedine-Kadry/publication/232590897_Corrosion_analysis_of_stainless_steel/links/585c1d0c08ae329d61f2f86a/Corrosion-analysis-of-stainless-steel?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.78,"10.3390_met10030327","Andrea Di Schino", "Università di Perugia", "March 2020", "https://www.researchgate.net/profile/S-Dutta/publication/330383386_Different_Types_and_New_Applications_of_Stainless_Steel/links/5c3d6a31a6fdccd6b5ad9ee0/Different-Types-and-New-Applications-of-Stainless-Steel.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uRG93bmxvYWQiLCJwYWdlIjoicHVibGljYXRpb24ifX0"),
    Metadata(0.57,"10.1088_1755-1315_446_5_052025","Liangliang Zhang", "Earth Environ. Sci.", "March 2020", "https://www.researchgate.net/publication/340084337_Study_on_Underpinning_Scheme_of_Shield_Tunnel_Crossing_Pile_Foundation_of_Viaduct/fulltext/5e76739692851cf2719d9ae4/Study-on-Underpinning-Scheme-of-Shield-Tunnel-Crossing-Pile-Foundation-of-Viaduct.pdf?origin=publicationDetail&_sg%5B0%5D=9VAhFI-MusRDr6yIrSDtT6WM0vg6b4w-SWNB4k2ITd0c6SRHoDiPrhT-QlvMOLZAc48sCxjV8Q5ktWBDFT2IkA.m3QEwaBn9izGwLpndo-cqtwQ4v00S7DthTLsodS638366HvOFYOh1XCKJlWIfXGVsEtsHUS-exr_IE3CF0bULQ&_sg%5B1%5D=72lNqtM6xPAvSGMzJf0apNoXsbNGc8Zpb71TSGCzSBsliE1kKzOFKs4ISodPTQL72BnBz1A3AjACKZcPurTBBm4xF5RFpCnzL6mNKsOPORp2.m3QEwaBn9izGwLpndo-cqtwQ4v00S7DthTLsodS638366HvOFYOh1XCKJlWIfXGVsEtsHUS-exr_IE3CF0bULQ&_iepl=&_rtd=eyJjb250ZW50SW50ZW50IjoibWFpbkl0ZW0ifQ%3D%3D&_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6Il9kaXJlY3QiLCJwYWdlIjoicHVibGljYXRpb24iLCJwb3NpdGlvbiI6InBhZ2VIZWFkZXIifX0"),
    Metadata(0.83,"10.20449_jnte.v5i2.284","Dian Pancawati", "Universitas Internasional Batam", "June 2016", "https://www.researchgate.net/profile/Andik-Yulianto/publication/305781879_Implementasi_Fuzzy_Logic_Controller_untuk_Mengatur_pH_Nutrisi_pada_Sistem_Hidroponik_Nutrient_Film_Technique_NFT/links/57a1bcc008aeef8f311cf67a/Implementasi-Fuzzy-Logic-Controller-untuk-Mengatur-pH-Nutrisi-pada-Sistem-Hidroponik-Nutrient-Film-Technique-NFT.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.45,"10.14027_j.cnki.cjxb.2002.01.015","Jiangyu Zhou", "Faculty of Earth Resources", "January 2002", "https://www.researchgate.net/profile/Jiangyu-Zhou/publication/309546999_Depositional_patterns_and_tectonic_setting_of_early_Tertiary_basins_in_the_NE_margin_of_the_Tibetan_plateau/links/5c06270a458515ae5444dcf6/Depositional-patterns-and-tectonic-setting-of-early-Tertiary-basins-in-the-NE-margin-of-the-Tibetan-plateau.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.92,"10.1109_POWERCON.2018.8602202","Huang Yufeng", "-", "November 2018", ""),
    Metadata(0.69,"10.1016/j.future.2019.04.046","Yongkai Fan", "-", "June 2019", ""),
    Metadata(0.73,"10.5937_inovacije1801013S","Ljubivoje D. Stojanović", "-", "July 2018", "https://www.researchgate.net/publication/326499985_Theological_Contribution_to_Creating_and_Developing_a_Culture_of_Diversity_in_the_Classroom/fulltext/5b513e7faca27217ffa679b6/Theological-Contribution-to-Creating-and-Developing-a-Culture-of-Diversity-in-the-Classroom.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.87,"10.1201/b13869","R. Radvanovsky", "-", "February 2013", ""),
    Metadata(0.76,"10.1088_1742-6596_1261_1_012037","A.V. Trotsyuk", "Lavrent'ev Institute of Hydrodynamics SB RAS", "June 2019", "https://www.researchgate.net/publication/334076717_Reduced_model_of_chemical_kinetic_and_two-dimensional_structure_of_detonation_wave_in_rich_mixtures_of_methane_with_oxidizer/fulltext/5d158240299bf1547c842e84/Reduced-model-of-chemical-kinetic-and-two-dimensional-structure-of-detonation-wave-in-rich-mixtures-of-methane-with-oxidizer.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.85,"10.1093_insilicoplants_diy003","Tiangen Chang", "Chinese Academy of Sciences", "January 2019", "https://www.researchgate.net/publication/332667458_Systems_models_phenomics_and_genomics_three_pillars_for_developing_high-yielding_photosynthetically_efficient_crops/fulltext/5cc282334585156cd7b1937f/Systems-models-phenomics-and-genomics-three-pillars-for-developing-high-yielding-photosynthetically-efficient-crops.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.87,"10.13140_RG.2.2.34086.27204","Hannan LaGarry", "Council for Responsible Mining", "August 2019", "https://www.researchgate.net/profile/Hannan-Lagarry/publication/334848205_PHOTOGRAPHS_2009_Badlands_NP_field_tour/data/5d432252a6fdcc370a741a22/Photographs-2009-badlands-field-tour.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19"),
    Metadata(0.56,"10.5593/sgem2019/5.3/S21.022","Rasa Viederytė", "Klaipeda University", "June 2019", ""),
    Metadata(0.64,"10.1063/5.0163369","Varadharajan Srinivasan", "Amity University", "September 2023", "https://www.researchgate.net/profile/Bishnu-Kant-Shukla/publication/373775395_Study_of_Growth_of_Steel_Steel_Infrastructure_and_Steel_Industries_in_India/links/64fc1b9d10813375f2685fc6/Study-of-Growth-of-Steel-Steel-Infrastructure-and-Steel-Industries-in-India.pdf?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InNpZ251cCIsInBhZ2UiOiJwdWJsaWNhdGlvbiIsInByZXZpb3VzUGFnZSI6Il9kaXJlY3QifX0"),
]

class Response:
    question = ""
    answer = ""
    reliability = ""
    doi = ""
    author = ""
    organization = ""
    publication_date = ""
    source = ""

    def __init__(self, question, answer, reliability, doi, author, organization, publication_date, source):
        self.question = question
        self.answer = answer
        self.reliability = reliability
        self.doi = doi
        self.author = author
        self.organization = organization
        self.publication_date = publication_date
        self.source = source

if form.getfirst("question"):
    print("Content-type: text/json\n\n")
    query = form.getfirst("question")
    results = run(query)
    document = results[0]
    short_answer = results[1]

    query_source = str(document.metadata["source"]) 
    prepared_source_name = query_source.replace(".pdf","").replace("docs/","")
    
    search = [x for x in hardcoded_lookup if x.doi == prepared_source_name]
    metadata = search[0]

    print(json.dumps(Response(query, short_answer, metadata.reliability, metadata.doi, metadata.author, metadata.organization, metadata.publication_date, metadata.source).__dict__))

else:
    print("Content-type: text/plain")
    print("Status: 400 Bad Request\n\n")
    print("Query needs to be in format ?question='free form text'")