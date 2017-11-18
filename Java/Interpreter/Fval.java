import java.util.HashMap;
import java.util.Map;

//Constructor template for Fval:
//new Fval (LambdaExp exp, Map<String,ExpVal> env)
// Interpretation: A FunVal represents the value of a lambda expression.
// exp represents the given lambda expression
// env represents the environment associated with the given lambda
// expression

public class Fval extends ExprValue implements FunVal {


	LambdaExp exp;  // The lambda Expression whose value needs to generated
	Map<String, ExpVal> env = new HashMap<String, ExpVal>(); // The environment associated with the lambda expression
	
	// Constructor template for Fval
	Fval(LambdaExp exp, Map<String,ExpVal> env) {
		this.exp = exp;
		this.env = env;
		
	}

	// Returns the lambda expression from which this function was created.
	
	public LambdaExp code() {
		return this.exp;
	}

	// Returns the environment that maps the free variables of that
	// lambda expression to their values.

	public Map<String, ExpVal> environment() {
		return this.env;
	}

    // Returns true when checked whether this object
    // is of type FunVal

	@Override
	public boolean isFunction() {
		return true;
	}
	
	 // Returns the representation for this object type, FunVal	
	
	@Override
	public FunVal asFunction() {
		return this;
	}

	
}
