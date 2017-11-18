package dkvs;
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;
import com.google.protobuf.ByteString;
import dkvs.Protocol.RouterRequest;
import dkvs.Protocol.RouterResponse;
import dkvs.Protocol.Row;
import dkvs.Protocol.ServerGetRequest;
import dkvs.Protocol.ServerSetRequest;
import dkvs.Protocol.Status;
import dkvs.Protocol.StatusType;

public class Client {
	private static int proxyserverport;
	private static String IPAddress;	
	public static void main(String args[]) throws IOException
	{
		if (args.length < 4)
		{
			 System.err.println("Usage:java -classpath <jarfiles>  dkvs.Client <Proxy IP> <Proxy Port> <Get =1, Set =2> <Key> <Value if Set>");
		     System.exit(2);
		}
		Client.IPAddress = args[0];
		Client.proxyserverport = Integer.parseInt(args[1]);
		int option = Integer.parseInt(args[2]);
		String key= args[3];
		String value = null;
		if (option == 2)
			value = args[4];		
		RouterRequest serv_addr_req = RouterRequest.newBuilder().setKey(ByteString.copyFrom(key.getBytes())).build();			
		Socket socket = new Socket(Client.IPAddress, Client.proxyserverport);
		OutputStream out = socket.getOutputStream();
		serv_addr_req.writeDelimitedTo(out);
		out.flush();
 		RouterResponse clientresponse=null;
		while ((clientresponse = RouterResponse.parseDelimitedFrom(socket.getInputStream())) != null) {
			String IPPort[] = clientresponse.getAddress().split(":");
			System.out.println("Proxy returned Node[Host:Port] " +  clientresponse.getAddress() + " for key "+key );
    		Socket servsocket = new Socket(IPPort[0],Integer.parseInt(IPPort[1]));
    		OutputStream servout = servsocket.getOutputStream();
	        if (option == 1)
	        {
	        	ServerGetRequest get_request = ServerGetRequest.newBuilder().setType("get").setKey(ByteString.copyFrom(key.getBytes())).build();		    		
	    		get_request.writeDelimitedTo(servout);
	    		servout.flush();
	     		Row response=null;
	    		while ((response = Row.parseDelimitedFrom(servsocket.getInputStream())) != null) {
	    			System.out.println("Key " + response.getKey().toStringUtf8() + " Value " + response.getValue().toStringUtf8());
	    		break;
	    		}
	        }
    		if (option == 2)
	        {
	        	ServerSetRequest set_request = ServerSetRequest.newBuilder().setType("set").setKey(ByteString.copyFrom(key.getBytes())).setValue(ByteString.copyFrom(value.getBytes())).build();	
	      		set_request.writeDelimitedTo(servout);
	    		servout.flush();
	     		Status setresponse=null;
	    		while ((setresponse = Status.parseDelimitedFrom(servsocket.getInputStream())) != null) {	    			
	    			if (setresponse.getStatus() == StatusType.OK)
		    			System.out.println("SET Successful");
	    			else
		    			System.out.println("SET Failed");
	    			break;
	    		}
	        }
    	servsocket.close();
    	socket.close();
    	break;
	}

}
}