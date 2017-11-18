import java.util.HashMap;
import java.util.Map;


public class UnionFindByName implements UnionFind {
	private Map<Integer,Node> elements = new HashMap<>();
	class Node{
		int num;
		Node leader;
	}

	public int find(int data){
		return find(elements.get(data)).num;
	}
	
	public void createSet(int data){
		Node n = new Node();
		n.num = data;
		n.leader = n;
		elements.put(data, n);
	
	}

	private Node find(Node n){
		return n.leader;
	}

	//Union operation on any two sets by name. 
	public void union(int num1, int num2){
		Node n1 = elements.get(num1);
		Node n2 = elements.get(num2);

		Node l1 = find(n1);
		Node l2 = find(n2);
		
		
		if(l1.num == l2.num)
			return;
		
		//l1.num = l2.num;
		//l1.leader = l2;
		l1.num = l2.num;
		l1.leader = l2;
	}
	
	// TESTS
	public static void main(String...args){
		UnionFindByName ds = new UnionFindByName();
        ds.createSet(1);
        ds.createSet(2);
        ds.createSet(3);
        ds.createSet(4);
        ds.createSet(5);
        ds.createSet(6);
        ds.createSet(7);

        ds.union(1, 2);
        ds.union(2, 3);
        ds.union(4, 5);
        ds.union(6, 7);
        ds.union(5, 6);
        ds.union(3, 7);

        
        System.out.println(ds.find(1));
        System.out.println(ds.find(2));
        System.out.println(ds.find(3));
        System.out.println(ds.find(4));
        System.out.println(ds.find(5));
        System.out.println(ds.find(6));
        System.out.println(ds.find(7));
	}
}