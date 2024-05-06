from datetime import datetime
import random
import tqdm
from socket import *
import sys
import os
from threading import Thread
import time 

if len(sys.argv) != 3:
    print("\n===== server_IP, server_port is required ======\n")
    sys.exit()

serverHost = sys.argv[1]
serverPort = int(sys.argv[2])
serverAddress = (serverHost, serverPort)

clientSocket = socket(AF_INET, SOCK_STREAM)
clientSocket.connect(serverAddress)

print("==== Successfully connect the server ====")
data = clientSocket.recv(1024)

print("==== existing wav file are listed below ====")

print(data.decode())
print("==== Please indicate the name of the file you want")

fileName = input("fileName:")
clientSocket.sendall(fileName.encode())

response = clientSocket.recv(1024).decode()

if response == "the file name does not exist" :
    print("==== invalid file name, please resend a valid file name")
    clientSocket.close()

else :
    print("==== valid file name, ready to receive the file")

    message = "requiring for file size"
    clientSocket.sendall(message.encode())

    fileSize = clientSocket.recv(1024).decode()

    # remove absolute path if there is
    fileName = os.path.basename(fileName)

    # start receiving the file from the socket
    # and writing to the file stream
    # + Very nice!!
    progress = tqdm.tqdm(range(int(fileSize)), f"Receiving {fileName}", unit="B", unit_scale=True, unit_divisor=1024)

    with open(fileName, "wb") as f:
        while True:
            data = clientSocket.recv(1024)
            # write to the file the bytes we just received
            if data == b'transfer is done': 
                break
            f.write(data)
            # update the progress bar
            progress.update(len(data))
            clientSocket.sendall("maintain sycronization".encode())
    
    print("==== successfully receive the wav file ====")
    clientSocket.close()