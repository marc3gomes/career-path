import json
import boto3
import os
import time

athena = boto3.client('athena')

def handler(event, context):
    # Debug para ver o corpo da requisição recebido
    print("Evento recebido:", event)

    # Nome do banco de dados Athena e o local para salvar os resultados
    database = os.environ['ATHENA_DATABASE']
    output_location = os.environ['ATHENA_OUTPUT']

    # Query SQL recebida do evento (adicionando tratamento extra para o corpo)
    try:
        body = json.loads(event["body"])
        query = body['query']
    except KeyError:
        return {
            'statusCode': 400,
            'body': 'A consulta SQL ("query") não foi fornecida no corpo da requisição.'
        }

    # Executando a consulta no Athena
    response = athena.start_query_execution(
        QueryString=query,
        QueryExecutionContext={'Database': database},
        ResultConfiguration={'OutputLocation': output_location}
    )

    # ID da execução da consulta
    query_execution_id = response['QueryExecutionId']

    # Aguardar a execução ser concluída
    while True:
        status = athena.get_query_execution(QueryExecutionId=query_execution_id)['QueryExecution']['Status']['State']
        if status in ['SUCCEEDED', 'FAILED', 'CANCELLED']:
            break
        time.sleep(1)

    # Verificar se a consulta foi bem-sucedida
    if status == 'SUCCEEDED':
        # Recuperar os resultados da consulta
        result = athena.get_query_results(QueryExecutionId=query_execution_id)
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    else:
        return {
            'statusCode': 500,
            'body': f"Query {status}"
        }
