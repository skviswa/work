import java.util.*;
public class UnionPathComp implements UnionFind {
	private Map<Integer,Node> elements = new HashMap<>();
	
	class Node{
		int num;
		Node leader;
		int rank;
	}

	public int find(int data){
		return find(elements.get(data)).num;
	}
	
	public void createSet(int data){
		Node n = new Node();
		n.num = data;
		n.leader = n;
		n.rank = 0;
		elements.put(data, n);
	
	}
	
	private Node find(Node n){
		Node p = n.leader;
		if(p == n)
			return p;
		n.leader = find(n.leader);
		return n.leader;
	}
	
	

	//Union operation on any two sets by rank. 
	public void union(int num1, int num2){
		Node n1 = elements.get(num1);
		Node n2 = elements.get(num2);

		Node l1 = find(n1);
		Node l2 = find(n2);
		
		if(l1.num == l2.num)
			return;
		
		// one with higher rank becomes the parent.
		
		if(l1.rank >= l2.rank){
			if(l1.rank == l2.rank)
				l1.rank = l1.rank + 1;
			l2.leader = l1;
		}
		else
			l1.leader = l2;
	}
	
	public static void main(String...args){
		UnionPathComp ds = new UnionPathComp();
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
