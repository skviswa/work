package dkvs;


public class MyValue implements java.io.Serializable {

	private static final long serialVersionUID = 1L;
	public String value;
	public MyValue(String myvalue)
	{
		value=new String(myvalue);
	}
}
