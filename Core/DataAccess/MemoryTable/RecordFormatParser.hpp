#ifndef INC_RecordFormatParser_hpp_
#define INC_RecordFormatParser_hpp_

#include <antlr/config.hpp>
/* $ANTLR 2.7.6 (2005-12-22): "record_parser.g" -> "RecordFormatParser.hpp"$ */
#include <antlr/TokenStream.hpp>
#include <antlr/TokenBuffer.hpp>
#include "RecordFormatParserTokenTypes.hpp"
#include <antlr/LLkParser.hpp>

#line 1 "record_parser.g"

  #include "LogAdapter.h"
  #include "RecognitionException.hpp"
  #include "ASTPair.hpp"
  #include "ASTFactory.hpp"
  #include <boost/cstdint.hpp>
  #include <boost/algorithm/string/predicate.hpp>

#line 21 "RecordFormatParser.hpp"
class CUSTOM_API RecordFormatParser : public ANTLR_USE_NAMESPACE(antlr)LLkParser, public RecordFormatParserTokenTypes
{
#line 31 "record_parser.g"

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
#line 25 "RecordFormatParser.hpp"
public:
	void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
protected:
	RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k);
public:
	RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf);
protected:
	RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer, int k);
public:
	RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer);
	RecordFormatParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state);
	int getNumTokens() const
	{
		return RecordFormatParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return RecordFormatParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return RecordFormatParser::tokenNames;
	}
	public: void program();
	public: void typeDefinition();
	public: void recordDefinition();
	public: void typeSpecification();
	public: void fieldDefinition();
	public: void typeParameter();
public:
	ANTLR_USE_NAMESPACE(antlr)RefAST getAST()
	{
		return returnAST;
	}
	
protected:
	ANTLR_USE_NAMESPACE(antlr)RefAST returnAST;
private:
	static const char* tokenNames[];
#ifndef NO_STATIC_CONSTS
	static const int NUM_TOKENS = 52;
#else
	enum {
		NUM_TOKENS = 52
	};
#endif
	
	static const unsigned long _tokenSet_0_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_0;
};

#endif /*INC_RecordFormatParser_hpp_*/
