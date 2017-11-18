import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Asts {

    // Static factory methods for Def
    
    // Returns a Def with the given left and right hand sides.
    
    public static Def def (String id1, Exp rhs) { 

        return new Defn(id1, rhs);
    }
    
    // Static factory methods for Exp
    
    // Returns an ArithmeticExp representing e1 op e2.
    
    public static ArithmeticExp arithmeticExp (Exp e1, String op, Exp e2) { 

                return new ArExp(e1, op, e2);
    }
    
    // Returns a CallExp with the given operator and operand expressions.
    
    public static CallExp callExp (Exp operator, List<Exp> operands) { 
    	return new CallExprn(operator, operands);
    }
    
    // Returns a ConstantExp with the given value.
    
    public static ConstantExp constantExp (ExpVal value) { 
    	return new CntExpr(value);
    }
    
    // Returns an IdentifierExp with the given identifier name.
    
    public static IdentifierExp identifierExp (String id) { 
    	return new IdrExpr(id);
    }
    
    // Returns an IfExp with the given components.
    
    public static IfExp ifExp (Exp testPart, Exp thenPart, Exp elsePart) { 
    	return new IfExpr(testPart, thenPart, elsePart);
    }
    
    // Returns a LambdaExp with the given formals and body.
    
    public static LambdaExp lambdaExp (List<String> formals, Exp body) { 

        return new LmdExpr(formals, body);
   }
    
    // Static factory methods for ExpVal
    
    // Returns a value encapsulating the given boolean.
    
    public static ExpVal expVal (boolean b) { 
    	return new ExprValue1(b);
    }
    
    // Returns a value encapsulating the given (long) integer.
    
    public static ExpVal expVal (long n) { 
    	return new ExprValue2(n);
    }
    
    // Returns a value encapsulating the given lambda expression
    // and environment.
    
    public static FunVal expVal (LambdaExp exp, Map<String,ExpVal> env) {
    	return new Fval(exp, env);
    }
    
    // Static methods for creating short lists
    
    // Returns: A List<X> which contains one element x1    
    public static <X> List<X> list (X x1) { 
        List<X> arr = new ArrayList<X>();
        arr.add(x1);
        return arr;
    }
    
 // Returns: A List<X> which contains two elements x1 and x2
    public static <X> List<X> list (X x1, X x2) { 
    
        List<X> arr = new ArrayList<X>();
        arr.add(x1);
        arr.add(x2);
        return arr;
    }

    // Returns: A List<X> which contains two elements x1, x2 and x3
    public static <X> List<X> list (X x1, X x2, X x3) { 
        List<X> arr = new ArrayList<X>();
        arr.add(x1);
        arr.add(x2);
        arr.add(x3);
        return arr; 
    }

    // Returns: A List<X> which contains two elements x1, x2, x3 and x4   
    public static <X> List<X> list (X x1, X x2, X x3, X x4) { 
        List<X> arr = new ArrayList<X>();
        arr.add(x1);
        arr.add(x2);
        arr.add(x3);
        arr.add(x4);
        return arr;
    }
	
}
