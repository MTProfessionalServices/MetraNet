#ifndef INC_DataflowTreeGenerator_hpp_
#define INC_DataflowTreeGenerator_hpp_

#include <antlr/config.hpp>
#include "DataflowTreeGeneratorTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "dataflow_generate.g" -> "DataflowTreeGenerator.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "dataflow_generate.g"
 
  // Prevent inclusion of WinSock since ASIO uses WinSock2
  #define _WINSOCKAPI_
  #include <map>
  #include <sstream>
  #include <boost/algorithm/string/predicate.hpp>
  #include <boost/lexical_cast.hpp>
  #include <boost/tuple/tuple.hpp>
  #include <boost/variant.hpp>
  #include <boost/format.hpp>
  #include <atlenc.h>
  #include "ArgEnvironment.h"
  #include "LogAdapter.h"
  #include "DatabaseSelect.h"
  #include "DesignTimeExpression.h"
  #include "DatabaseInsert.h"
  #include "DesignTimeExternalSort.h"
  #include "DesignTimeComposite.h"
  #include "DesignTimeCodeGeneratedComposite.h"
  #include "HashAggregate.h"
  #include "RecordParser.h"
  #include "SortMergeCollector.h"
  #include "Normalization.h"
  #include "MessageDigest.h"
  #include "SortRunningTotal.h"
  #include "Taxware.h"
  #include "DataFile.h"
  #include "LongestPrefixMatch.h"
  #include "MetraFlowQueue.h"
  #include "IdGeneratorOperator.h"
  #include "MTSQLParam.h"
  #include "ScriptInterpreter.h"
  #include "DatabaseMetering.h"
  #include "MyAST.h"
  #include "DataflowException.h"
  #include "CompositeDictionary.h"
  #include "OperatorArg.h"
  #include "Workflow.h"
  #include "WorkflowInstructionIf.h"
  #include "WorkflowInstructionStep.h"
  #include "WorkflowPredicate.h"

#line 53 "DataflowTreeGenerator.hpp"
class CUSTOM_API DataflowTreeGenerator : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public DataflowTreeGeneratorTokenTypes
{
#line 55 "dataflow_generate.g"

private:
  MetraFlowLoggerPtr mLog;
  bool mHasError;

  /** Map of the symbol tables for the steps. */
  std::map<std::wstring, DataflowSymbolTable*>* mMapOfSymbolTables;

  /** The workflow which holds the plans for all steps. */
  Workflow* mWorkflow;

  /** Symbol table for operators in the main script. */
  DataflowSymbolTable* mScriptSymbolTable;

  /** Design time plan for the main script */
  DesignTimePlan *mScriptPlan;

  /**
   * Active symbol table.  We may be storing operators
   * in mScriptSymbolTable, or we may be storing symbols in a temporary
   * table if we are analyzing a composite definition.
   */
  DataflowSymbolTable *mActiveSymbolTable;

  /**
   * Pointer to active design time plan.  We may working on the main script plan
   * or we may be working on a composite definition plan.
   */
  DesignTimePlan *mActivePlan;

  /** Name of the composite currently being parsed or empty string. */
  std::wstring mActiveCompositeName;

  /** True if a composite is actively being parsed. */
  bool mIsCompositeBeingParsed;

  /** 
   * Dictionary of defined composites. 
   * This dictionary was started during the parsing phase.
   * In this phase we add the design time plan to the definitions.
   */
  CompositeDictionary *mCompositeDictionary;

  /** The name of the file being parsed. Used for error reporting. */
  std::wstring mFilename;

  /**
   * The script interpreter used for expanding code generated composites 
   */
  DataflowScriptInterpreter * mScriptInterpreter;

  std::vector<Metering*> mMetering;
  std::vector<boost::shared_ptr<DatabaseMeteringStagingDatabase> > mDbs;

  /** Convert the standard string to a wide-string */
  std::wstring ASCIIToWide(const std::string& str)
  {
    std::wstring wstr;
    ::ASCIIToWide(wstr, str.c_str(), -1, mEncoding);
    return wstr;
  }

  /** 
   * Set the name of the given operation and add the
   * operator to the symbol table.  This should be redundant 
   * since the symbol entry was already created by 
   * dataflow_analyze.g and the line number of operator has 
   * been assigned.
   */
  void addToSymbolTable(DesignTimeOperator *op, RefMyAST id)
  {
    std::wstring wstrName;
    ::ASCIIToWide(wstrName, id->getText().c_str(), -1, mEncoding);
    op->SetName(wstrName);

    (*mActiveSymbolTable)[wstrName].Op = op;
  }

  /**
   * Form an operator argument. The caller of this method is 
   * responsible for freeing the returned argument pointer.
   *
   * @param name  argument name
   * @param value argument value
   */
  OperatorArg* formOperatorArg(RefMyAST name,
                               RefMyAST value)
  {
    OperatorArg *arg = NULL;

    if (value->getType() == STRING_LITERAL)
    {
      arg = new OperatorArg(ASCIIToWide(name->getText()), ASCIIToWide(value->getText()),
                            name->getLine(), name->getColumn(),
                            value->getLine(), value->getColumn(),
                            mFilename);
    }
    else if (value->getType() == TK_TRUE)
    {
      arg = new OperatorArg(ASCIIToWide(name->getText()), true,
                            name->getLine(), name->getColumn(),
                            value->getLine(), value->getColumn(),
                            mFilename);
    }
    else if (value->getType() == TK_FALSE)
    {
      arg = new OperatorArg(ASCIIToWide(name->getText()), false,
                            name->getLine(), name->getColumn(),
                            value->getLine(), value->getColumn(),
                            mFilename);
    }
    else if (value->getType() == NUM_INT)
    {
      boost::int32_t num(boost::lexical_cast<boost::int32_t>(value->getText()));
      arg = new OperatorArg(ASCIIToWide(name->getText()), num,
                            name->getLine(), name->getColumn(),
                            value->getLine(), value->getColumn(),
                            mFilename);
    }
    else
    {
      // This is unexpected -- there are no other types.
      throw DataflowInvalidArgumentException(
                            name->getLine(), name->getColumn(),
                            mFilename, L"", ASCIIToWide(name->getText()));
    }

    return arg;
  }

  /**
   * Check the values of the mode argument.  If not acceptable,
   * throw an expection (DataflowInvalidArgumentValueException).
   * Otherwise, set the mode of the operation.
   *
   * @param op        operator
   * @param name      ast holding the argument name
   * @param value     ast holding the argument value
   */
  void processModeParameter(DesignTimeOperator *op, RefMyAST name,
                            RefMyAST value)
  {
      if (value->getType() != STRING_LITERAL ||
          (!boost::algorithm::iequals("\"sequential\"", 
                                      value->getText().c_str()) && 
           !boost::algorithm::iequals("\"parallel\"", 
                                      value->getText().c_str())))
      {
        reportInvalidArgumentValue(op, name, value, 
                                   L"Expected \"sequential\" or \"parallel\"");
      }

      if (boost::algorithm::iequals("\"sequential\"", value->getText().c_str()))
      {
        op->SetMode(DesignTimeOperator::SEQUENTIAL);
      }
  }

  /**
   * Check the values of the collectionIDEncoded argument.  If not acceptable,
   * throw an expection (DataflowInvalidArgumentValueException).
   * Otherwise, set the collectionID of the meter operation.
   *
   * @param op        meter operator
   * @param id        ast holding the argument name
   * @param encoded   value to be used for encoded collection ID.
   *                  This should be a 16 bytes value encoded in base64.
   */
  void processCollectionIDEncodedParameter(
                            Metering *op, 
                            RefMyAST id,
                            std::string encoded)
  {
      BYTE decoded[32];
      int byteLength = 32;

      // Make sure we can decode the given string
      if (!Base64Decode(encoded.c_str(), encoded.size(), decoded, &byteLength))
      {
        reportInvalidArgument(op, id, 
                              L"Could not decode the base64 encoded string.");
      }

      // We expect that the decoded length is 16 bytes
      if (byteLength != 16)
      {
        reportInvalidArgument(op, id, 
                                  L"The decoded string was not 16 bytes long.");
      }

      // Shove the 16 bytes into a boost vector.
      std::vector<boost::uint8_t> val;
      for (int i=0; i<16; i++)
      {
        val.push_back((boost::uint8_t)(decoded[i]));
      }

      // Set this value in the meter operator.
      op->SetCollectionID(val);
  }

  /**
   * Report an incorrect argument value encountered in the script.
   *
   * @param op        operator
   * @param name      ast holding the argument name
   * @param value     ast holding the argument value
   * @param expected  a phrase explaining expected values (e.g. Expected a or b).
   */
  void reportInvalidArgumentValue(DesignTimeOperator *op, RefMyAST name,
                                   RefMyAST value, const std::wstring& expected)
  {
    throw DataflowInvalidArgumentValueException(value->getLine(),
                                                value->getColumn(),
                                                mFilename,
                                                op->GetName(),
                                                ASCIIToWide(name->getText()),
                                                ASCIIToWide(value->getText()),
                                                expected);
  }

  /**
   * Report an incorrect argument encountered in the script.
   *
   * @param op        operator
   * @param name      ast holding the argument name
   * @param reason    a phrase explaining the problem
   */
  void reportInvalidArgument(DesignTimeOperator *op, RefMyAST name,
                             const std::wstring& reason)
  {
    throw DataflowInvalidArgumentException(
                                       name->getLine(), name->getColumn(),
                                       mFilename,
                                       op->GetName(), reason);
  }

  /**
   * Report an operator with implausible arguments in the script.
   *
   * @param op        operator
   * @param id        the AST holding the operator
   * @param reason    a phrase explaining the problem
   */
  void reportInvalidArguments(DesignTimeOperator *op, RefMyAST id,
                              const std::wstring& reason)
  {
    throw DataflowInvalidArgumentsException(id->getLine(), id->getColumn(),
                                            mFilename, op->GetName(), reason);
  }

  /**
   * Report an internal error.
   *
   * @param reason   a phrase explaining the problem.
   */
  void reportInternalError(const std::wstring& reason, RefMyAST id)
  {
    std::wstringstream out;
    out << reason << L": \"" << ASCIIToWide(id->getText()) << L"\"";
    throw DataflowInternalErrorException(out.str());
  }

  /**
   * Verify that the referenced port exists.  If not,
   * throw an error.
   * 
   * @param ports        Collection of input or output ports of operator
   * @param portInfo     Tuple of <operator name, <port id, port name>, 
   *                            line number, column number>
   * @param isInputPort  true if this is an input port
   */
  void verifyPortExists(const PortCollection& ports,
                        boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int > portInfo,
                        bool isInput)
  {
    // Verify that the referenced port exists
    if (portInfo.get<1>().which() == 0 )
    {
      if (!ports.doesPortExist(boost::get<int>(portInfo.get<1>())))
      {
        throw DataflowUndefPortException(
                                  portInfo.get<0>(), L"", 
                                  boost::get<int>(portInfo.get<1>()),
                                  isInput, portInfo.get<2>(), 
                                  portInfo.get<3>(),
                                  mFilename);
      }
    }
    else
    {
      if (!ports.doesPortExist(boost::get<std::wstring>(portInfo.get<1>())))
      {
        throw DataflowUndefPortException(
                                  portInfo.get<0>(), 
                                  boost::get<std::wstring>(portInfo.get<1>()), 0,
                                  isInput, portInfo.get<2>(), portInfo.get<3>(),
                                  mFilename);
      }
    }
  }

  /**
   * Get the hex value corresponding to the given character.
   */
  boost::uint32_t GetHexValue(char c)
  {
    static boost::uint32_t lut[128];
    static bool init(false);
    if (!init)
    {
      for(int i=0; i<128; i++) lut[i]=0xffffffff;
      lut['0'] = 0;
      lut['1'] = 1;
      lut['2'] = 2;
      lut['3'] = 3;
      lut['4'] = 4;
      lut['5'] = 5;
      lut['6'] = 6;
      lut['7'] = 7;
      lut['8'] = 8;
      lut['9'] = 9;
      lut['a'] = lut['A'] = 10;
      lut['b'] = lut['B'] = 11;
      lut['c'] = lut['C'] = 12;
      lut['d'] = lut['D'] = 13;
      lut['e'] = lut['E'] = 14;
      lut['f'] = lut['F'] = 15;
      init = true;
    }

    if ((boost::int32_t) c < 0 || (boost::int32_t) c > 127) return 0xffffffff;
    return lut[c];
  }

  /**
   * The encoding of the file.  Defaults to locale codepage but may
   * overridden (e.g. to UTF8).
   */
  boost::int32_t mEncoding;

public:
  ~DataflowTreeGenerator()
  {
    for (std::vector<Metering*>::iterator it = mMetering.begin();
         it != mMetering.end();
         ++it)
    {
      delete *it;
    }
  }

  virtual void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t)
  {
    // Since we are exclusively using MyAST as the AST Type in
    // the AST tree built by DataflowParser and DataflowTreeParser
    // we can safely cast the RefAST to RefMyAST.
    program((RefMyAST)_t);
  }

  /**
   * Set the map of step name to symbol table.
   * The symbol table is used for operators encountered
   * in the step (rather than in composite definitions).
   * This should be called prior to invoking program().
   * This class does not own the symbol table.
   */
  void setSymbolTable(
            std::map<std::wstring, DataflowSymbolTable*>* mapOfSymbolTables)
  {
    mMapOfSymbolTables = mapOfSymbolTables;
    mScriptSymbolTable = (*mapOfSymbolTables)[L"main"];
    mActiveSymbolTable = mScriptSymbolTable;
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

  void setScriptInterpreter(DataflowScriptInterpreter * scriptInterpreter)
  {
    mScriptInterpreter = scriptInterpreter;
  }
  
  /** Set the workflow */
  void setWorkflow(Workflow *workflow)
  {
    mWorkflow = workflow;
    mScriptPlan = workflow->getDesignTimePlan(Workflow::DefaultStepName);
    mActivePlan = mScriptPlan;
  }

  /**
   * Set encoding of the parser.
   */
  void setEncoding(boost::int32_t encoding)
  {
    mEncoding = encoding;
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
#line 57 "DataflowTreeGenerator.hpp"
public:
	DataflowTreeGenerator();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return DataflowTreeGenerator::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return DataflowTreeGenerator::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return DataflowTreeGenerator::tokenNames;
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
	public: void delayedGenerateStatement(RefMyAST _t);
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
	public: void ifPredicate(RefMyAST _t,
		WorkflowPredicate** predicate
	);
	public: void ifArgument(RefMyAST _t,
		WorkflowPredicate* predicate
	);
	public: void doesFileExistPredicate(RefMyAST _t,
		WorkflowPredicate** predicate
	);
	public: void isFileEmptyPredicate(RefMyAST _t,
		WorkflowPredicate** predicate
	);
	public: void operatorArgument(RefMyAST _t,
		DesignTimeOperator * op
	);
	public: void nodeArgumentValue(RefMyAST _t);
	public: void operatorArgumentList(RefMyAST _t,
		OperatorArg** opArgSubList
	);
	public: void generateStatement(RefMyAST _t);
	public: void expressionGenerateStatement(RefMyAST _t);
	public: void meterArgument(RefMyAST _t,
		Metering * op, std::vector<std::wstring>& services, std::vector<std::wstring>& keys
	);
	public: void compositeArgument(RefMyAST _t,
		const CompositeDefinition* defn,
                  DesignTimeComposite *op
	);
	public: boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >   arrowOrRefStatement(RefMyAST _t);
	public: bool  arrowArguments(RefMyAST _t);
	public: boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >  nodeRefStatement(RefMyAST _t);
	public: bool  arrowBufferArgument(RefMyAST _t);
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

#endif /*INC_DataflowTreeGenerator_hpp_*/
