import java.util.*;
import java.util.HashMap;

// Heap which is a min heap.
// Also has a map structure which maps Vertex and the position of Vertex in heap.
public class MinHeap {
	// Node class defines a node which has cost and vertex associated with it. 
	public class Node{
		public int cost;
		public Vertex vertex;

	}
	public List<Node> vertices;
	public HashMap<Vertex, Integer> position = new HashMap<>();
	
	// Constructor definition
	MinHeap(){
		vertices = new ArrayList<Node>();
	}
	
	// Insert the vertex and cost onto the map.
	public void insertVertex(Vertex vertex, int cost){
		Node n = new Node();
		//this.vertices.add(n);
		n.cost = cost;
		n.vertex = vertex;
		vertices.add(n);
		int size = vertices.size();
		int currentIndex = size - 1;
		position.put(n.vertex, currentIndex);
		bubbleUp(currentIndex);
	}
	
	// helper function for restructuring the heap
	private void bubbleUp(int currentIndex){
		int parentIndex = (currentIndex - 1) / 2;
		while(parentIndex >= 0){
			Node p = vertices.get(parentIndex);
			Node c = vertices.get(currentIndex);
			if(p.cost > c.cost){
				swapPositions(p,c);
				updatePos(p.vertex,c.vertex,parentIndex, currentIndex);
				currentIndex = parentIndex;
				parentIndex = (parentIndex - 1) / 2;
			}
			else
				break;
		}
	}
	
	// the cost is decreased and hence the heap is restructured.
	public void decreaseCost(Vertex v, int c){
		int pos = position.get(v);
		vertices.get(pos).cost = c;
		int parentIndex = (pos - 1) / 2;
		while(parentIndex >= 0){
			if(vertices.get(parentIndex).cost > vertices.get(pos).cost){
				swapPositions(vertices.get(parentIndex),vertices.get(pos));
				updatePos(vertices.get(parentIndex).vertex,vertices.get(pos).vertex,parentIndex, pos);
				pos = parentIndex;
				parentIndex = (parentIndex - 1) / 2;
			}
			else
				break;
		}
	}
	
	// positions of the Vertices are updated.
	private void updatePos(Vertex parent, Vertex current, int parentIndex, int currentIndex) {
		position.remove(parent);
		position.remove(current);
		position.put(parent, parentIndex);
		position.put(current, currentIndex);
	}

	// Swaps any two given vertices. 
	private void swapPositions(Node p, Node c){
		int tempCost = p.cost;
		Vertex v = p.vertex;

		p.cost = c.cost;
		p.vertex = c.vertex;

		c.cost = tempCost;
		c.vertex = v;
	}

	
	// Returns the most minimum node. This node will have the vertex and the cost.
	public Node popMinimum(){
		Node n = new Node();
		n.vertex = vertices.get(0).vertex;
		n.cost = vertices.get(0).cost;
		int size = vertices.size();
		int smallestIndex;
		vertices.get(0).cost = vertices.get(size -1).cost;
		vertices.get(0).vertex = vertices.get(size -1).vertex;
		position.remove(n.vertex);
		position.remove(vertices.get(0));
		position.put(vertices.get(0).vertex, 0);
		vertices.remove(size - 1);
		int currentIndex = 0;
		size -= 2;

		while(true){
			int leftChild = 2*currentIndex + 1;
			int rightChild = 2*currentIndex + 2;
			if(size < leftChild)
				break;

			if(size < rightChild)
				rightChild = leftChild;

			
			if(vertices.get(leftChild).cost <= vertices.get(rightChild).cost)
				smallestIndex = leftChild;
			else
				smallestIndex = rightChild;
			if(vertices.get(currentIndex).cost > vertices.get(smallestIndex).cost){
				swapPositions(vertices.get(currentIndex), vertices.get(smallestIndex));
				updatePos(vertices.get(currentIndex).vertex, vertices.get(smallestIndex).vertex, currentIndex, smallestIndex);
				currentIndex = smallestIndex;
			}
			else
				break;
		}
		return n;	
	}

	// Returns true iff the heap is empty
	public boolean empty(){
		return vertices.size() == 0;
	}
	
	// Returns true iff the vertex is present in the map.
	public boolean containsVertex(Vertex v){
		return position.containsKey(v);
	}
	
	// Returns the cost of Vertex associated with the heap.
	public Integer getCost(Vertex v){
		Integer pos = position.get(v);
		if(pos != null)
			return vertices.get(pos).cost;
		return 0;

	}
}
