package dkvs;
import java.io.IOException;
import java.net.MalformedURLException;

import de.uniba.wiai.lspi.chord.data.URL;
import de.uniba.wiai.lspi.chord.service.Chord;
import de.uniba.wiai.lspi.chord.service.ServiceException;

public class ChordNode {
	
	private static ServerSocketThread serverinterface;
	private static Thread serverthread;
	private static ProxySocketThread proxyserverinterface;
	private static Thread proxyserverthread;
	private static Chord chord;
	
	public static void main (String[] args) throws IOException {	
		
		if (args.length <=3)
		{
			 System.err.println("Usage:java -classpath <jarfiles>  dkvs.ChordNode <Type> <local IP> <Chord Port> <Service Port> <bootstrap IP> <bootstrap URL>");
		     System.exit(2);
		}
		int type = Integer.parseInt(args[0]);
		String localIPAddress = args[1];
		String localPort = args[2];
		String serviceport = args[3];
		String proxyserviceport = null;
		String bootstrapIPAddress = null;
		String bootstrapPort = null;
		String url = "://";
		if (type == 2)
		{
			bootstrapIPAddress = args[4];
			bootstrapPort = args[5];
		}
		if (type == 1)
			proxyserviceport=args[4];
		
		de.uniba.wiai.lspi.chord.service.PropertiesLoader.loadPropertyFile();
		String protocol = URL.KNOWN_PROTOCOLS.get(URL.SOCKET_PROTOCOL);
		URL localURL = null;
		try {	
			url = url.concat(localIPAddress).concat(":").concat(localPort).concat("/");
			localURL = new URL(protocol + url ) ;
		} catch (MalformedURLException e) {
			throw new RuntimeException(e);
		}
		try {	
			chord = new de.uniba.wiai.lspi.chord.service.impl.ChordImpl();			
			if (type == 2){
				String sbootstrapurl="://";
				sbootstrapurl = sbootstrapurl.concat(bootstrapIPAddress).concat(":").concat(bootstrapPort).concat("/");
				URL bootstrapurl= new URL(protocol + sbootstrapurl ) ;
				chord.join(localURL,bootstrapurl);
			}
			if(type == 1){
				chord.create(localURL);
				proxyserverinterface = new ProxySocketThread(Integer.parseInt(proxyserviceport),chord);
				proxyserverthread = new Thread(proxyserverinterface);	
				proxyserverthread.start();				
			}
			serverinterface = new ServerSocketThread(Integer.parseInt(serviceport),chord);
			serverthread = new Thread(serverinterface);	
			serverthread.start();		
		} catch (ServiceException e) {
			throw new RuntimeException ( " Could not create DHT ! " , e ) ;
		}
		System.out.println("Successful Node Creation in Chord- Host:" + chord.getURL().getHost() + "  Port:"+chord.getURL().getPort());
		}
	
}
