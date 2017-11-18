import java.util.HashMap;
import java.util.Map;

//Constructor template for IfExp:
//new IfExp (Exp testPart, Exp thenPart, Exp elsePart)
// Interpretation: An IfExp represents an if expression.
// testPart represents the expression to be tested
// thenPart represents the expression to be evaluated if
// test result is true.
// elsePart represents the expression to be evaluated if
// test result is false
public class IfExpr extends Exprn implements IfExp {

	Exp test, then, elsecase; // Represents the test, then and else parts respectively
   
    // Constructor template for If
	
	IfExpr(Exp testPart, Exp thenPart, Exp elsePart) {
    this.test = testPart;
    this.then = thenPart;
    this.elsecase = elsePart;
    }

	// Returns the test part of this if expression.
	
    public Exp testPart() {
    	
    	return this.test;
    }

	// Returns the then part of this if expression.

    public Exp thenPart() {
    	return this.then;
    }

	// Returns the else part of this if expression.

    public Exp elsePart() {
    	return this.elsecase;
    }
	
    // Returns true when checked whether this object
    // is of type IfExp
   
    @Override
	public boolean isIf() {
    	return true;
    }
 
	 // Returns the representation for this object type	

    @Override
	public IfExp asIf() {
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
    	
	
	    ExpVal tmp = Programs.updateMap (this.testPart(), env);      // Find the value of testPart of the if expression
 
	    if(!tmp.isBoolean())
	    	throw new RuntimeException();
	    
    	if(tmp.asBoolean()) 
    	{
    	    return Programs.updateMap (this.thenPart(), env);   // If condition is true, evaluate the thenPart
    		
     	}
    	else
	{
    	    return Programs.updateMap (this.elsePart(), env);   // If condition is false, evaluate the elsePart           
    	}      


	}
   
    
}
