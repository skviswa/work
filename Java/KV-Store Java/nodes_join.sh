#!/bin/sh
echo "################################################################################################"
echo "Chord Network Validation - New Node Addition"
echo "################################################################################################"


#start Server Nodes
java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 1 127.0.0.1 5553 5554 5555 &
sleep 2 
pids1=$(ps -al | grep java | awk 'END {print $4}')
echo $pids1

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5557 5558 127.0.0.1 5553 &
sleep 2 
pids2=$(ps -al | grep java | awk 'END {print $4}')
echo $pids2

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5559 5560 127.0.0.1 5553 &
sleep 2
pids3=$(ps -al | grep java | awk 'END {print $4}')
echo $pids3

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5561 5562 127.0.0.1 5553 &
sleep 2
pids4=$(ps -al | grep java | awk 'END {print $4}')
echo $pids4

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5563 5564 127.0.0.1 5553 &
sleep 2 
pids5=$(ps -al | grep java | awk 'END {print $4}')
echo $pids5

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5565 5566 127.0.0.1 5553 &
sleep 4
pids6=$(ps -al | grep java | awk 'END {print $4}')
echo $pids6

 

#Start Client Requests
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Preethi Ayyamperumal &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Vivek Selvam &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Pratheep Santhi &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Soumya Gajula &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Neethu Prasad &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Swathi Soni &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 2 Preethi Vivek &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Swathi &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Preethi &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Neethu &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Soumya &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Soumya &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Pratheep &
sleep 2

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5567 5568 127.0.0.1 5553 &
sleep 2
pids7=$(ps -al | grep java | awk 'END {print $4}')
echo $pids7

java  -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.ChordNode 2 127.0.0.1 5569 5570 127.0.0.1 5553 &
sleep 2
pids8=$(ps -al | grep java | awk 'END {print $4}')
echo $pids8

java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Swathi &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Preethi &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Neethu &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Soumya &
sleep 2
java -classpath .:./src:protobuf-java-3.0.0.jar:log4j.jar:openchord_1.0.5.jar dkvs.Client 127.0.0.1 5555 1 Pratheep &
sleep 2


kill -9 $pids1 $pids2 $pids3 $pids4  $pids5 $pids6 $pids7 $pids8


