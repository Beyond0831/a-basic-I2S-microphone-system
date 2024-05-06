import os

# + import * is looked down upon and makes it hard to read
#   replace with "from socket import xxx, yyy, zzz" like for threading
from socket import *

import sys
from datetime import datetime
from threading import Thread, Timer
from _thread import *
import time
import subprocess

if len(sys.argv) != 2:
    print("the port number is required")
    sys.exit()

if not (sys.argv[1].isdigit() or sys.argv[1] in range(1024, 65535)):
    print("the server requires a valid port number ranging from 1024 to 65535")
    sys.exit()

# for testing only
# serverHost = "127.0.0.1"
hostname = gethostname()
res = subprocess.check_output("""ifconfig eth0 | grep "inet " | awk '{print $2}'""", shell=True, text=True)
IPaddr = res.strip()

serverPort = int(sys.argv[1])
serverAddress = (IPaddr, serverPort)


# define socket for the server side and bind address
serverSocket = socket(AF_INET, SOCK_STREAM)
serverSocket.bind(serverAddress)

print("\n start searching for the clients")

print("IP Address for the server is", IPaddr)

class ClientThread(Thread):
    def __init__(self, clientAddress, clientSocket):
        Thread.__init__(self)
        self.clientAddress = clientAddress
        self.clientSocket = clientSocket
        self.clientAlive = False

        print("===== New connection created for: ", clientAddress)
        self.clientAlive = True

        dir_path = os.getcwd()
        wavList = []
        for file in os.listdir(dir_path) :
            if file.endswith(".wav") :
                wavList.append(file)

        list_as_bytes = str(wavList).encode()
        clientSocket.sendall(list_as_bytes)
        
    def run(self):
        while self.clientAlive:
            data = self.clientSocket.recv(1024)
            fileName = data.decode()

            Send = False
            if not os.path.exists(fileName) :
                message_to_reply = "the file name does not exist"
            else:
                message_to_reply = "the file name exists"
            
            self.clientSocket.sendall(message_to_reply.encode())
            
            if clientSocket.recv(1024).decode() == "requiring for file size":
                fileSize = str(os.path.getsize(fileName))
                self.clientSocket.sendall(fileSize.encode())
                # progress = tqdm.tqdm(range(int(fileSize)), f"Sending {fileName}", unit="B", unit_scale=True, unit_divisor=1024)
                # print(fileName)
                with open(fileName, 'rb') as f:
                    while True:
                        data = f.read(1024)
                        if not data:
                            print("transfer is done for ", clientAddress)
                            Send = True
                            self.clientSocket.sendall("transfer is done".encode('utf-8'))
                            break
                        self.clientSocket.sendall(data)
                        # progress.update(len(data))
                        time.sleep(0.0001)
                        self.clientSocket.recv(1024)
                self.clientAlive = False
                if Send :
                    print(clientAddress, " has received the file, the client disconnected")
                else :
                    print(clientAddress, "provide a invalid file name, the client disconnected")
      
            
while True:
    serverSocket.listen(5)
    clientSocket, clientAddress = serverSocket.accept()
    print(f"[+] {clientAddress} is connected.")
    clientThread = ClientThread(clientAddress, clientSocket)
    clientThread.start()