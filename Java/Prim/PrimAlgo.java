import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class PrimAlgo {

	public List<Edge> mst(Graph g){
		MinHeap minHeap = new MinHeap();
		Map<Vertex, Edge> connection = new HashMap<>();
		List<Edge> solution = new ArrayList<>();

		for (Map.Entry<Integer, Vertex> entry : g.getVertexList().entrySet()) {
			minHeap.insertVertex(entry.getValue(), Integer.MAX_VALUE);
		}

		// Until the heap is empty
		while(!minHeap.empty()){
			// gets the minimum vertex which will be the current vertex
			Vertex currentVertex = minHeap.popMinimum();
			Edge span = connection.get(currentVertex);
			if(span != null)
				solution.add(span);

			for (Edge edge : currentVertex.getListOfEdges()) {
				Vertex adj = getVertexFromEdge(currentVertex, edge);
				if(minHeap.containsVertex(adj) && minHeap.getCost(adj) > edge.getCost()){
					minHeap.decreaseCost(adj, edge.getCost());
					connection.put(adj, edge);
				}
			}
		}
		return solution;
	}

	// Vertex , Edge -> Vertex
	private Vertex getVertexFromEdge(Vertex v, Edge e){
		if(e.getV1().equals(v))
			return e.getV2();

		else
			return e.getV1();
	}

	public static void main(String[] args) throws IOException{
		Graph g = new Graph();
		// Read inputs from file
		BufferedReader in = new BufferedReader(new FileReader("src/Input.txt"));
		String str;

		// contains all lines of the file (line by line)
		List<String> list = new ArrayList<String>();
		while((str = in.readLine()) != null){
			list.add(str);
		}
		
		in.close();

		// First line is the number of vertices.
		String arr = list.get(0);
		int n = Integer.parseInt(arr);

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
		PrimAlgo p = new PrimAlgo();
		List<Edge> finalList = p.mst(g);
		
		// Check for spanning tree. edges = totalVertices - 1.
		if(finalList.size() == n-1){
			for (Edge edge : finalList) {
				System.out.println(edge);
			}
		}
		else
			System.out.println("Spanning tree Error");
	}
}
