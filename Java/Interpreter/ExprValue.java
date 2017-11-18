

//Constructor template for ExprValue:
//new ExprValue ()
//Interpretation:
// An ExpVal represents the value of an expression.

public abstract class ExprValue implements ExpVal {

	// Constructor template for ExprValue
    ExprValue() {
    	
    }
    
	// Returns true iff this ExpVal is a Boolean

    public boolean isBoolean() {
		return false;
	}

	// Returns true iff this ExpVal is an Integer

	public boolean isInteger() {
		return false;
	}

	// Returns true iff this ExpVal is a Function

	public boolean isFunction() {
        return false;
	}

	// Precondition: the corresponding predicate isBoolean is true.
	// Returns the representation of this object.
	
	public boolean asBoolean() {
		   throw new UnsupportedOperationException();
	}

	// Precondition: the corresponding predicate isInteger is true.
	// Returns the representation of this object.

	public long asInteger() {
		   throw new UnsupportedOperationException();
	}

	// Precondition: the corresponding predicate isFunction is true.
	// Returns the representation of this object.

	public FunVal asFunction() {
		   throw new UnsupportedOperationException();
	}
	

}
