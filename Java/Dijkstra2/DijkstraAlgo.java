import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

import org.omg.PortableInterceptor.DISCARDING;

public class DijkstraAlgo {

	public static void main(String[] args) throws IOException {
		Graph g = new Graph();
		// Source vertex index. 1 in this case. 
		int start = 1;
		
		// Read inputs from file
		BufferedReader in = new BufferedReader(new FileReader("src/Input2.txt"));
		String str;
		
		// contains all lines of the file (line by line)
		List<String> list = new ArrayList<String>();
		while((str = in.readLine()) != null){
		    list.add(str);
		}
		
		in.close();
		
		// First line is the number of vertices.
		String arr = list.get(0);
		list.remove(0);
		int index = 0;
		int length = list.size();
		
		// Add edges to the graph.
		while(index != length -1){
			arr = list.get(index);
			String[] split = arr.split("\t");
			int j = 0;
			g.addEdge(Integer.parseInt(split[j]), Integer.parseInt(split[j+1]), Integer.parseInt(split[j+2]));
			index = index + 1;
		}
		
		DijkstraAlgo d = new DijkstraAlgo();
		
		// setting source vertex.
		Vertex source = g.VertexList.get(start);
		
		// Storing the vertex and shortest distance.
		Map<Vertex, Integer> finalSol = d.dijkstraShortestPath(g, source);
		
		// Display shortest path
		System.out.println("Distance from source : " + source.vertexIndex);
		for (Map.Entry<Vertex,Integer> entry : finalSol.entrySet()) {
			System.out.println(source.vertexIndex + " -> " + entry.getKey() + " : " + entry.getValue());
		}

	}
	// Vertex , Edge -> Vertex
	private Vertex getVertexFromEdge(Vertex v, Edge e){
		if(e.getV1().equals(v))
			return e.getV2();

		else
			return e.getV1();
	}
	
	// Graph , Vertex -> Map 
	public Map<Vertex, Integer> dijkstraShortestPath(Graph g, Vertex source){
		MinHeap heap = new MinHeap();
		// map for storing vertex and its shortest distance
		Map<Vertex, Integer> shortestDistance = new HashMap<>();
		//map for storing its parentVertex
		Map<Vertex, Vertex> parentVertex = new HashMap<>();
		// Assigning all the cost of vertex to infinity initially.
		for (Map.Entry<Integer, Vertex> entry : g.getVertexList().entrySet())
			heap.insertVertex(entry.getValue(), Integer.MAX_VALUE);

		// First vertex is set to 0 and its parent to null.
		heap.decreaseCost(source, 0);
		shortestDistance.put(source, 0);
		parentVertex.put(source, null);
		
		// Computation of Shortest path.
		while(!heap.empty()){
			MinHeap.Node minNode = heap.popMinimum();
			Vertex currentVertex = minNode.vertex;
			shortestDistance.put(currentVertex, minNode.cost);
			for (Edge e : currentVertex.getListOfEdges()) {
				Vertex adj = getVertexFromEdge(currentVertex, e);
				if(!heap.containsVertex(adj))
					continue;
				int distance = shortestDistance.get(currentVertex) + e.getCost();
				if(heap.getCost(adj) > distance){
					heap.decreaseCost(adj, distance);
					parentVertex.put(adj, currentVertex);
				}
			}
						
		}
		return shortestDistance;
	}

}
