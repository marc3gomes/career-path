import pandas as pd

# Carregar o arquivo Parquet gerado
df = pd.read_parquet('data.parquet')

# Exibir o conteúdo do arquivo
print(df)
