#ifndef INC_DataflowAnnotator_hpp_
#define INC_DataflowAnnotator_hpp_

#include <antlr/config.hpp>
#include "DataflowAnnotatorTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "dataflow_annotator.g" -> "DataflowAnnotator.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "dataflow_annotator.g"

  // Prevent inclusion of WinSock since ASIO uses WinSock2
  #define _WINSOCKAPI_
  #include "DatabaseSelect.h"
  #include "ScriptInterpreter.h"

  #include <boost/algorithm/string/predicate.hpp>
  #include <boost/lexical_cast.hpp>
  #include <boost/tuple/tuple.hpp>
  #include <boost/variant.hpp>
  #include <boost/format.hpp>
  #include <boost/filesystem/path.hpp>
  #include <boost/filesystem/fstream.hpp>

  #include <map>
  #include <iostream>
  #include <fstream>

#line 29 "DataflowAnnotator.hpp"
/**
 * This class is used to perform typecheck of a MetraFlow script.
 * Given an AST produced by DataFlowTreeParser (dataflow_analyze.g)
 * this class writes to standard output an annotated version
 * of the MetraFlow script show the datatype flowing across
 * edge statements (arrows).  This class is used after calling
 * DesignTimePlan::type_check() so that the annotator can access
 * metadata of the input and output ports.  
 *
 * Before calling the program() method to generate
 * the output, you must call setDesignTimePlan(), setSymbolTable(), and
 * setOutputFile().
 */
class CUSTOM_API DataflowAnnotator : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public DataflowAnnotatorTokenTypes
{
#line 45 "dataflow_annotator.g"

private:
  MetraFlowLoggerPtr mLog;

  /** True if an ANTLR error occured during processing */
  bool mHasError;

  /** Contains a table of operation names and corresponding op information */
  std::map<std::string, DataflowSymbol> * mSymbol;

private:
  /** Convert given string to a wide string */
  std::wstring ASCIIToWide(const std::string& str)
  {
    std::wstring wstr;
    ::ASCIIToWide(wstr, str);
    return wstr;
  }    

  /**
   * Write to output the given parameter.
   *
   * @param parameterName  the AST token representing the parameter.
   * @param parameterValue the AST token containing the value of the parameter.
   */
  void outputArgument(ANTLR_USE_NAMESPACE(antlr) RefAST parameterName,
                      ANTLR_USE_NAMESPACE(antlr) RefAST parameterValue)
  {
    std::cout << parameterName->getText() << "=";
    std::cout << parameterValue->getText();
    if (parameterName->getNextSibling() != NULL)
    {
        std::cout << ", ";
    }
  }

  /**
   * Writes to output any syntax needed after the operation name
   * (like a left-bracket or not).
   *
   * @param opStatement  the AST token containing the statement.
   */
  void outputStatementOpen(ANTLR_USE_NAMESPACE(antlr) RefAST opStatement)
  {
    if (opStatement->getNumberOfChildren() > 0)
    {
      std::cout << "[";
    }
  }

  /**
   * Write to output any syntax need after the arguments
   * (like a right-bracket or not and an ending semi-colon.
   */
  void outputStatementClose(ANTLR_USE_NAMESPACE(antlr) RefAST opStatement)
  {
    if (opStatement->getNumberOfChildren() > 0)
    {
      std::cout << "]";
    }
    std::cout << ";\n";
  }

  /**
   * Write to output the metadata associated with the given port.
   * It is possible that the port will have no metadata (happens
   * if the MetraFlow script was not complete).
   */
  void outputPortMetadata(const boost::shared_ptr<Port> port)
  {
    if (port != NULL)
    {
      const RecordMetadata *metadata = port->GetMetadata();
      if (metadata != NULL)
      {
        std::cout << "{";

        for (int i=0; i<metadata->GetNumColumns(); i++)
        {
          DataAccessor *accessor = metadata->GetColumn(i);
          if (accessor == NULL)
          {
            mLog->logError("Encountered unexpected null in outputPortMetadata()");
            continue;
          }
          
          std::string utf8FieldName, utf8FieldType;
          ::WideStringToUTF8(accessor->GetName(), utf8FieldName);
          ::WideStringToUTF8(PhysicalFieldType::GetMTSQLDatatype(accessor), utf8FieldType);

          std::cout << utf8FieldName << " " << utf8FieldType;

          if (i != metadata->GetNumColumns()-1)
          {
            std::cout << ",";
          }
        }

        std::cout << "} ";
      }
    }
  }

public:

  ~DataflowAnnotator()
  {
  }

  /** Set the symbol table referencing operations used in the script. */
  void setSymbolTable(std::map<std::string, DataflowSymbol >& sym)
  {
    mSymbol = &sym;
  }

  /** Override the error and warning reporting */
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

  /** Set the log to use */
  void setLog(MetraFlowLoggerPtr log)
  {
    mLog = log;
    mHasError = false;
  }

  /** Did an ANTLR error occur during parsing? */
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
#line 46 "DataflowAnnotator.hpp"
public:
	DataflowAnnotator();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return DataflowAnnotator::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return DataflowAnnotator::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return DataflowAnnotator::tokenNames;
	}
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void broadcastStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void collStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void copyStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void devNullStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void exportStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void exportQueueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void exprStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void filterStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void delayedGenerateStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void groupByStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void hashPartStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void hashRunningTotalStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void importStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void importQueueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void innerHashJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void innerMergeJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void insertStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void meterStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void multiHashJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void printStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void projectionStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void renameStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightMergeAntiSemiJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightMergeSemiJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightOuterHashJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightOuterMergeJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sequentialFileOutputStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sequentialFileScanStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortGroupByStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortMergeStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortMergeCollStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sqlExecDirectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void switchStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void taxwareStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void unionAllStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void unrollStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void edgeStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void broadcastArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void nodeArgumentValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void collArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void devNullArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void selectArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void exportArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void exportQueueArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void exprArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void filterArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void generateStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void generateArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void expressionGenerateStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void expressionGenerateArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void groupByArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void hashPartArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void hashRunningTotalArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void importArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void importQueueArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void innerHashJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void innerMergeJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void insertArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void meterArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void multiHashJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void printArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void projectionArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void renameArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightMergeAntiSemiJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightMergeSemiJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightOuterHashJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void rightOuterMergeJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sequentialFileOutputArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sequentialFileScanArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortGroupByArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortMergeArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sortMergeCollArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sqlExecDirectStatementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sqlExecDirectArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void switchArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void taxwareArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void unionAllArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void unrollArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: boost::tuple<std::string, boost::variant<int,std::string>, bool >   arrowOrRefStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: bool  arrowArguments(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: boost::tuple<std::string, boost::variant<int,std::string>, bool >  nodeRefStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: bool  arrowBufferArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
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
	static const int NUM_TOKENS = 106;
#else
	enum {
		NUM_TOKENS = 106
	};
#endif
	
};

#endif /*INC_DataflowAnnotator_hpp_*/
