#ifndef _MTSQLSEMANTICEXCEPTION_H_
#define _MTSQLSEMANTICEXCEPTION_H_

#include "RecognitionException.hpp"
#include "MTSQLAST.h"

class MTSQLSemanticException : public ANTLR_USE_NAMESPACE(antlr)RecognitionException
{
protected:
	int mColumn;
public:
	MTSQLSemanticException(const ANTLR_USE_NAMESPACE(std)string& s, RefMTSQLAST ast);

	virtual ANTLR_USE_NAMESPACE(std)string toString() const;	
};

#endif
