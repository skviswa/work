import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//Constructor template for IfExp:
//new LmdExpr (List<String> formals, Exp body)
// Interpretation: A LambdaExp represents a lambda expression.
// formals represents the identifiers of the variables associated
// with the given lambda function
// Body represents the body of the given lambda expression

public class LmdExpr extends Exprn implements LambdaExp {

	List<String> formals = new ArrayList<String>();  // Represents the identifier for given lambda function
	Exp body;  // Represents the body of the given lambda function
	
	// Represents the constructor template for lambdaExp
	
	LmdExpr(List<String> formals, Exp body) {
		this.formals = formals;
		this.body = body;
	}
	
	// Returns the formal parameters of this lambda expression.

    public List<String> formals() {
    	return this.formals;
    	
    }

    // Returns the body of this lambda expression.

    public Exp body() {
    	
    	return this.body;
    }

    // Returns true when checked whether this object
    // is of type LambdaExp
    
   @Override
    public boolean isLambda() {
		return true;
	}

	 // Returns the representation for this object type	

   @Override
   public LambdaExp asLambda() {
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
	   
       return Asts.expVal(this, env);
	   
      }   
	   
}
