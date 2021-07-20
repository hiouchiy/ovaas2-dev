#Import
from azure.storage.queue import QueueClient, TextBase64EncodePolicy, TextBase64DecodePolicy
import os, uuid
import sys

# Retrieve the connection string from an environment
# variable named AZURE_STORAGE_CONNECTION_STRING
connect_str = "AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;QueueEndpoint=http://192.168.10.107:10001/devstoreaccount1;"

# Create a unique name for the queue
#q_name = "queue-" + str(uuid.uuid4())
q_name = "queue-0d244bad-9757-46c0-ac3e-9f3be82bf835"

# Instantiate a QueueClient object which will
# be used to create and manipulate the queue
#print("Creating queue: " + q_name)
#queue_client = QueueClient.from_connection_string(connect_str, q_name)

# Create the queue
#queue_client.create_queue()

# Setup Base64 encoding and decoding functions
queue_client = QueueClient.from_connection_string(conn_str=connect_str, queue_name=q_name, message_encode_policy = TextBase64EncodePolicy(), message_decode_policy = TextBase64DecodePolicy())

# Create the queue
#queue_client.create_queue()

messages = queue_client.receive_messages()

message_csv = ""
count = 0
for message in messages:
    if count > 0:
        message_csv = message_csv + ";"
    message_csv = message_csv + message.content
    count =+ 1

sys.stdout.write(message_csv)