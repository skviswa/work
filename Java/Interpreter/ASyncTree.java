import java.util.ArrayList;

import java.util.List;

//Constructor template for ASyncTree
//new ASyncTree()
//Interpretation:
// An ASyncTree class represents the given
// program in the form of an Abstract Syntax Tree


public abstract class ASyncTree implements Ast {

 // Constructor for Ast
	
	ASyncTree() {
		
	}
	
 
	// Returns true iff this Ast is for a program
   public  boolean isPgm() {
	
	  return false;
  }
   
   // Returns true iff this Ast is for a Definition
   
     public boolean isDef() {
	  return false;
  }
     
  // Returns true iff this Ast is for an Expression
     
  public  boolean isExp() {
	  return false;
  }

    // Precondition: this Ast is for a program.
    // Returns a representation of that program.

   public List<Def> asPgm() {
   
   throw new UnsupportedOperationException();
	   
   }

   // Precondition: this Ast is for a definition.
    // Returns a representation of that definition.

    public Def asDef() {
    	   throw new UnsupportedOperationException();
    }
    	
    // Precondition: this Ast is for an expression.
    // Returns a representation of that expression.

    public Exp asExp() {
    	   throw new UnsupportedOperationException();
    }
   	
 
}
