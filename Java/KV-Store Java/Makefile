

SRC_DIR=proto
PROTOBUF_DIRECTORY=/usr/local/include
DST_DIR=src

all: clean myproto server client 

build: clean myproto server client 
	
myproto:
	protoc -I=proto --java_out=$(DST_DIR) proto/protocol.proto	 
	
client:
	javac  -classpath .:protobuf-java-3.0.0.jar:log4j.jar $(DST_DIR)/dkvs/Client.java  $(DST_DIR)/dkvs/Protocol.java

server:
	javac -classpath .:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar $(DST_DIR)/dkvs/ChordNode.java \
	$(DST_DIR)/dkvs/ServerSocketThread.java $(DST_DIR)/dkvs/ProxySocketThread.java $(DST_DIR)/dkvs/Protocol.java \
	$(DST_DIR)/dkvs/MyKey.java $(DST_DIR)/dkvs/MyValue.java


clean:
	rm -rf src/dkvs/*.class

tests:	chordNetworkBasic chordNetworkNodeAddition chordNetworkNodeFailure chordReplication
				
	
chordNetworkBasic:
	./BasicChordNetwork.sh 	
	
chordNetworkNodeAddition:
	./nodes_join.sh 
	
chordNetworkNodeFailure:
	./nodes_leave.sh 
	
chordReplication:
	./replication.sh 
	
