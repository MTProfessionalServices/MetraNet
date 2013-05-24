#ifndef _MTSQLAST_H_
#define _MTSQLAST_H_

#include "CommonASTWithHiddenTokens.hpp"

#include "RuntimeValue.h"
#include "LexicalAddress.h"

class MTSQLAST : public ANTLR_USE_NAMESPACE(antlr)CommonASTWithHiddenTokens
{
public:
	MTSQLAST();
  MTSQLAST( const MTSQLAST& other ) : CommonASTWithHiddenTokens(other)
	{
		mAccess = other.getAccess();
		mLine =   other.getLine();
		mCol =    other.getColumn();
		mValue =  other.getValue();
		hiddenAfter =  other.getHiddenAfter();
	}
	
	MTSQLAST(ANTLR_USE_NAMESPACE(antlr)RefToken t);

	MTSQLAST(ANTLR_USE_NAMESPACE(antlr)RefAST a);

	virtual ~MTSQLAST() {}

	static ANTLR_USE_NAMESPACE(antlr)RefAST factory();

	LexicalAddressPtr getAccess() const ;
	void setAccess(LexicalAddressPtr access);
	int getLine() const; 
	void setLine(int line) ;
	int getColumn() const; 
	void setColumn(int column);
	void setValue(const RuntimeValue& val);
	RuntimeValue getValue() const;

	virtual void initialize(int t,const ANTLR_USE_NAMESPACE(std)string& txt);
	virtual void initialize(ANTLR_USE_NAMESPACE(antlr)RefAST t);
	virtual void initialize(ANTLR_USE_NAMESPACE(antlr)RefToken t);
  virtual ANTLR_USE_NAMESPACE(antlr)RefAST clone( void ) const
  {
    return ANTLR_USE_NAMESPACE(antlr)RefAST(new MTSQLAST(*this));
  }

  virtual std::string toString() const;

protected:
	LexicalAddressPtr mAccess;
	int mLine;
	int mCol;
	RuntimeValue mValue;
};


typedef ANTLR_USE_NAMESPACE(antlr)ASTRefCount<MTSQLAST> RefMTSQLAST;

#endif
