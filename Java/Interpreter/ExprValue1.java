//Constructor template for ExprValue1:
//new ExprValue1 (boolean b)
//Interpretation:
// ExprValue1 represents the boolean value of an expression.

public class ExprValue1 extends ExprValue {
	
	   boolean b; // Represents the given boolean value
	   
	   // Constructor class for ExprValue1
		
		ExprValue1(boolean b) {

			this.b = b;
		}

	    // Returns true when checked whether this object
	    // is of ExpVal type corresponding to Boolean
		
        @Override
		public boolean isBoolean() {
      		return true;
		}

   	 // Returns the representation for this object type	
		@Override
		public boolean asBoolean() {
			return this.b;		
		}


			
}
