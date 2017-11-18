import java.util.HashMap;
import java.util.Map;

//Constructor template for IdrExpr:
// new IdrExpr (String id)
// Interpretation: A IdentifierExp represents an identifier (or variable).
// s represents the name assigned to the given variable or constant in
// the form of a string.

public class IdrExpr extends Exprn implements IdentifierExp {

    
	String s; // The variable name is represented in the form of a string
	
    IdrExpr (String id) {
    	this.s = id;
    }

    // Returns the name of this identifier.

    public String name() {
    	return this.s;
    }
 
    // Returns true when checked whether this object
    // is of type IdentifierExp

    @Override
	public boolean isIdentifier() {
    	return true;
    }

	 // Returns the representation for this object type, IdentifierExp    
    
    @Override
 	public IdentifierExp asIdentifier() {
     	return this;
     }
 
    // Given: The environment associated with a given program
	// Returns the value of this expression when its free variables
	// have the values associated with them in the given Map.
	// May run forever if this expression has no value.
	// May throw a RuntimeException if some free variable of this
	// expression is not a key of the given Map or if a type
	// error is encountered during computation of the value.
   
	@Override
    public ExpVal value(Map<String, ExpVal> env) {
		
	       return env.get(this.name()); 
	       
	}
	
}
