#include "MTSQLAST.h"

MTSQLAST::MTSQLAST() : ANTLR_USE_NAMESPACE(antlr)CommonASTWithHiddenTokens(), mLine(1), mCol(1) {}
	
MTSQLAST::MTSQLAST(ANTLR_USE_NAMESPACE(antlr)RefToken t) : ANTLR_USE_NAMESPACE(antlr)CommonASTWithHiddenTokens() 
{
	initialize(t);
}

MTSQLAST::MTSQLAST(ANTLR_USE_NAMESPACE(antlr)RefAST a) : ANTLR_USE_NAMESPACE(antlr)CommonASTWithHiddenTokens() 
{ 
	initialize(a); 
}

void MTSQLAST::initialize(int t,const ANTLR_USE_NAMESPACE(std)string& txt)
{
	CommonASTWithHiddenTokens::initialize(t, txt);
	mAccess = nullLexicalAddress;
	mLine = 1;
	mCol = 1;
}

void MTSQLAST::initialize(ANTLR_USE_NAMESPACE(antlr)RefAST t)
{
	CommonASTWithHiddenTokens::initialize(t);
	if (NULL != static_cast<MTSQLAST*>(t.get()))
	{
		mAccess = static_cast<MTSQLAST*>(t.get())->getAccess();
		mLine = static_cast<MTSQLAST*>(t.get())->getLine();
		mCol = static_cast<MTSQLAST*>(t.get())->getColumn();
		mValue = static_cast<MTSQLAST*>(t.get())->getValue();
		//no need to set hidden tokens in here anymore. Base class does this now.
	}
}

void MTSQLAST::initialize(ANTLR_USE_NAMESPACE(antlr)RefToken t)
{
	CommonASTWithHiddenTokens::initialize(t);
	mAccess = nullLexicalAddress;
	mLine = t->getLine();
	mCol = t->getColumn();
}

std::string MTSQLAST::toString() const
{
  std::string str = ANTLR_USE_NAMESPACE(antlr)CommonASTWithHiddenTokens::toString();
  if (!mValue.isNullRaw())
  {
    str += "[";
    try
    {
      str += mValue.castToString().getStringPtr();
    }
    catch(std::exception& ex)
    {
      str += "Exception casting value to string: ";
      str += ex.what();
    }
    str += "]";
  }
  return str;
}

LexicalAddressPtr MTSQLAST::getAccess() const 
{ 
	return mAccess; 
}
void MTSQLAST::setAccess(LexicalAddressPtr access) 
{ 
	mAccess = access; 
}

int MTSQLAST::getLine() const 
{
	return mLine;
}
void MTSQLAST::setLine(int line) 
{
	mLine = line;
}

int MTSQLAST::getColumn() const 
{
	return mCol;
}
void MTSQLAST::setColumn(int column)
{
	mCol = column;
}

RuntimeValue MTSQLAST::getValue() const
{
	return mValue;
}

void MTSQLAST::setValue(const RuntimeValue& value) 
{
	mValue = value;
}

ANTLR_USE_NAMESPACE(antlr)RefAST MTSQLAST::factory()
{
	return ANTLR_USE_NAMESPACE(antlr)RefAST(new MTSQLAST);
}
