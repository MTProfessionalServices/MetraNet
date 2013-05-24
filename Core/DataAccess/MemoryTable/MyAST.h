#ifndef __MY_AST_H__
# define __MY_AST_H__

#include <antlr/CommonAST.hpp>

class MyAST;

typedef ANTLR_USE_NAMESPACE(antlr)ASTRefCount<MyAST> RefMyAST;

/** 
 * Custom AST class that adds line numbers to the AST nodes.
 * Filenames will take more work since
 * you'll need a custom token class as well (one that contains the
 * filename)
 */
class MyAST : public ANTLR_USE_NAMESPACE(antlr)CommonAST {
public:
  /** Copy constructor */
   MyAST( const MyAST& other )
	: CommonAST(other)
	, line(other.line)
  , column(other.column)
	{
	}

   /** Default constructor */
   MyAST( void ) : CommonAST(), line(0) {}

   /** Destructor */
   virtual ~MyAST( void ) {}

   /** 
    * Get the line number of the node (or try to derive it 
    * from the child node).
    */
   virtual int getLine( void ) const
   {
      // most of the time the line number is not set if the node is a
      // imaginary one. Usually this means it has a child. Refer to the
      // child line number. Of course this could be extended a bit.
      // based on an example by Peter Morling.
      if ( line != 0 )
         return line;
      if( getFirstChild() )
         return ( RefMyAST(getFirstChild())->getLine() );
      return 0;
   }

   /** 
    * Get the column number of the node (or try to derive it 
    * from the child node).
    */
   virtual int getColumn( void ) const
   {
      if ( column != 0 )
         return column;
      if( getFirstChild() )
         return ( RefMyAST(getFirstChild())->getColumn() );
      return 0;
   }

   virtual void setLine( int l )
   {
      line = l;
   }

   virtual void setColumn( int l )
   {
      column = l;
   }

	 /** 
    * The initialize methods are called by the tree building constructs
    * depending on which version is called the line number is filled in.
    * e.g. a bit depending on how the node is constructed it will have the
    * line number filled in or not (imaginary nodes!).
    */
   virtual void initialize(int t, const ANTLR_USE_NAMESPACE(std)string& txt)
   {
      CommonAST::initialize(t,txt);
      line = 0;
      column = 0;
   }

   virtual void initialize( ANTLR_USE_NAMESPACE(antlr)RefToken t )
   {
      CommonAST::initialize(t);
      line = t->getLine();
      column = t->getColumn();
   }

   virtual void initialize( ANTLR_USE_NAMESPACE(antlr)RefAST ast )
   {
      // Since we are exclusively using MyAST as the AST Type in
      // the AST tree built by DataflowParser and DataflowTreeParser
      // we can safely cast the RefAST to RefMyAST.
      initialize((RefMyAST) ast);
   }

   virtual void initialize( RefMyAST ast )
   {
      CommonAST::initialize(ANTLR_USE_NAMESPACE(antlr)RefAST(ast));
      line = ast->getLine();
      column = ast->getColumn();
   }

   /** For convenience will also work without. */
   void addChild( RefMyAST c )
   {
      BaseAST::addChild( ANTLR_USE_NAMESPACE(antlr)RefAST(c) );
   }

   /** For convenience will also work without. */
   void setNextSibling( RefMyAST c )
   {
      BaseAST::setNextSibling( ANTLR_USE_NAMESPACE(antlr)RefAST(c) );
   }

   /** Provide a clone of the node (no sibling/child pointers are copied) */
   virtual ANTLR_USE_NAMESPACE(antlr)RefAST clone( void )
   {
      return ANTLR_USE_NAMESPACE(antlr)RefAST(new MyAST(*this));
   }

   static ANTLR_USE_NAMESPACE(antlr)RefAST factory( void )
   {
      return ANTLR_USE_NAMESPACE(antlr)RefAST(RefMyAST(new MyAST()));
   }

private:
   int line;
   int column;
};
#endif
