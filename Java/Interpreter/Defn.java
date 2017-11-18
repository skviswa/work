import java.util.List;

//Constructor template for Defn:
//new Defn (String id, Exp e)
//Interpretation:
//A Def represents one definition of the source program. 
//id represents the identifier associated with the given definition 
//e represents the expression associated with the given definition

public class Defn extends ASyncTree implements Def {

	String id;   // Represents the identifier 
	Exp e;      // Represents the expression

 //Constructor template for Defm
	
	protected Defn(String id, Exp e) {
		this.id = id;
		this.e = e;
	}

	// Returns the left hand side of this definition,
	// which will be an identifier represented as a String.

	public String lhs() {

		return this.id;
	}

	// Returns the right hand side of this definition,
	// which will be a ConstantExp or a LambdaExp.

	public Exp rhs() {

		return this.e;
	}

	 // Returns true when checked whether this object
    // is of type Def	
	@Override
	public boolean isDef() {
		return true;
	}

	// Returns the representation for this object type, Def	

	@Override
	public Def asDef() {
		return this;
	}
	
}
