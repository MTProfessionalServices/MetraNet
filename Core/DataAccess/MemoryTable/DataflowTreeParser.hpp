#ifndef INC_DataflowTreeParser_hpp_
#define INC_DataflowTreeParser_hpp_

#include <antlr/config.hpp>
#include "DataflowTreeParserTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "dataflow_analyze.g" -> "DataflowTreeParser.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "dataflow_analyze.g"

  #include "LogAdapter.h"
  #include "MTSQLParam.h"	
  #include "ScriptInterpreter.h"
  #include "MyAST.h"
  #include "DataflowException.h"
  #include "Workflow.h"
  #include "WorkflowInstruction.h"
  #include <stdexcept>
  #include <boost/lexical_cast.hpp>
  #include <boost/tuple/tuple.hpp>
  #include <boost/variant.hpp>
  #include <boost/format.hpp>
  #include <map>

#line 26 "DataflowTreeParser.hpp"
class CUSTOM_API DataflowTreeParser : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public DataflowTreeParserTokenTypes
{
#line 34 "dataflow_analyze.g"

private:
  /** Last error message (corresponds to mHasError) */
  MetraFlowLoggerPtr mLog;

  /** True if an error has occurred. */
  bool mHasError;

  /** Map of the symbol tables for the steps. */
  std::map<std::wstring, DataflowSymbolTable*>* mMapOfSymbolTables;

  /** 
   * Symbol table for operators in the main script. This symbol table
   * is in the mMapOfSymbolTables, but we use this variable for
   * convenience.
   */
  DataflowSymbolTable * mMainSymbolTable;

  /** Dictionary of defined composites. */
  CompositeDictionary *mCompositeDictionary;    

  /**
   * Active symbol table.  We may be storing operators
   * in (1) a symbol table associated with the main script,
   * (2) a symbol table associated with a step, or (3)
   * a symbol table associated with a composite.
   */
  DataflowSymbolTable *mActiveSymbolTable;

  /** The name of the file being parsed. Used for error reporting. */
  std::wstring mFilename;

  /**
   * The encoding of the file.  Defaults to locale codepage but may
   * overridden (e.g. to UTF8).
   */
  boost::int32_t mEncoding;

private:
  /** Convert the standard string to a wide-string */
  std::wstring ASCIIToWide(const std::string& str)
  {
    std::wstring wstr;
    ::ASCIIToWide(wstr, str.c_str(), -1, mEncoding);
    return wstr;
  }

  /**
   * Add the given operator name to the symbol table.
   * The operator maybe added to the symbol table for the
   * main script or maybe added to the symbol table for
   * a composite depending upon which symbol table is active.
   * Check if the given operator has already been defined.
   * If so, throw an exception.
   *
   * @param id  AST containing name of the operator
   */
  void addOperator(RefMyAST id)
  {
    DataflowSymbolTable *activeTable = mActiveSymbolTable;
    std::wstring name = ASCIIToWide(id->getText());
    if (activeTable->find(name) != activeTable->end())
    {
      throw DataflowRedefinedOperatorException(
              name,
              (*activeTable)[name].LineNumber,
              (*activeTable)[name].ColumnNumber,
              mFilename,
              id->getLine(),
              id->getColumn());
    }

    (*activeTable)[name] = DataflowSymbol();;
    (*activeTable)[name].LineNumber = id->getLine();
  }
  
public:
  virtual void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t)
  {
    // Since we are exclusively using MyAST as the AST Type in
    // the AST tree built by DataflowParser and DataflowTreeParser, 
    // we can safely cast the RefAST to RefMyAST.
    // There may be a way to tell ANTLR that RefMyAST's are being
    // used rather that RefAST's to avoid this cast, but I
    // haven't found it.
    program((RefMyAST)_t);
  }

  /**
   * Set the map of step name to symbol table.
   * The symbol table is used for operators encountered
   * in the step or main script (rather than in composite definitions).
   * This should be called prior to invoking program().
   * This class does not own the symbol table.
   */
  void setSymbolTable(
            std::map<std::wstring, DataflowSymbolTable*>* mapOfSymbolTables)
  {
    // Default, there is always a default step.
    // Create a symbol table for this default step.
    std::map<std::wstring, DataflowSymbol> 
                    *symbolTable = new std::map<std::wstring, DataflowSymbol>;

    (*mapOfSymbolTables)[Workflow::DefaultStepName] = symbolTable;

    mMapOfSymbolTables = mapOfSymbolTables;
    mMainSymbolTable = symbolTable;
    mActiveSymbolTable = mMainSymbolTable;
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

  /** Override the error and warning reporting */
  virtual void reportError(
                const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
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

  /**
   * Set encoding of the parser.
   */
  void setEncoding(boost::int32_t encoding)
  {
    mEncoding = encoding;
  }

#line 30 "DataflowTreeParser.hpp"
public:
	DataflowTreeParser();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return DataflowTreeParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return DataflowTreeParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return DataflowTreeParser::tokenNames;
	}
	public: void program(RefMyAST _t);
	public: void includeCompositeStatement(RefMyAST _t);
	public: void compositeDeclaration(RefMyAST _t);
	public: void stepDeclaration(RefMyAST _t);
	public: void mainScript(RefMyAST _t);
	public: void dataFlowBody(RefMyAST _t);
	public: void controlFlow(RefMyAST _t);
	public: void accountResolutionStatement(RefMyAST _t);
	public: void broadcastStatement(RefMyAST _t);
	public: void collStatement(RefMyAST _t);
	public: void compositeStatement(RefMyAST _t);
	public: void copyStatement(RefMyAST _t);
	public: void devNullStatement(RefMyAST _t);
	public: void exportStatement(RefMyAST _t);
	public: void exportQueueStatement(RefMyAST _t);
	public: void exprStatement(RefMyAST _t);
	public: void filterStatement(RefMyAST _t);
	public: void generateStatement(RefMyAST _t);
	public: void groupByStatement(RefMyAST _t);
	public: void hashPartStatement(RefMyAST _t);
	public: void hashRunningTotalStatement(RefMyAST _t);
	public: void idGeneratorStatement(RefMyAST _t);
	public: void importStatement(RefMyAST _t);
	public: void importQueueStatement(RefMyAST _t);
	public: void innerHashJoinStatement(RefMyAST _t);
	public: void innerMergeJoinStatement(RefMyAST _t);
	public: void insertStatement(RefMyAST _t);
	public: void loadErrorStatement(RefMyAST _t);
	public: void loadUsageStatement(RefMyAST _t);
	public: void longestPrefixMatchStatement(RefMyAST _t);
	public: void md5Statement(RefMyAST _t);
	public: void meterStatement(RefMyAST _t);
	public: void multiHashJoinStatement(RefMyAST _t);
	public: void printStatement(RefMyAST _t);
	public: void projectionStatement(RefMyAST _t);
	public: void rangePartStatement(RefMyAST _t);
	public: void rateCalculationStatement(RefMyAST _t);
	public: void rateScheduleResolutionStatement(RefMyAST _t);
	public: void renameStatement(RefMyAST _t);
	public: void rightMergeAntiSemiJoinStatement(RefMyAST _t);
	public: void rightMergeSemiJoinStatement(RefMyAST _t);
	public: void rightOuterHashJoinStatement(RefMyAST _t);
	public: void rightOuterMergeJoinStatement(RefMyAST _t);
	public: void selectStatement(RefMyAST _t);
	public: void sequentialFileDeleteStatement(RefMyAST _t);
	public: void sequentialFileOutputStatement(RefMyAST _t);
	public: void sequentialFileRenameStatement(RefMyAST _t);
	public: void sequentialFileScanStatement(RefMyAST _t);
	public: void sessionSetBuilderStatement(RefMyAST _t);
	public: void sortStatement(RefMyAST _t);
	public: void sortGroupByStatement(RefMyAST _t);
	public: void sortMergeStatement(RefMyAST _t);
	public: void sortMergeCollStatement(RefMyAST _t);
	public: void sortNestStatement(RefMyAST _t);
	public: void sortOrderAssertStatement(RefMyAST _t);
	public: void sortRunningTotalStatement(RefMyAST _t);
	public: void sqlExecDirectStatement(RefMyAST _t);
	public: void subscriptionResolutionStatement(RefMyAST _t);
	public: void switchStatement(RefMyAST _t);
	public: void taxwareStatement(RefMyAST _t);
	public: void unionAllStatement(RefMyAST _t);
	public: void unnestStatement(RefMyAST _t);
	public: void unrollStatement(RefMyAST _t);
	public: void writeErrorStatement(RefMyAST _t);
	public: void writeProductViewStatement(RefMyAST _t);
	public: void edgeStatement(RefMyAST _t);
	public: void compositeParameters(RefMyAST _t);
	public: void compositeBody(RefMyAST _t);
	public: void compositeParameterSpec(RefMyAST _t);
	public: void compositeParameterInputSpec(RefMyAST _t);
	public: void compositeParameterOutputSpec(RefMyAST _t);
	public: void compositeArgSpec(RefMyAST _t);
	public: void compositeArgSpecString(RefMyAST _t);
	public: void compositeArgSpecInt(RefMyAST _t);
	public: void compositeArgSpecBool(RefMyAST _t);
	public: void compositeArgSpecSublist(RefMyAST _t);
	public: void stepBody(RefMyAST _t);
	public: void controlFlowBody(RefMyAST _t);
	public: void stepStatement(RefMyAST _t);
	public: void ifStatement(RefMyAST _t);
	public: void ifPredicate(RefMyAST _t);
	public: void ifArgument(RefMyAST _t);
	public: void nodeArgument(RefMyAST _t);
	public: void nodeArgumentValue(RefMyAST _t);
	public: void argumentVariable(RefMyAST _t);
	public: void ifArgumentValue(RefMyAST _t);
	public: boost::tuple<std::wstring, int, int >  arrowOrRefStatement(RefMyAST _t);
	public: void arrowArguments(RefMyAST _t);
	public: void annotationArguments(RefMyAST _t);
	public: boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >  nodeRefStatement(RefMyAST _t);
	public: void annotationArgument(RefMyAST _t);
public:
	ANTLR_USE_NAMESPACE(antlr)RefAST getAST()
	{
		return ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST);
	}
	
protected:
	RefMyAST returnAST;
	RefMyAST _retTree;
private:
	static const char* tokenNames[];
#ifndef NO_STATIC_CONSTS
	static const int NUM_TOKENS = 127;
#else
	enum {
		NUM_TOKENS = 127
	};
#endif
	
	static const unsigned long _tokenSet_0_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_0;
};

#endif /*INC_DataflowTreeParser_hpp_*/
