// Edge class represents edges with two vertices and cost between them
public class Edge {
	private Vertex v1;
	private Vertex v2;
	private int cost;
	
	public Edge(Vertex v1, Vertex v2, int cost){
		this.v1 = v1;
		this.v2 = v2;
		this.cost = cost;
	
	} 
	
	// Returns Vertex1
	public Vertex getV1() {
		return v1;
	}

	// Returns Vertex2
	public Vertex getV2() {
		return v2;
	}

	// Returns cost
	public int getCost() {
		return cost;
	}

	public String toString(){
		return "Vertex " + v1 + " -> Vertex "+ v2 + " : "+ cost;
	}

	

}
