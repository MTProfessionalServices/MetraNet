#ifndef __SCRIPTINTERPRETER_H__
#define __SCRIPTINTERPRETER_H__

#include <istream>
#include <boost/cstdint.hpp>

#include "MetraFlowConfig.h"
#include "Reporter.h"
#include "ReporterCmdLine.h"
#include "CompositeDictionary.h"
#include "LogAdapter.h"
#include "Workflow.h"
#include "WorkflowHistorian.h"
#include "DataflowSymbol.h"

/**
 * The interpreter of the MetraFlow scripts.
 */
class DataflowScriptInterpreter
{
private:
  /** 
   * A map of step name to symbol table.
   * The symbol table contains all operators that are present in the 
   * step.  This symbol table is filled by dataflow_parser.g.
   * Keep in mind, even if no steps are formally used in the script,
   * the operators/edgements in the main body are placed in a default
   * step named "main".
   */
  std::map<std::wstring, DataflowSymbolTable *> mMapOfSymbolTables;

  /** Contains composite definitions. */
  CompositeDictionary mCompositeDictionary;
   
  /**
   * A map of included filenames.  False indicates that the include
   * is in progress (important for detecting circular references).
   * True indicates the include has been completed (important for
   * ignoring repeated includes of the same file).
   */
  std::map<std::wstring, bool> mIncludedFilenames;

  /** The name of the file parsed file or empty string if not known. */
  std::wstring mParsedFilename;

  /** 
   * The name of the plan currently being interpreter. 
   * Used for error reporting.
   */
  std::wstring mCurrentStepName;

  /** 
   * Interface to the user of the interepreter.
   * Receiver of exceptions that occur during parsing or type checking 
   */
  Reporter *mReporter;

  /** Reporter to use if one is not specified in the constructor. */
  ReporterCmdLine mDefaultReporter;

  /** The historian of what happened during script runs. */
  WorkflowHistorian *mHistorian;

  /** Logger */
  MetraFlowLoggerPtr mLogger;

private:
  /**
   * Use generate a workflow containing design time plans from the script.
   *
   * @param filename             The name of the file being parsed.
   * @param script               The script to turn into a design time plan
   * @param encoding             Character encoding of the script stream.
   * @param isVerifyAndTypeCheck If true, verify the plan, expand composites
   *                             and type check. (If we are using this method
   *                             to import composites, we set this to false).
   * @param isAnnotate           True if we want to produce an annotation.
   * @param workflow             The workflow
   * @return 0 on success.
   */
  int parse(const std::wstring& filename,
            std::istream& script, 
            boost::int32_t encoding,
            bool isVerifyAndTypeCheck,
            bool isAnnotate,
            Workflow &workflow);

  /** Inform all slave processes to abort processing. */
  METRAFLOW_DECL void Abort(boost::int32_t numPartitions, bool isCluster);

  /** Disallowed */
  DataflowScriptInterpreter(const DataflowScriptInterpreter&);

  /** Disallowed */
  DataflowScriptInterpreter& operator = (const DataflowScriptInterpreter&);

public:
  /**
   * Constructor.  Creates a default reporter of parsing and type checking
   * errors.
   */
  METRAFLOW_DECL DataflowScriptInterpreter();

  /**
   * Constructor
   *
   * @param reporter  Used for the reporting of errors that occur during
   *                  parsing and type checkin.
   */
  METRAFLOW_DECL DataflowScriptInterpreter(Reporter *reporter);

  /** Destructor */
  METRAFLOW_DECL ~DataflowScriptInterpreter();

  /**
   * Returns true if a parse or type-check error occurred during
   * the evalution of the MetraFlow script.
   *
   * @param msg        Error message.
   * @param lineNumber Line number where the error occurred. <= 0 is unknown.
   * @param colNumber  Column number where the error occurred. <= 0 is unknown.
   */
  METRAFLOW_DECL bool didParseErrorOccur(std::wstring &msg, 
                                         int &lineNumber, int &colNumber);
  
  /** Execute based on the given command line parameters. */
  METRAFLOW_DECL int Run(int argc, char * argv[]);

  /**
   * Parses the given script and produces a workflow containing
   * design time plans.  Type-checks all the design time plan.
   *
   * @param script           stream containing script being parsed.
   * @param encoding         The character encoding of the input script stream.
   * @param numPartitions    number of partitions
   * @param partitionListDefinitions    named partition lists that may be 
   *                         referenced by programs to enforce partition 
   *                         constraints.
   * @param isTypeCheckOnly  if true, an annotated script is written to stdout
   *                         and the script is not executed.
   * @param isNewTrackingRun if true, this run will be tracked. 
   * @param isRerun          if true, this script will run based on 
   *                         the last step run.  trackingID identifies
   *                         the last run.  filename is not needed.
   * @param filename         name of the file being parsed or empty string
   *                         if not known.  Used in error reporting.
   */
  METRAFLOW_DECL int Run(std::istream& script,
                         boost::int32_t encoding, 
                         boost::int32_t numPartitions, 
                         bool isCluster, 
                         const std::map<std::wstring, std::vector<boost::int32_t> > & partitionListDefinitions,
                         bool isTypeCheckOnly=false,
                         bool isNewTrackingRun=false,
                         bool isRerun=false,
                         const std::wstring &trackingID=L"",
                         const std::wstring &filename=L"");

  /** Inform all slave processes that we are done processing all plans. */
  static METRAFLOW_DECL void tellSlavesWeAreDone(boost::int32_t numPartitions, 
                                                 bool isCluster);


  /**
   * Parses the given script and produces a workflow.  
   * A workflow is a set of design time plans (steps) and the flow control
   * for running them.  Type-checks all the design time plans.  
   * If an error occurs, the error is reported
   * using mReporter.
   *
   * @param filename         The name of the file containing the script or
   *                         empty string if not known.  If provided,
   *                         the filename will be reported in error messages.
   * @param script           The script to turn into a design time plan
   * @param encoding         Encoding of the input script.
   * @param isTypeCheckOnly  If true, an annotated version of the
   *                         script is produced.
   * @param workflow         The created workflow.
   * @return 0 on success.
   */
  METRAFLOW_DECL int createWorkflow(std::wstring filename,
                                    std::istream& script,
                                    boost::int32_t encoding, 
                                    bool isTypeCheckOnly,
                                    Workflow &workflow);
  /** 
   * Return the line number in the script where the given operator
   * was defined, or -1 if not known. This uses mCurrentStepName
   * to determine the symbol table to find the line number.
   *
   * @param stepName  name of the step the operator occurs in.
   * @param op        operator
   */
  METRAFLOW_DECL int getLineNumber(const DesignTimeOperator &op);

  /** 
   * Return the column number in the script where the given operator
   * was defined, or -1 if not known. This uses mCurrentStepName
   * to determine the symbol table to find the column number.
   *
   * @param stepName  name of the step the operator occurs in.
   * @param op        operator
   */
  METRAFLOW_DECL int getColumnNumber(const DesignTimeOperator &op);

  /**
   * Parse the given file containing the composite.
   * Adds the composite definition to the dictionary.
   *
   * @param filename  the name of the script being imported.
   * @param script    file stream containing the script.
   * @param encoding  The encoding of the input script stream.
   * @param return    0 on success
   */
  METRAFLOW_DECL int includeComposite(const std::wstring& filename,
                                      std::istream& script,
                                      boost::int32_t encoding);

  /**
   * Parse the code generated composite operator.
   * Adds the composite definition to the dictionary.  Also associates the
   * composite instance named with the definition.
   *
   * @param compositeName         the name of the composite being generated.
   * @param script                string containing the script.
   * @param compositeInstanceName the name of the composite operator instance.
   * @param referencedComposites  map in which to store the association between the 
   *                              operator instance and the code generated definition.
   * @param return    0 on success
   */
  METRAFLOW_DECL int codeGenerateComposite(const std::wstring& compositeName,
                                           const std::wstring& script,
                                           const std::wstring& compositeInstanceName);

  /** Is the included of this file already in progress? */
  bool isFileIncludeInProgress(const std::wstring& filename) const;

  /** Has this file already been included? */
  bool isFileAlreadyIncluded(const std::wstring& filename) const;

  /** 
   * Resolve the include file.
   *
   * @param fileBeingParsed  Name of the file being parsed.
   * @param fname            Specified include file name.
   * @param fullPath         Set to the full path name for the file.
   * @return true if file was found.
   */
  bool resolveIncludeFile(const std::wstring& fileBeingParsed,
                          const std::wstring& fname, 
                          std::wstring &fullPath) const;
};

class DataflowPreparedPlan
{
private:
  DataflowScriptInterpreter mInterpreter;
  boost::int32_t mNumPartitions;
  bool mIsCluster;
  MetraFlowLoggerPtr mLogger;
  ReporterCmdLine mReporter;
  WorkflowHistorian *mHistorian;
  std::map<std::wstring, std::vector<boost::int32_t> > mPartitionListDefns;
  Workflow *mWorkflow;

  void Abort();

public:
  /**
   * Constructor.
   * Attempt to produce a design time plan from the given script.
   * Throws an exception if unable to.
   */
  METRAFLOW_DECL DataflowPreparedPlan(std::istream& script,
                                      boost::int32_t encoding, 
                                      boost::int32_t numPartitions, 
                                      bool isCluster);
  /**
   * Constructor.
   * Attempt to produce a design time plan from the given script.
   * Reports a parse error through passed arguments rather than
   * throwing an exception.
   *
   * @param encoding   The encoding of the input script stream.
   * @param didErrorOccur  True if an error occurred.
   * @param msg        Error message.
   * @param lineNumber Line number where the error occurred. <= 0 is unknown.
   * @param colNumber  Column number where the error occurred. <= 0 is unknown.
   */
  METRAFLOW_DECL DataflowPreparedPlan(std::istream& script,
                                      boost::int32_t encoding, 
                                      boost::int32_t numPartitions, 
                                      bool isCluster,
                                      bool &didErrorOccur,
                                      std::wstring &msg,
                                      int &lineNumber,
                                      int &colNumber);

  /** Destructor */
  METRAFLOW_DECL ~DataflowPreparedPlan();

  /** Execute the plan */
  METRAFLOW_DECL boost::int32_t Execute(); 
};

#endif
