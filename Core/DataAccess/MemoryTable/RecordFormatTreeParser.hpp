#ifndef INC_RecordFormatTreeParser_hpp_
#define INC_RecordFormatTreeParser_hpp_

#include <antlr/config.hpp>
#include "RecordFormatTreeParserTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "record_analyze.g" -> "RecordFormatTreeParser.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "record_analyze.g"

  #include "LogAdapter.h"
  #include "MTSQLParam.h"
  #include "RecognitionException.hpp"
  #include "ImportFunction.h"
  #include <map>
  #include <boost/format.hpp>

#line 19 "RecordFormatTreeParser.hpp"
class CUSTOM_API RecordFormatTreeParser : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public RecordFormatTreeParserTokenTypes
{
#line 18 "record_analyze.g"

private:
  MetraFlowLoggerPtr mLog;
  bool mHasError;
  std::map<std::string, ANTLR_USE_NAMESPACE(antlr)RefAST> mTypeDefinitions;

  Record_Metadata_Builder * mBuilder;

public:
	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
    mHasError = true;
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
    mHasError = true;
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }
 
  void setBuilder(Record_Metadata_Builder * builder)
  {
    mBuilder = builder;
  }

  void setLog(MetraFlowLoggerPtr log)
  {
	mLog = log;
    mHasError = false;
  }

  bool getHasError()
  {
	return mHasError;
  }
  
  void setLog(Logger * log)
  {
  }

  std::vector<MTSQLParam> antlr::TreeParser::getParams(void)
  {
    return std::vector<MTSQLParam>();
  }
#line 23 "RecordFormatTreeParser.hpp"
public:
	RecordFormatTreeParser();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return RecordFormatTreeParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return RecordFormatTreeParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return RecordFormatTreeParser::tokenNames;
	}
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void recordDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void fieldDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		const std::wstring& fieldName
	);
	public: void typeParameter(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		bool& isRequired
	);
public:
	ANTLR_USE_NAMESPACE(antlr)RefAST getAST()
	{
		return returnAST;
	}
	
protected:
	ANTLR_USE_NAMESPACE(antlr)RefAST returnAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST _retTree;
private:
	static const char* tokenNames[];
#ifndef NO_STATIC_CONSTS
	static const int NUM_TOKENS = 52;
#else
	enum {
		NUM_TOKENS = 52
	};
#endif
	
};

#endif /*INC_RecordFormatTreeParser_hpp_*/
