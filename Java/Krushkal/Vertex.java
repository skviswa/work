import java.util.*;

// Vertex class which defines vertexIndex.
// Also stores list of edges and vertices.
public class Vertex{
	public int vertexIndex;
	public List<Edge> listOfEdges = new ArrayList<>();
	public List<Vertex> listOfVertices = new ArrayList<>();
	
	// Constructor definition
	public Vertex(int vertex){
		this.vertexIndex = vertex;
	}
	
	// Returns list of Edge in graph
	public List<Edge> getListOfEdges() {
		return listOfEdges;
	}

	// Returns list of Vertex in graph
	public List<Vertex> getListOfVertices() {
		return listOfVertices;
	}
	
	// Object -> Boolean
	// Given: Object 
	// Returns true iff given Object is equal to this Object
	public boolean equals(Object obj){
		if(this == obj)
			return true;
		else
			return false;
	}
	
	
	// Given: a Vertex and an Edge
	// Action : adds Vertex to listOfVertices of this Vertex and Edge to listOfEdges of this Vertex
	public void addAdj(Vertex v, Edge e){
		listOfEdges.add(e);
		listOfVertices.add(v);
	}
	
	public String toString(){
		return Integer.toString(vertexIndex);
	}
	
	
}