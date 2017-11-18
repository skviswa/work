package dkvs;

import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;
import de.uniba.wiai.lspi.chord.com.Node;
import de.uniba.wiai.lspi.chord.service.Chord;
import dkvs.Protocol.RouterRequest;
import dkvs.Protocol.RouterResponse;

public class ProxySocketThread implements Runnable {

	ServerSocket serviceSocket;
	int port;
	Chord chordobj;

	public ProxySocketThread(int thisport, Chord chord) throws IOException {
		this.port=thisport;
		this.serviceSocket = new ServerSocket(thisport);
		this.chordobj = chord;
	}

	@Override
	public void run() {
		while (true) {
			try {
				Socket client = serviceSocket.accept();
				InputStream input = client.getInputStream();
				RouterRequest clientRequest;
				clientRequest = RouterRequest.parseDelimitedFrom(input);			
				String ServerIPPort = getResponsibleNodeInfo(clientRequest.getKey().toStringUtf8());
				RouterResponse clientResponse = RouterResponse.newBuilder().setAddress(ServerIPPort).build();
				clientResponse.writeDelimitedTo(client.getOutputStream());
				client.getOutputStream().flush();
				
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	private synchronized String getResponsibleNodeInfo(String string) {
		Node responsibleNode;
		synchronized(this.chordobj){
		
		  responsibleNode = this.chordobj.getSuccessorNode(new MyKey(string));
		}
			int nodeport = responsibleNode.getNodeURL().getPort()+1;
			String url =  responsibleNode.getNodeURL().getHost();
			 url = url.concat(":").concat(String.valueOf(nodeport));
			 return  url;		
	}

}
