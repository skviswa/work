package dkvs;


import de.uniba.wiai.lspi.chord.service.Key;

public class MyKey implements Key {

	private String key;

	public MyKey(String theString) {
		this.key = theString;
	}

	public byte[] getBytes() {
		return this.key.getBytes();
	}

	public int hashCode() {
		return this.key.hashCode();
	}

	public boolean equals(Object o) {
		if (o instanceof MyKey) {
			return ((MyKey)o).key.equals(this.key);
		}
		return false;
	}

}
