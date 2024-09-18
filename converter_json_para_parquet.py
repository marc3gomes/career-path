import pandas as pd

# Dados fornecidos
data = [
    {"title": "Interno", "experience": "No Experience / Student"},
    {"title": "Junior Designer Test", "experience": "1-5 years"},
    {"title": "Mid-level Designer", "experience": "3-8 years"},
    {"title": "Senior Designer", "experience": "5-15 years"},
    {"title": "Specialist", "experience": "5-15 years"},
    {"title": "Expert", "experience": "5-15 years"},
    {"title": "Principal", "experience": "5-15 years"},
    {"title": "Lead", "experience": "5-15 years"}
]

# Criando um DataFrame com os dados fornecidos
df = pd.DataFrame(data)

# Salvando o DataFrame como arquivo Parquet
df.to_parquet('data.parquet')

print("Arquivo Parquet gerado com sucesso: data.parquet")
