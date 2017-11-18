//Constructor template for ExprValue1:
//new ExprValue2 (long i)
//Interpretation:
// ExprValue1 represents the integer value of an expression.

public class ExprValue2 extends ExprValue {
	
    long i;   // Represents the given integer value

    // Constructor for ExprValue2
    
    ExprValue2(long n) {

		this.i = n;
	}

    // Returns true when checked whether this object
    // is of ExpVal type corresponding to Integer

    @Override
	public boolean isInteger() {
      return true;		
	}

  	 // Returns the representation for this object type	

    @Override
	public long asInteger() {
		return this.i;
	}


}
