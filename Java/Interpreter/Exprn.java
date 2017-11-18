import java.util.List;
import java.util.Map;

//Constructor template for Defn:
//new Exprn ()
//Interpretation:
//Exprn represents an expression of a source program. 
// It is one of
// Constant Expression
// Call Expression
// Identifier Expression
// Lambda Expression
// IfExpression
// Arithmetic Expression

public abstract class Exprn extends ASyncTree implements Exp {

	// Constructor template for Exprn
	Exprn() {

	}
	
	// Returns true iff this Exp is a constant expression

	public boolean isConstant() {
		return false;
	}

	// Returns true iff this Exp is an identifier expression
	
	public boolean isIdentifier() {
		return false;
	}

	// Returns true iff this Exp is a lambda expression 
	
	public boolean isLambda() {
		return false;
	}

	// Returns true iff this Exp is a arithmetic expression 

	public boolean isArithmetic() {
		return false;
	}

	// Returns true iff this Exp is a call expression 
	
	public boolean isCall() {
		return false;
	}

	// Returns true iff this Exp is a if expression
	
	public boolean isIf() {
		return false;
	}

	// Precondition: the corresponding predicate isConstant is true.
	// Returns a representation of this object type

	public ConstantExp asConstant() {
		   throw new UnsupportedOperationException();
    }

	// Precondition: the corresponding predicate isIdentifier is true.
	// Returns a representation of this object type
	
	public IdentifierExp asIdentifier() {
		
		   throw new UnsupportedOperationException();

	}

	// Precondition: the corresponding predicate isLambda is true.
	// Returns a representation of this object type
	
	public LambdaExp asLambda() {
		
		   throw new UnsupportedOperationException();
	}

	// Precondition: the corresponding predicate isArithmetic is true.
	// Returns a representation of this object type
	
	public ArithmeticExp asArithmetic() {
		   throw new UnsupportedOperationException();		
	}

	// Precondition: the corresponding predicate isCall is true.
	// Returns a representation of this object type
	
	public CallExp asCall() {
		   throw new UnsupportedOperationException();
	}

	// Precondition: the corresponding predicate isIf is true.
	// Returns a representation of this object type

	public IfExp asIf(){
		   throw new UnsupportedOperationException();
	}

    // Returns true when checked whether this object
    // is of type Exp
	
	@Override
	public boolean isExp() {
		return true;
	}

	 // Returns the representation for this object type, Exp	
	
	@Override
    public Exp asExp() {
     
		return this;
    	
    }

    // Given: The environment associated with a given program
	// Returns the value of this expression when its free variables
	// have the values associated with them in the given Map.
	// May run forever if this expression has no value.
	// May throw a RuntimeException if some free variable of this
	// expression is not a key of the given Map or if a type
	// error is encountered during computation of the value.

	public abstract ExpVal value(Map<String, ExpVal> env);		
	
}
