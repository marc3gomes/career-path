import pandas as pd

# Carregar o arquivo Parquet
df = pd.read_parquet('data.parquet')

# Exibir o esquema e as primeiras linhas de dados
print(df.info())  # Mostra o esquema (colunas e tipos)
print(df.head())  # Mostra as primeiras linhas do arquivo
