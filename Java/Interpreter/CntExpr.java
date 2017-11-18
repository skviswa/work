import java.util.Map;

//Constructor template for CntExpr:
//     new CntExpr (ExpVal val)
// Interpretation:
// Interpretation: A ConstantExp represents an identifier (or variable).
// val is the value associated with the identifier 

public class CntExpr extends Exprn implements ConstantExp {


	ExpVal v;   // Represents the value of the identifier
	
	// Constructor template for CntExpr
	
	CntExpr(ExpVal val) {
		
		this.v = val;
		
	}

	// Returns the value of this constant expression.
	
	public ExpVal value() {
    	return this.v;
    }

    // Returns true when checked whether this object
    // is of type ConstantExp
	
    @Override
	public boolean isConstant() {
    	return true;
    }
    
	 // Returns the representation for this object type, ConstantExp	
    
    @Override
	public ConstantExp asConstant() {
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
	public ExpVal value (Map<String, ExpVal> env) {
    	return this.value();
   }

    
}
