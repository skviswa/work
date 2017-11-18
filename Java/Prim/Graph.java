import java.util.*;
import java.util.List;
import java.util.Map;


class Graph
{
	public Map<Integer, Vertex> VertexList;
	public List<Edge> edgeList;
	public int VertexListSize;
	
	// Constructor Definition
	public Graph()
	{
		this.VertexList = new HashMap<>();
		this.edgeList = new ArrayList<Edge>();
		this.VertexListSize = 0;
	}
	
	
	// Adds edge between two vertices and associating a cost to it.
	public void addEdge(int v1, int v2, int weight) {
		Vertex firstV = null;
		if(VertexList.containsKey(v1))
			firstV = VertexList.get(v1);
		else{
			firstV = new Vertex(v1);
			VertexList.put(v1, firstV);
		}
		
		Vertex secondV  = null;
		if(VertexList.containsKey(v2))
			secondV = VertexList.get(v2);
		else{
			secondV = new Vertex(v2);
			VertexList.put(v2, secondV);
		}
		
		Edge e = new Edge(firstV, secondV, weight);
		edgeList.add(e);
		firstV.addAdj(secondV, e);
		secondV.addAdj(firstV, e);
	}
	
	// Returns all the vertices in the graph in the form of a HashMap
	public Map<Integer, Vertex> getVertexList() {
		return VertexList;
	}

}
