header {
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
}

options {
	language="Cpp";
}

class DataflowParser extends Parser;

options {
  k = 3;
  importVocab=Dataflow;
	buildAST = true;
  defaultErrorHandler = false;
  ASTLabelType = "RefMyAST";
}

tokens {
  ACCOUNT_RESOLUTION;
  BROADCAST;
  COLL;
  COMPOSITE;
  COPY;
  DEVNULL;
  EXPORT;
  EXPORT_QUEUE;
  EXPR;
  FILTER;
  GENERATE;
  GROUP_BY;
  HASHPART;
  HASH_RUNNING_TOTAL;
  ID_GENERATOR;
  IMPORT;
  IMPORT_QUEUE;
  INNER_HASH_JOIN;
  INNER_MERGE_JOIN;
  INSERT;
  LOAD_ERROR;
  LOAD_USAGE;
  LONGEST_PREFIX_MATCH;
  MD5;
  METER;
  MULTI_HASH_JOIN;
  PRINT;
  PROJECTION;
  RANGEPART;
  RATE_CALCULATION;
  RATE_SCHEDULE_RESOLUTION;
  RENAME;
  RIGHT_MERGE_ANTI_SEMI_JOIN;
  RIGHT_MERGE_SEMI_JOIN;
  RIGHT_OUTER_HASH_JOIN;
  RIGHT_OUTER_MERGE_JOIN;
  SELECT;
  SEQUENTIAL_FILE_DELETE;
  SEQUENTIAL_FILE_OUTPUT;
  SEQUENTIAL_FILE_RENAME;
  SEQUENTIAL_FILE_SCAN;
  SESSION_SET_BUILDER;
  SORT;
  SORT_GROUP_BY;
  SORTMERGE;
  SORTMERGECOLL;
  SORT_NEST;
  SORT_ORDER_ASSERT;
  SORT_RUNNING_TOTAL;
  STEP;
  SUBSCRIPTION_RESOLUTION;
  SQL_EXEC_DIRECT;
  SWITCH;
  TAXWARE;
  UNION_ALL;
  UNNEST;
  UNROLL;
  PREDICATE_DOES_FILE_EXIST;
  PREDICATE_IS_FILE_EMPTY;
  WRITE_ERROR;
  WRITE_PRODUCT_VIEW;
}

{
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
}

program
options {
    defaultErrorHandler = true;
}
  :
  (BOM! { mEncoding = CP_UTF8; })? 
  (includeCompositeStatement (SEMI!)?)*
  (
  nodeStatement (SEMI!)?
  | 
  edgeStatement (SEMI!)?
  |
  compositeDeclaration
  |
  stepDeclaration
  )* 
  (controlFlow)?
  EOF
  ;

includeCompositeStatement
  :
  (INCLUDE_COMPOSITE filename:STRING_LITERAL)
  {
    std::wstring fname;
    ::ASCIIToWide(fname, filename->getText().c_str(), -1, mEncoding);
    if (fname.size() >= 2)
    {
      fname = fname.substr(1, fname.size()-2); 
    }

    // Locate the include file
    std::wstring outFullPath;
    if (!mInterpreter->resolveIncludeFile(mFilename, fname, outFullPath))
    {
        std::wstringstream out;
        out << L"\nFile not found: \"" << fname << L"\".  This file "
               L"must be in (1) extensions\\*\\config\\Metraflow\\"
               L"Composites\\ or in (2) config\\MetraFlow\\*\\Composites "
               L"or in (3) the local working directory  "
               L"or in (4) the same directory as given MetraFlow script file.";
        throw (DataflowGeneralException(filename->getLine(),
                                        filename->getColumn(), 
                                        mFilename,
                                        out.str()));
    }
    boost::filesystem::wpath fullPath(outFullPath, boost::filesystem::native);

    // Check if this is a circular import file reference.
    if (mInterpreter->isFileIncludeInProgress(fullPath.native_file_string()))
    {
      std::wstringstream out;
      out << L"\nImported files references are circular: \"" 
          << fullPath.native_file_string() << L"\"";
      throw (DataflowGeneralException(filename->getLine(),
                                      filename->getColumn(), 
                                      mFilename,
                                      out.str()));
    }

    // Check if we've already imported this file.
    if (!mInterpreter->isFileAlreadyIncluded(fullPath.native_file_string()))
    {
      boost::filesystem::ifstream f(fullPath);

      if (mInterpreter->includeComposite(fullPath.native_file_string(), f, mEncoding) != 0)
      {
        throw (DataflowGeneralException(filename->getLine(),
                                        filename->getColumn(), 
                                        mFilename,
                                        L"Include of composite failed."));
      }
    }
  }
  ;

compositeDeclaration
{
  // We start forming a composite definition.  We will add
  // this to the composite dictionary when completed.
  mActiveCompositeDefinition = new CompositeDefinition(mFilename);
}
  :
  (OPERATOR^ id:ID LBRACKET! (compositeParameters)? RBRACKET! compositeBody)
  {
    // Check if this composite has already been declared.
    const CompositeDefinition* defn = 
              mCompositeDictionary->getDefinition(ASCIIToWide(id->getText()));

    if (defn != NULL)
    {
      throw DataflowRedefinedCompositeException(
              ASCIIToWide(id->getText()),
              defn->getLineNumber(),
              defn->getColumnNumber(),
              mFilename,
              id->getLine(),
              id->getColumn());
    }

    mActiveCompositeDefinition->setName(ASCIIToWide(id->getText()));
    mActiveCompositeDefinition->setLocation(id->getLine(), id->getColumn(), L"");

    // We need to add the composite name to the dictionary
    // in the parsing phrase so that we can identify operators
    // referring to composites and set the operator type appropriately.
    mCompositeDictionary->add(mActiveCompositeDefinition);

    // The dictionary now has ownership of the pointer and is reasonable
    // for freeing.
    mActiveCompositeDefinition = NULL;
  };

compositeParameters
  :
  (compositeParameterSpec (COMMA! compositeParameterSpec)*);

compositeParameterSpec
  : 
  (compositeParameterInputSpec | 
   compositeParameterOutputSpec |
   compositeArgSpec
  );

compositeParameterInputSpec
  {
    int portIndex(0);
    std::wstring portName;
    int portLine, portCol;
  }
  :
  INPUT^ paramName:STRING_LITERAL IS operatorId:ID 
  LPAREN!  (i:NUM_INT 
            { 
              portIndex = boost::lexical_cast<int>(#i->getText()); 
              portLine = #i->getLine();
              portCol = #i->getColumn();
            }
          | s:STRING_LITERAL
            { 
              portLine = #s->getLine();
              portCol = #s->getColumn();
              ::ASCIIToWide(portName, #s->getText().substr(1, #s->getText().size()-2).c_str(), -1, mEncoding);
            }
           ) 
  RPAREN!
  {
    mActiveCompositeDefinition->addInput(
      ASCIIToWide(paramName->getText().substr(1, paramName->getText().size()-2)),
      ASCIIToWide(operatorId->getText()), portName, portIndex,
      paramName->getLine(), paramName->getColumn(),
      operatorId->getLine(), operatorId->getColumn(),
      portLine, portCol);
  };

compositeParameterOutputSpec
  {
    int portIndex(0);
    std::wstring portName;
    int portLine, portCol;
  }
  :
  OUTPUT^ paramName:STRING_LITERAL IS operatorId:ID 
  LPAREN!  (i:NUM_INT 
            { 
              portIndex = boost::lexical_cast<int>(#i->getText()); 
              portLine = #i->getLine();
              portCol = #i->getColumn();
            }
          | s:STRING_LITERAL
            { 
              portLine = #s->getLine();
              portCol = #s->getColumn();
              ::ASCIIToWide(portName, #s->getText().substr(1, #s->getText().size()-2).c_str(), -1, mEncoding);
            }
           ) 
  RPAREN!
  {
    mActiveCompositeDefinition->addOutput(
      ASCIIToWide(paramName->getText().substr(1, paramName->getText().size()-2)),
      ASCIIToWide(operatorId->getText()), portName, portIndex,
      paramName->getLine(), paramName->getColumn(),
      operatorId->getLine(), operatorId->getColumn(),
      portLine, portCol);
  };

compositeArgSpec
  {
    OperatorArgType argType;
  }
  :
  (    STRING_DECL^  { argType = OPERATOR_ARG_TYPE_STRING; }
    | INTEGER_DECL^  { argType = OPERATOR_ARG_TYPE_INTEGER; }
    | BOOLEAN_DECL^  { argType = OPERATOR_ARG_TYPE_BOOLEAN; }
    | SUBLIST_DECL^  { argType = OPERATOR_ARG_TYPE_SUBLIST; }
  ) DOLLAR_SIGN variableId: ID
  {
    mActiveCompositeDefinition->addArg(argType,
                                       ASCIIToWide(variableId->getText()),
                                       variableId->getLine(),
                                       variableId->getColumn());

    mArgEnvironment->storeEnvironmentalSettingForArg(ASCIIToWide(variableId->getText()));
  }
  ;
  
compositeBody
  :
  LPAREN!  (nodeStatement (SEMI!)?  | 
            edgeStatement (SEMI!)?)* RPAREN!
  ;

stepDeclaration
  :
  (STEP_DECL^ id:ID LBRACKET! RBRACKET! stepBody)
  {
    // Add the step to the workflow known steps.
    if (!mWorkflow->addStepDeclaration(ASCIIToWide(id->getText())))
    {
      throw DataflowRedefinedStepException(
              ASCIIToWide(id->getText()),
              mFilename,
              id->getLine(),
              id->getColumn());
    }
  };

stepBody
  :
  LPAREN  (nodeStatement (SEMI!)?  | 
           edgeStatement (SEMI!)?)* RPAREN
  ;

controlFlow
  : 
  STEPS_BEGIN
  controlFlowBody
  STEPS_END
  ;

controlFlowBody
  : 
  (stepStatement | ifStatement)*
  ;

ifStatement
  :
  IF_BEGIN
  LPAREN
  ifPredicate 
  RPAREN
  THEN
  controlFlowBody
  ( ELSE
    controlFlowBody)?
  IF_END
  (SEMI!)?
  ;

ifPredicate
  :
  (BANG)? id:ID LPAREN ifArgument RPAREN
  {
    if (boost::algorithm::iequals(#id->getText(), "doesFileExist"))
    {
      #id->setType(PREDICATE_DOES_FILE_EXIST);
    }
    else if (boost::algorithm::iequals(#id->getText(), "isFileEmpty"))
    {
      #id->setType(PREDICATE_IS_FILE_EMPTY);
    }
    else
    {
      throw DataflowGeneralException(
              #id->getLine(),
              #id->getColumn(),
              mFilename,
              L"Encountered unrecognized if predicate: " + ASCIIToWide(#id->getText()));
    }
  }
  ;

stepStatement
{
  std::wstring opType;
  int opTypeLine=1;
  int opTypeCol=1;
}
  :
  (
    id:ID^ 
    { 
      ::ASCIIToWide(opType, #id->getText().c_str(), -1, mEncoding);
      opTypeLine = id->getLine(); 
      opTypeCol = id->getColumn(); 
      #id->setType(STEP);
    } 
  )
  (SEMI!)?
  {
    if (!mWorkflow->isKnownStep(opType.c_str()))
    {
      throw DataflowGeneralException(
              #id->getLine(),
              #id->getColumn(),
              mFilename,
              L"Encountered unrecognized step: " + opType);
    }
  }
  ;

nodeStatement
{
  std::string opType;
  int opTypeLine=1;
  int opTypeCol=1;
}
  :
  (
    id:ID^ 
    { 
      opType = #id->getText(); 
      opTypeLine = id->getLine(); 
      opTypeCol = id->getColumn(); 
    } 
    (COLON id2:ID 
      { 
        opType = #id2->getText(); 
        opTypeLine = id2->getLine(); 
        opTypeCol = id2->getColumn(); 
      } 
    )? 
    (LBRACKET! (arguments)? RBRACKET!)?
  )
  {
    std::wstring wOpType;
    ::ASCIIToWide(wOpType, opType.c_str(), -1, mEncoding);

    if (boost::algorithm::iequals(opType.c_str(), "account_lookup"))
    {
      ##->setType(ACCOUNT_RESOLUTION);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "broadcast") || 
        boost::algorithm::iequals(opType.c_str(), "bcast"))
    {
      ##->setType(BROADCAST);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "coll"))
    {
      ##->setType(COLL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "copy"))
    {
      ##->setType(COPY);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "devnull"))
    {
      ##->setType(DEVNULL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "export"))
    {
      ##->setType(EXPORT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "export_queue"))
    {
      ##->setType(EXPORT_QUEUE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "expr"))
    {
      ##->setType(EXPR);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "filter"))
    {
      ##->setType(FILTER);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "generate"))
    {
      ##->setType(GENERATE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "group_by") ||
             boost::algorithm::iequals(opType.c_str(), "hash_group_by"))
    {
      ##->setType(GROUP_BY);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "hashpart") ||
             boost::algorithm::iequals(opType.c_str(), "hash_part"))
    {
      ##->setType(HASHPART);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "hash_running_total"))
    {
      ##->setType(HASH_RUNNING_TOTAL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "id_generator"))
    {
      ##->setType(ID_GENERATOR);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "import"))
    {
      ##->setType(IMPORT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "import_queue"))
    {
      ##->setType(IMPORT_QUEUE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "inner_hash_join"))
    {
      ##->setType(INNER_HASH_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "inner_merge_join"))
    {
      ##->setType(INNER_MERGE_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "insert"))
    {
      ##->setType(INSERT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "load_error"))
    {
      ##->setType(LOAD_ERROR);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "load_usage"))
    {
      ##->setType(LOAD_USAGE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "longest_prefix_match"))
    {
      ##->setType(LONGEST_PREFIX_MATCH);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "md5"))
    {
      ##->setType(MD5);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "meter"))
    {
      ##->setType(METER);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "multi_hash_join"))
    {
      ##->setType(MULTI_HASH_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "print"))
    {
      ##->setType(PRINT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "proj") ||
             boost::algorithm::iequals(opType.c_str(), "project") ||
             boost::algorithm::iequals(opType.c_str(), "projection"))
    {
      ##->setType(PROJECTION);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "rangepart"))
    {
      ##->setType(RANGEPART);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "parameter_table_lookup"))
    {
      ##->setType(RATE_CALCULATION);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "rate_schedule_lookup"))
    {
      ##->setType(RATE_SCHEDULE_RESOLUTION);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "rename"))
    {
      ##->setType(RENAME);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "right_merge_anti_semi_join"))
    {
      ##->setType(RIGHT_MERGE_ANTI_SEMI_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "right_merge_semi_join"))
    {
      ##->setType(RIGHT_MERGE_SEMI_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "right_outer_hash_join") ||
             boost::algorithm::iequals(opType.c_str(), "right_hash_join"))
    {
      ##->setType(RIGHT_OUTER_HASH_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "right_outer_merge_join") ||
             boost::algorithm::iequals(opType.c_str(), "right_merge_join"))
    {
      ##->setType(RIGHT_OUTER_MERGE_JOIN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "select"))
    {
      ##->setType(SELECT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_delete"))
    {
      ##->setType(SEQUENTIAL_FILE_DELETE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_write"))
    {
      ##->setType(SEQUENTIAL_FILE_OUTPUT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_rename"))
    {
      ##->setType(SEQUENTIAL_FILE_RENAME);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_scan"))
    {
      ##->setType(SEQUENTIAL_FILE_SCAN);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "session_set_builder"))
    {
      ##->setType(SESSION_SET_BUILDER);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sort_group_by"))
    {
      ##->setType(SORT_GROUP_BY);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sortmerge") ||
             boost::algorithm::iequals(opType.c_str(), "sort_merge"))
    {
      ##->setType(SORTMERGE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sortmergecoll") ||
             boost::algorithm::iequals(opType.c_str(), "sort_merge_coll"))
    {
      ##->setType(SORTMERGECOLL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sort"))
    {
      ##->setType(SORT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sort_nest"))
    {
      ##->setType(SORT_NEST);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "assert_sort_order"))
    {
      ##->setType(SORT_ORDER_ASSERT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sort_running_total"))
    {
      ##->setType(SORT_RUNNING_TOTAL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "sql_exec_direct"))
    {
      ##->setType(SQL_EXEC_DIRECT);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "subscription_lookup"))
    {
      ##->setType(SUBSCRIPTION_RESOLUTION);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "switch"))
    {
      ##->setType(SWITCH);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "taxware"))
    {
      ##->setType(TAXWARE);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "unionall") ||
             boost::algorithm::iequals(opType.c_str(), "union_all"))
    {
      ##->setType(UNION_ALL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "unnest"))
    {
      ##->setType(UNNEST);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "unroll"))
    {
      ##->setType(UNROLL);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "write_error"))
    {
      ##->setType(WRITE_ERROR);
    }
    else if (boost::algorithm::iequals(opType.c_str(), "write_product_view"))
    {
      ##->setType(WRITE_PRODUCT_VIEW);
    }
    else if (mCompositeDictionary->isDefined(wOpType.c_str()))
    { 
      ##->setType(COMPOSITE);
    }

    else
    {
      throw DataflowGeneralException(
              opTypeLine,
              opTypeCol,
              mFilename,
              L"Encountered unknown operator: " + wOpType);
    }
  }
  ;

arguments
  :
  argument (COMMA! argument)*
  ;

argument
  :
  ID^ EQUALS! (argumentValue | argumentVariable)
  ;

argumentValue
  :
  NUM_INT
  |
  NUM_BIGINT
  |
  NUM_FLOAT
  |
  NUM_DECIMAL
  |
  STRING_LITERAL
  |
  TK_TRUE
  |
  TK_FALSE
  |
  LBRACKET! arguments RBRACKET!
  ;

argumentVariable
  :
  DOLLAR_SIGN ID
  ;

ifArgument
  :
  (ifArgumentValue | argumentVariable)
  ;

ifArgumentValue
  :
  STRING_LITERAL
  ;

annotationArguments
  :
  annotationArgument (COMMA! annotationArgument)*
  ;

annotationArgument
  :
  ID^ annotationArgumentDataType
  ;

annotationArgumentDataType
  :
  ID
  |
  (ID ID)
  ;

edgeStatement
  :
  nodeDefOrRef (ARROW^ (arrowArguments)? (arrowAnnotation)? nodeDefOrRef)+
  ;

arrowArguments
  :
  LBRACKET^ arguments RBRACKET!
  ;

arrowAnnotation
  :
  LCURLY^ annotationArguments RCURLY!
  ;

protected
nodeDefOrRef
  :
  ID^ (LPAREN! (NUM_INT | STRING_LITERAL) RPAREN!)?
  ;
