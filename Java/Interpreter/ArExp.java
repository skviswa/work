import java.util.HashMap;
import java.util.Map;

// Constructor Template for ArithmeticExp
// new ArExp (Exp e1, String op, Exp e2)
// Interpretation: An ArithmeticExp represents an expression of the form
//     e1 op e2
// where op is one of the binary operators represented as a String
//     < represented by "LT"
//     = represented by "EQ"
//     > represented by "GT"
//     + represented by "PLUS"
//     - represented by "MINUS"
//     * represented by "TIMES"
// and expression e1 is the left operand
// and e2 expression is the right operand

public class ArExp extends Exprn implements ArithmeticExp {

 	Exp e1, e2;  // Represent the left and right operands
	String op;  // Represents the operation to be done
	
	// Constructor for Class ArExp
	
	protected ArExp(Exp e1, String op, Exp e2) {
	 
		this.e1 = e1;
		this.op = op;
		this.e2 = e2;
	 
	}


	// Returns the left subexpression.
	
    public Exp leftOperand() {
    
    	return e1;
    	
    }
    	
	// Returns the right subexpression.
    
    public Exp rightOperand() {
      
    	return e2;
    }

    // Returns the binary operation as one of the strings
    //     "LT"
    //     "EQ"
    //     "GT"
    //     "PLUS"
    //     "MINUS"
    //     "TIMES"

    public String operation() {
  
    	return this.op;
    }
 
 // Returns true when checked for this object type, ArithmeticExp  
    
    @Override
	public boolean isArithmetic() {
    	return true;
    }

 // Returns the representation for this object type, ArithmeticExp   
       
    @Override
   public ArithmeticExp asArithmetic() {
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
    	
 	
	    ExpVal tmp1 = Programs.updateMap (this.leftOperand(), env);      // Evaluate the left operand of the expression
	    ExpVal tmp2 =  Programs.updateMap (this.rightOperand(), env);   // Evaluate the right operand of the expression

       if(!tmp1.isInteger())
    	   throw new RuntimeException();
      
       if(!tmp2.isInteger())
    	   throw new RuntimeException();
	    
	    long val1 = tmp1.asInteger() ; 
       	long val2 = tmp2.asInteger() ; 

    //Check for various cases of binary operator
       	
 	   if(op.matches("LT")) {
		   if(val1 < val2)
			return  Asts.expVal(true);
		   else
		   return  Asts.expVal(false);
	   }

	   if(op.matches("GT")) {
		   if(val1 > val2)
			return Asts.expVal(true);
		   else
		   return Asts.expVal(false);
	   }
	  
	   if(op.matches("EQ")) {
		   if(val1 == val2)
			return Asts.expVal(true);
		   else
		   return Asts.expVal(false);
	   }
	   
	   if(op.matches("PLUS")) 
		return Asts.expVal((val1 + val2));
	   
	   if(op.matches("MINUS")) 
		return Asts.expVal((val1 - val2));
	   
	   if(op.matches("TIMES")) 
		return Asts.expVal((val1 * val2));	   
	   	
	   
	    throw new RuntimeException();
    }   
}
