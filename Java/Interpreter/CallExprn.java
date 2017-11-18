import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


//Constructor template for CallExprn:
//     new CallExprn (Exp operator, List<Exp> operands)
// Interpretation:
//  Operator is the function that operates on the 
//  associated list of expressions. It can be an identifier
//  or a lambda expression.
//  Operands are the variables associated with the 
//  given function call


public class CallExprn extends Exprn implements CallExp {

	Exp operator;  // Represents the function call
 	List<Exp> operands = new ArrayList<Exp>(); // Represents the variables which the function operates on

 // Constructor for CallExprn class
 	
	CallExprn(Exp operator, List<Exp> operands) {
		
		this.operator = operator;
		this.operands = operands;
	}

    // Returns the expression for the function part of the call.
    public Exp operator() {
    
    	return this.operator;
    }

    // Returns the list of argument expressions.
    public List<Exp> arguments() {
    	
    	return this.operands;
    	
    }

    // Returns true when checked whether this object
    // is of type CallExp
	@Override
	public boolean isCall() {
    	return true;
    }
    
	 // Returns the representation for this object type, CallExp	
	
	@Override
	public CallExp asCall() {
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
		
    	int i;
    	Exp tmp = this.operator();     // Get the operator. The operator can be either LambdaExp or an IdentifierExp
		
    	Map<String,ExpVal> m = new HashMap<String,ExpVal>();     // Create a new local environment for call expression

   	   	m.putAll(env);   	    
    	
    	ExpVal val = tmp.value(env);  // Get the ExpVal object associated with tmp in environment env 
    	
    	if(val.isFunction()) {


    		List<ExpVal> lst = Programs.computeList(this.arguments(), env);  // Evaluate arguements in given environment

	   		m.putAll(val.asFunction().environment());

	   	   	
    		LambdaExp l = val.asFunction().code();
 
    	    
	        int s = Math.min(lst.size(), l.formals().size());
  		  		for(i = 0; i < s; i++) {
    					m.put(l.formals().get(i) , lst.get(i)); // Add the variable values to the local environment
    			}

		  		
    		return l.body().value(m);
    		
    	}
    	
    	else 
    		return val;
    	
	}	
		

	
	
		

}