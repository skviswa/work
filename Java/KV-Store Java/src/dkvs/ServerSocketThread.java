package dkvs;

import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Iterator;
import java.util.Set;

import com.google.protobuf.ByteString;

import de.uniba.wiai.lspi.chord.service.Chord;
import de.uniba.wiai.lspi.chord.service.ServiceException;
import de.uniba.wiai.lspi.chord.service.impl.ChordImpl;
import dkvs.Protocol.Row;
import dkvs.Protocol.ServerGetRequest;
import dkvs.Protocol.ServerSetRequest;
import dkvs.Protocol.Status;
import dkvs.Protocol.StatusType;

public class ServerSocketThread implements Runnable {

	ServerSocket serviceSocket;
	int port;
	Chord chordobj;

	public ServerSocketThread(int thisport, Chord chord) throws IOException {
		this.port=thisport;
		this.serviceSocket = new ServerSocket(this.port);
		this.chordobj=chord;
	}

	@Override
	public void run() {
		while (true) {
			try {
				Socket client = serviceSocket.accept();
				ServerGetRequest clientRequest;
				InputStream input = client.getInputStream();
					clientRequest = ServerGetRequest.parseDelimitedFrom(input);
					synchronized(this.chordobj){
					if (clientRequest.getType().equalsIgnoreCase("get")) {					
						Set<Serializable> value = chordobj.retrieve(new MyKey(clientRequest.getKey().toStringUtf8()));
						Iterator<Serializable> iter = value.iterator();
						//System.out.println(" Get Set Size " +value.size()+ " Node "+chordobj.getURL() + " " +clientRequest.getKey().toStringUtf8());
						if(iter.hasNext())
						{
							MyValue first = (MyValue) iter.next();
							Row clientResponse = Row.newBuilder().setKey(clientRequest.getKey()).setValue(ByteString.copyFrom(first.value.getBytes())).build();			
							clientResponse.writeDelimitedTo(client.getOutputStream());
							client.getOutputStream().flush();
						}
						System.out.println("*****************************************************************************************************************");
						System.out.println("Node "+ chordobj.getURL().getHost() + ":" +  chordobj.getURL().getPort()   + " Status");
						System.out.println(((ChordImpl)(this.chordobj)).printEntries());
						System.out.println("--------------------------------------------------------------------------");
						System.out.println(((ChordImpl)(this.chordobj)).printFingerTable());
						System.out.println("--------------------------------------------------------------------------");
						System.out.println(((ChordImpl)(this.chordobj)).printPredecessor());
						System.out.println("--------------------------------------------------------------------------");
						System.out.println(((ChordImpl)(this.chordobj)).printSuccessorList());
						System.out.println("*****************************************************************************************************************");


					} else {
						ServerSetRequest setrequest = ServerSetRequest.newBuilder().setKey(clientRequest.getKey()).setValue(clientRequest.getValue()).build();
						//System.out.println("Set String " + setrequest.getKey().toStringUtf8());
						chordobj.insert(new MyKey(setrequest.getKey().toStringUtf8()), new MyValue(setrequest.getValue().toStringUtf8()));	
						Status clientResponse = Status.newBuilder().setStatus(StatusType.OK).build();
						clientResponse.writeDelimitedTo(client.getOutputStream());
						client.getOutputStream().flush();					
					}
				}
				
			} catch (IOException | ServiceException e) {
				e.printStackTrace();
			}

		}
	}
}
