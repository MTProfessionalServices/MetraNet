#ifndef INC_DataflowParser_hpp_
#define INC_DataflowParser_hpp_

#include <antlr/config.hpp>
/* $ANTLR 2.7.6 (2005-12-22): "dataflow_parser.g" -> "DataflowParser.hpp"$ */
#include <antlr/TokenStream.hpp>
#include <antlr/TokenBuffer.hpp>
#include "DataflowParserTokenTypes.hpp"
#include <antlr/LLkParser.hpp>

#line 1 "dataflow_parser.g"

  #include "LogAdapter.h"
  #include "RecognitionException.hpp"
  #include "CompositeDictionary.h"
  #include "ASTPair.hpp"
  #include "ASTFactory.hpp"
  #include "MyAST.h"
  #include "ScriptInterpreter.h"
  #include "ArgEnvironment.h"
  #include <boost/algorithm/string/predicate.hpp>
  #include <boost/lexical_cast.hpp>
  #include <boost/filesystem/operations.hpp>
  #include <boost/filesystem/path.hpp>
  #include <boost/filesystem/fstream.hpp>

#line 28 "DataflowParser.hpp"
class CUSTOM_API DataflowParser : public ANTLR_USE_NAMESPACE(antlr)LLkParser, public DataflowParserTokenTypes
{
#line 95 "dataflow_parser.g"

private:
  /** Logger */
  MetraFlowLoggerPtr mLog;

  /** True if an error occurred during parsing */
  bool mHasError;

  /** If mHasError is true, corresponding error message. */
  std::string mErrMessage;
  
  /** Dictionary of defined composites. */
  CompositeDictionary *mCompositeDictionary;
  
  /** A composite definition that is actively being defined. */
  CompositeDefinition *mActiveCompositeDefinition;
  
  /** The name of the file being parsed. Used for error reporting. */
  std::wstring mFilename;

  /** 
   * The script interpreter.
   * Used for recursively processing import statements.
   */
  DataflowScriptInterpreter *mInterpreter;

  /** The workflow */
  Workflow* mWorkflow;

  /** 
   * The environment of argument settings, from either the command
   * line or environmental variable settings.
   */
  ArgEnvironment *mArgEnvironment;

  /**
   * The encoding of the file.  Defaults to locale codepage but may
   * overridden (e.g. to UTF8).
   */
  boost::int32_t mEncoding;

  /** Convert the standard string to a wide-string */
  std::wstring ASCIIToWide(const std::string& str)
  {
    std::wstring wstr;
    ::ASCIIToWide(wstr, str.c_str(), -1, mEncoding);
    return wstr;
  }

public:
  
  /** Set the environment (the place where we store environment settings) */
  void setArgEnvironment(ArgEnvironment *env)
  {
    mArgEnvironment = env;
  }

  /** Set the interpreter */
  void setInterpreter(DataflowScriptInterpreter *interpreter)
  {
    mInterpreter = interpreter;
  }

  /** Set the workflow */
  void setWorkflow(Workflow *workflow)
  {
    mWorkflow = workflow;
  }

	/** Override the error and warning reporting */
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
    mHasError = true;
    mErrMessage = "Parsing error: " + ex.toString();
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
    mHasError = true;
    mErrMessage = "Parsing error: " + s;
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	  mLog->logWarning(s);
  }

  /** Set the logger to use. */
  void setLog(MetraFlowLoggerPtr log)
  {
	  mLog = log;
    mHasError = false;
  }

  /** Did an error occur during parsing? */
  bool getHasError()
  {
	  return mHasError;
  }
  
  /** Returns last error message or empty string if no error occurred. */
  string getErrorMessage()
  {
    if (mHasError)
    {
      return mErrMessage;
    }
    else
    {
      return "";
    }
  }

  /**
   * Set the composite dictionary.  This class does not own this
   * dictionary and is NOT responsible for freeing it.
   */
  void setCompositeDictionary(CompositeDictionary *dictionary)
  {
    mCompositeDictionary = dictionary;
  }

  /** Set the name of the file being parsed. Used for error reporting. */
  void setFilename(const std::wstring &filename)
  {
    mFilename = filename;
  }

  /**
   * Set encoding of the parser.
   */
  void setEncoding(boost::int32_t encoding)
  {
    mEncoding = encoding;
  }

  boost::int32_t getEncoding() const
  {
    return mEncoding;
  }

  /** Set the logger to use. */
  void setLog(Logger * log)
  {
  }

  virtual void initASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
  {
    initializeASTFactory(factory);
  }
#line 32 "DataflowParser.hpp"
public:
	void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
protected:
	DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k);
public:
	DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf);
protected:
	DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer, int k);
public:
	DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer);
	DataflowParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state);
	int getNumTokens() const
	{
		return DataflowParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return DataflowParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return DataflowParser::tokenNames;
	}
	public: void program();
	public: void includeCompositeStatement();
	public: void nodeStatement();
	public: void edgeStatement();
	public: void compositeDeclaration();
	public: void stepDeclaration();
	public: void controlFlow();
	public: void compositeParameters();
	public: void compositeBody();
	public: void compositeParameterSpec();
	public: void compositeParameterInputSpec();
	public: void compositeParameterOutputSpec();
	public: void compositeArgSpec();
	public: void stepBody();
	public: void controlFlowBody();
	public: void stepStatement();
	public: void ifStatement();
	public: void ifPredicate();
	public: void ifArgument();
	public: void arguments();
	public: void argument();
	public: void argumentValue();
	public: void argumentVariable();
	public: void ifArgumentValue();
	public: void annotationArguments();
	public: void annotationArgument();
	public: void annotationArgumentDataType();
	protected: void nodeDefOrRef();
	public: void arrowArguments();
	public: void arrowAnnotation();
public:
	ANTLR_USE_NAMESPACE(antlr)RefAST getAST()
	{
		return ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST);
	}
	
protected:
	RefMyAST returnAST;
private:
	static const char* tokenNames[];
#ifndef NO_STATIC_CONSTS
	static const int NUM_TOKENS = 126;
#else
	enum {
		NUM_TOKENS = 126
	};
#endif
	
	static const unsigned long _tokenSet_0_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_0;
	static const unsigned long _tokenSet_1_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_1;
	static const unsigned long _tokenSet_2_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_2;
};

#endif /*INC_DataflowParser_hpp_*/
