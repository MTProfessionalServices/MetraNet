#include "MTSQLSemanticException.h"

#include <string>

MTSQLSemanticException::MTSQLSemanticException(const ANTLR_USE_NAMESPACE(std)string& s, RefMTSQLAST ast) :
	ANTLR_USE_NAMESPACE(antlr)RecognitionException(s, "", ast->getLine(), ast->getColumn())
{
	mColumn = ast->getColumn();
}

ANTLR_USE_NAMESPACE(std)string MTSQLSemanticException::toString() const
{
	char buf[256];
	sprintf(buf, "line %d: column %d: ", getLine(), mColumn);
	return ANTLR_USE_NAMESPACE(std)string(buf) + getMessage();
}
