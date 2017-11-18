import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Programs {

   // GIVEN: A List of Definitions that correspond to a program and the list of inputs
   // given for the program 
   // RETURNS: The value the program generates for the given input
	
    public static ExpVal run (List<Def> pgm, List<ExpVal> inputs) {
        
    	Map<String, ExpVal> env = new HashMap<String, ExpVal>();   // Represents the environment for the given program
    	int i;

    	for(Def d: pgm) {
    		
    		if(d.rhs().isLambda()) {                                     // The Definition can be a constant or a lambda expression
    			FunVal f1 = Asts.expVal(d.rhs().asLambda(), env);        // Store the lambda expression corresponding to the function value  
    			env.put(d.lhs(), f1);                                    // Add the FunVal object to my program environment
    		}	
    		if(d.rhs().isConstant())
    			env.put(d.lhs(),d.rhs().asConstant().value());     // If the definition is a constant, directly add it to the program environment
    	}

    	Def d = pgm.get(0);
    	if(d.rhs().isLambda()) {
    			
    			List<String> tmp = d.rhs().asLambda().formals();
    			Exp tmpexp = d.rhs().asLambda().body();
    			
    	        int s = Math.min(inputs.size(), tmp.size());
      		  		for(i = 0; i < s; i++) 
        					env.put(tmp.get(i) , inputs.get(i));          // Add the variable values to the local environment
        			
                 ExpVal f = tmpexp.value(env);                               // Return the value of the program
                   if(f.isFunction())
                 return  f.asFunction().code().body().value(f.asFunction().environment());
                   else
                	   return f;
    	}
    	else
    		return env.get(d.lhs());
                   
    }

    // GIVEN: An expression which is a part of the program and the program environment
    // RETURNS: The value the expression with respect to the program environment
    
   public static ExpVal updateMap (Exp body, Map<String,ExpVal> env) {
	   
		if(body.isIdentifier()) {
	    return body.asIdentifier().value(env);	                // Fetch the value of the variable from the environment 
		}
		
		if(body.isArithmetic()) {
		 return body.asArithmetic().value(env);      // Fetch the value of the expression with the help of environment
		}
		
		if(body.isIf()) {
		return body.asIf().value(env);     // Fetch the value of the expression with the help of environment
		}
		
		if(body.isCall()) { 
	    return body.asCall().value(env);   // Fetch the value of the variable with the help of environment
		}
		
        if(body.isConstant()) {
		return body.asConstant().value();  // Get the value of the constant from the object
        }
		
        if(body.isLambda()) {
   		 return body.asLambda().value(env);    // Fetch the value of the variable with the help of environment
        } 
        
        throw new RuntimeException();
        
   }
    

    // GIVEN: A List of Expression which is a part of the program and the program environment
    // RETURNS: A list of Expression Values which contain the value of each expression
    // evaluated with respect to the given environment
    
    public static List<ExpVal> computeList (List<Exp> lst, Map<String, ExpVal> env) {
 
    	
    	List<ExpVal> vlst = new ArrayList<ExpVal>();
    	
    	for(Exp e : lst) {
    		
    	vlst.add(Programs.updateMap(e, env));	
    	}
    	
    	return vlst;
    }
  
    // GIVEN: An expression which is a part of the program and the program environment
    // RETURNS: The set of free variables in the given expression with respect to the program environment
  
     public static Set<String> updateVariable (Exp body, Set<String>freelst, List<String> formals, Set<String> lhslst) {
 	   
		   
 		if(body.isIdentifier()) {                                                         
 	    if (!lhslst.contains(body.asIdentifier().name()) && !formals.contains(body.asIdentifier().name())) // Check if its not in 
 	     freelst.add(body.asIdentifier().name());	                                                      // definition list or formals list
 	    
 	    }

     	if(body.isArithmetic()) {
  	       formals.addAll(updateVariable(body.asArithmetic().leftOperand(), freelst, formals, lhslst));	 // check for left operand
  	       formals.addAll(updateVariable(body.asArithmetic().rightOperand(), freelst, formals, lhslst));	 // check for right operand
     	}
 		
         if(body.isLambda()) {
    	  
   		  formals.addAll(body.asLambda().formals());	                                      // first get formals
   		  formals.addAll(updateVariable(body.asLambda().body(), freelst, formals, lhslst));  // check for free variables in body
   
         } 
     
 		if(body.isIf()) {
  	       formals.addAll(updateVariable(body.asIf().testPart(), freelst, formals, lhslst));  // check for free variables in testpart	 
  	       formals.addAll(updateVariable(body.asIf().thenPart(), freelst, formals, lhslst));  // check for free variables in thenpart
  	       formals.addAll(updateVariable(body.asIf().elsePart(), freelst, formals, lhslst));  // check for free variables in elsepart	  
  		}
    	 		
    	if(body.isCall()) { 
    	
   	       formals.addAll(updateVariable(body.asCall().operator(), freelst, formals, lhslst));   // check for free variables in operator
   	       for(int i = 0; i < body.asCall().arguments().size(); i++)
   	   	   formals.addAll(updateVariable(body.asCall().arguments().get(i), freelst, formals, lhslst));   // check for free variables in arguements 
    	}
    	
 	    if(body.isConstant()) { 
 		    return freelst;            
         }
       
    	return freelst;
         
    }       
   
     // Runs the ps11 program found in the file named on the command line
     // on the integer inputs that follow its name on the command line,
     // printing the result computed by the program.
     //
     // Example:
     //
     //     % java Programs sieve.ps11 2 100
     //     25
     
    public static void main(String args[]) 
   {
	   
	  String filename = Scanner.readPgm(args[0]); //reads the file from the commandline and turns it into a string
	  List<Def> prgm0 = Scanner.parsePgm(filename); // parses the file and returns a program
	  List<ExpVal> inputs = new ArrayList<ExpVal>();

	  for (int i=1;i<args.length;i++)
	  {
		  inputs.add(Asts.expVal(Integer.parseInt(args[i]))); // inputs are taken from the commandline
	  }
	  ExpVal result = Programs.run(prgm0, inputs);
	  if (result.isBoolean())
	  {
		  System.out.println(result.asBoolean()); // print output if boolean
	  }
	  else
		 System.out.println(result.asInteger()); // print output if Integer
}
   
    // Reads the ps11 program found in the file named by the given string
    // and returns the set of all variable names that occur free within
    // the program.
    //
    // Examples:
    //     Programs.undefined ("church.ps11")    // returns an empty set
    //     Programs.undefined ("bad.ps11")       // returns { "x", "z" }
    //
    //   where bad.ps11 is a file containing:
    // 
    //     f (x, y) g (x, y) (y, z);
    //     g (z, y) if 3 > 4 then x else f
    
    
   public static Set<String> undefined (String filename) 
   {
	   List<Def> prgm0 = Scanner.parsePgm(filename); // get the definition list from filename
	   Set<String> lhslst = new HashSet<String>();  // The list of definition identifiers
		   
	  Set<String> lstfreevariables = new HashSet<String>();
	
	  for (Def d : prgm0)
	   {
		lhslst.add(d.lhs());          // Create a list of definition identifiers
	   }
	   for (Def d : prgm0)
	   {
		 List<String> formallst = new ArrayList<String>();          // Maintain a list of formals of lambda
		   
		 if(d.rhs().isLambda()) {
		 
		  formallst.addAll(d.rhs().asLambda().formals());	 
		  lstfreevariables.addAll(updateVariable(d.rhs().asLambda().body(), lstfreevariables, formallst, lhslst));  
		 }                               // fetch list of free variables from helper
	   }
	   
	   return lstfreevariables;
   }
  
	
}
