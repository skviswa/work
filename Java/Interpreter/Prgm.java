import java.util.ArrayList;
import java.util.List;

//Constructor template for Prgm:
//new Prgm ()
//Interpretation:
//A Prgm represents A List of definitions of the source program. 

public class Prgm extends ASyncTree {


	List<Def> lst = new ArrayList<Def>();  // Represents the list of definitions

	// Constructor for the Prgm

	Prgm () {
	}

	 // Returns true when checked whether this object
    // is of type Pgm	

	@Override
	public boolean isPgm() {
		return true;
	}

	// Returns the representation for this object type

	@Override
	public List<Def> asPgm() {
		return this.lst;
	}
	
}
