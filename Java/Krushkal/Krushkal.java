import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;
public class Krushkal {
	int numberOfVertices = 0;
	UnionFind u4;
	public Krushkal(String choice) {
		if(choice.equals("1"))
			u4 = new UnionFindByName() ;
		else if(choice.equals("2"))
			u4 = new UnionFindByParent();
		else if(choice.equals("3"))
			u4 =  new UnionFindByRank();
		else
			u4 = new UnionPathComp();
	}
	public class EdgeCompare implements Comparator<Edge>{
		public int compare(Edge e1, Edge e2){
			if(e1.getCost() <= e2.getCost())
				return -1;
			else
				return 1;
		}
	}
	public List<Edge> getMST(Graph g){
		List<Edge> listOfEdges = g.getEdgeList();
		
		EdgeCompare ec = new EdgeCompare();
		Collections.sort(listOfEdges,ec);
		
		//UnionFindByName u4 = new UnionFindByName();
		//UnionFindByParent u4 = new UnionFindByParent();
		//UnionFindByRank u4 = new UnionFindByRank();
			
		
		for (Map.Entry<Integer, Vertex> entry : g.getVertexList().entrySet()) {
			u4.createSet(entry.getValue().vertexIndex);
		}

		List<Edge> finalSol = new ArrayList<Edge>();
		for(Edge e: listOfEdges){
			int r1 = u4.find(e.getV1().vertexIndex);
			int r2 = u4.find(e.getV2().vertexIndex);

			if(r1 == r2)
				continue;
			else{
				finalSol.add(e);
				u4.union(e.getV1().vertexIndex, e.getV2().vertexIndex);
			}
		}
		return finalSol;
	}
	
	   public static void main(String args[]) throws IOException {
	        
		   Graph g = new Graph();
			// Read inputs from file
			
		   //	BufferedReader in = new BufferedReader(new FileReader("src/Input2.txt"));
		   	BufferedReader in = new BufferedReader(new FileReader(args[0]));
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
			while(index < length ){
				arr = list.get(index);
				String[] split = arr.split("\t");
				int j = 0;
				g.addEdge(Integer.parseInt(split[j]), Integer.parseInt(split[j+1]), Integer.parseInt(split[j+2]));
				index = index + 1;
			}
			String choice;
			try{
			choice = args[1];
			choice = choice == null ? "4" : choice;
			}catch(Exception e){
				choice = "4";
			}
	        Krushkal mst = new Krushkal(choice);
	        mst.numberOfVertices = n;
	        List<Edge> result = mst.getMST(g);
	        for (Edge edge : result) {
	            System.out.println(edge.getV1() + " " + edge.getV2());
	        }
	    }
}
