header {
  #include "LogAdapter.h"
  #include "RecognitionException.hpp"
  #include "ASTPair.hpp"
  #include "ASTFactory.hpp"
  #include <boost/cstdint.hpp>
  #include <boost/algorithm/string/predicate.hpp>
}

options {
	language="Cpp";
}

class RecordFormatParser extends Parser;
options {
	k = 3;
    importVocab=RecordFormat;
	buildAST = true;
    defaultErrorHandler = false;
//	analyzerDebug=true;
}
tokens {
  FIELD_DEFINITION;
  RECORD_DEFINITION;
  TYPE_DEFINITION;
  TYPE_PARAMETER;
  TYPE_REFERENCE;
  TYPE_SPECIFICATION;
}

{
private:
  MetraFlowLoggerPtr mLog;
  boost::int32_t mNumFields;
  std::vector<std::wstring> mErrorMessages;

public:

  boost::int32_t getNumFields() const
  {
    return mNumFields;
  }

  void setNumFields(boost::int32_t numFields) 
  {
    mNumFields = numFields;
  }
  
	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
    // Assume all parse errors are in default locale (even though
    // the file we are parsing is UTF-8 encoded).
    std::wstring wstrError;
    ::ASCIIToWide(wstrError, ex.toString());
    mErrorMessages.push_back(wstrError);
	mLog->logError(ex.toString());
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
    // Assume all parse errors are in default locale (even though
    // the file we are parsing is UTF-8 encoded).
    std::wstring wstrError;
    ::ASCIIToWide(wstrError, s);
    mErrorMessages.push_back(wstrError);
	mLog->logError(s);
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  void setLog(MetraFlowLoggerPtr log)
  {
	mLog = log;
  }

  bool getHasError()
  {
	return mErrorMessages.size() > 0;
  }
  
  const std::vector<std::wstring> getErrorMessages()
  {
	return mErrorMessages;
  }
  
  void setLog(Logger * log)
  {
  }

  virtual void initASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
  {
    initializeASTFactory(factory);
  }
}


program
options {
    defaultErrorHandler = true;
}
  :
  ID^ (typeDefinition)* recordDefinition
  ;

typeDefinition
  :
  ID^ { ##->setType(TYPE_DEFINITION); } EQUALS! typeSpecification
  ;

recordDefinition
  :
  LPAREN^ { ##->setType(RECORD_DEFINITION); } fieldDefinition (COMMA! fieldDefinition)* RPAREN!
  ;

typeSpecification
  :
  ID^ { ##->setType(TYPE_SPECIFICATION); } LPAREN! (typeParameter (COMMA! typeParameter)*)? RPAREN!
  ;

typeParameter
  :
  ID^ { ##->setType(TYPE_PARAMETER); } EQUALS! (STRING_LITERAL | ID)
  ;

fieldDefinition
  :
  fd:ID^ { #fd->setType(FIELD_DEFINITION); mNumFields += 1; } (tr:ID { #tr->setType(TYPE_REFERENCE); } | typeSpecification)
  ;

