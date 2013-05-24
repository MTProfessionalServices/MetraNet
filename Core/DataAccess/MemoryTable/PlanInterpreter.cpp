#pragma warning(disable:4005)
#include "winsock2.h" 
#include "windows.h" 
#import <RCD.tlb>

#include "mpi.h"
#include <iostream>
#include <fstream>

#include <boost/archive/binary_iarchive.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/program_options.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/iostreams/device/array.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>
#include <boost/tokenizer.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/lexical_cast.hpp>

#include "Timer.h"
#include "ArgEnvironment.h"
#include "PlanInterpreter.h"
//#include "DatabaseInsert.h"
//#include "RunTimeExpression.h"
#include "HashAggregate.h"
#include "RunTimeHashAggregate.h"
#include "DatabaseSelect.h"
#include "RunTimeDatabaseSelect.h"
//#include "ExternalSort.h"
//#include "DataFile.h"
#include "DataflowException.h"
#include "TypeCheckException.h"
#include "Reporter.h"
//#include "LongestPrefixMatch.h"
//#include "IdGeneratorOperator.h"
//#include "Normalization.h"
#include "MessageDigest.h"
#include "SortRunningTotal.h"
#include "ScriptInterpreter.h"
#include "DataflowLexer.hpp"
#include "DataflowParser.hpp"
#include "DataflowTreeParser.hpp"
#include "DataflowTreeGenerator.hpp"
#include "AST.hpp"
#include "ASTFactory.hpp"
#include "TokenStreamHiddenTokenFilter.hpp"
#include "CommonHiddenStreamToken.hpp"
#include "WorkflowHistorian.h"
#include <OdbcConnection.h>

#include "RuntimeValueCast.h"

#include <sstream>

//#include <boost/serialization/export.hpp>

//BOOST_CLASS_EXPORT(RunTimeExpression);
//BOOST_CLASS_EXPORT(RunTimeExpressionGenerator);
//BOOST_CLASS_EXPORT(RunTimeGenerator);
//BOOST_CLASS_EXPORT(CapacityChangeHandler);
//BOOST_CLASS_EXPORT(Reactor);
//BOOST_CLASS_EXPORT(BipartiteChannelSpec2);
//BOOST_CLASS_EXPORT(StraightLineChannelSpec2);
//BOOST_CLASS_EXPORT(ParallelPlan);
//BOOST_CLASS_EXPORT(RunTimeOperator);
//BOOST_CLASS_EXPORT(RunTimeDataFileScan<PagedParseBuffer<mapped_file> >);
//BOOST_CLASS_EXPORT(RunTimeDataFileScan<StdioReadBuffer<StdioFile> >);
//BOOST_CLASS_EXPORT(RunTimeDataFileScan<StdioReadBuffer<Win32File> >);
//BOOST_CLASS_EXPORT(RunTimeDataFileExport<StdioWriteBuffer<StdioFile> >);
//BOOST_CLASS_EXPORT(RunTimeDataFileDelete);
//BOOST_CLASS_EXPORT(RunTimeDataFileRename);
//BOOST_CLASS_EXPORT(RunTimeDatabaseInsert<COdbcPreparedBcpStatement>);
//BOOST_CLASS_EXPORT(RunTimeDatabaseInsert<COdbcPreparedArrayStatement>);
//BOOST_CLASS_EXPORT(RunTimeTransactionalInstall);
//BOOST_CLASS_EXPORT(RunTimeTransactionalInstall2);
//BOOST_CLASS_EXPORT(RunTimeExternalSort);
//BOOST_CLASS_EXPORT(RunTimeRecordImporter<PagedParseBuffer<mapped_file> >);
//BOOST_CLASS_EXPORT(RunTimeRecordImporter<StdioReadBuffer<StdioFile> >);
//BOOST_CLASS_EXPORT(RunTimeRecordImporter<StdioReadBuffer<ZLIBFile> >);
//BOOST_CLASS_EXPORT(RunTimeRecordExporter<StdioWriteBuffer<StdioFile> >);
//BOOST_CLASS_EXPORT(RunTimeRecordExporter<StdioWriteBuffer<ZLIBFile> >);
//BOOST_CLASS_EXPORT(RunTimeSortKey);
//BOOST_CLASS_EXPORT(RunTimeSortMergeCollector);
//BOOST_CLASS_EXPORT(RunTimeLongestPrefixMatch);
//BOOST_CLASS_EXPORT(RunTimeIdGenerator);
//BOOST_CLASS_EXPORT(RunTimeSortNest);
//BOOST_CLASS_EXPORT(RunTimeUnnest);
//BOOST_CLASS_EXPORT(DesignTimeTaxwareBinding);
//BOOST_CLASS_EXPORT(RunTimeTaxware);
//BOOST_CLASS_EXPORT(RunTimeMD5Hash);
//BOOST_CLASS_EXPORT(RunTimeSortRunningAggregate);

// TODO: Hook up ICU code page dictionary.
boost::int32_t LookupCodepage(const std::string & codepage)
{
  if (boost::to_upper_copy<std::string>(codepage) == "UTF-8")
    return CP_UTF8;
  else
    return -1;
}

class AutoMPI
{
private:
  int mErrCode;
public:
  AutoMPI(int * argc, char ** argv[])
    :
    mErrCode(0)
  {
    int threading = 0;
    int result = MPI_Init_thread(argc, argv, MPI_THREAD_MULTIPLE, &threading);
    if (threading != MPI_THREAD_MULTIPLE)
    {
      MPI_Finalize();
      throw std::runtime_error("MPI not multi-threaded");
  }
  }
  ~AutoMPI()
  {
    if (mErrCode)
    {
      MPI_Abort(MPI_COMM_WORLD, mErrCode);
    }
    else
    {
      // Can we call finalize now?
      MPI_Finalize();
    }
  }

  void SetErrorCode(int errorCode)
  {
    mErrCode = errorCode;
  }
};

void MPIPlanInterpreter::Start(int argc, char * argv[])
{
  int myid, numprocs;

  AutoMPI mpi(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);

  if (myid == 0)
  {
    DesignTimePlan plan;
    plan.type_check();
    ParallelPlan pplan(numprocs, true);
    plan.code_generate(pplan);

    std::ostringstream oss(std::ios_base::binary | std::ios_base::out);
    boost::archive::binary_oarchive oa(oss);
    ParallelPlan * tmp = &pplan;
    oa << BOOST_SERIALIZATION_NVP(tmp); 
    for(boost::int32_t id = 1; id < pplan.GetNumDomains(); id++)
    {
      // create and open a character archive for output
      int ret = MPI_Send(const_cast<char *>(oss.str().c_str()), oss.str().size()+1, MPI_BYTE, id, 0, MPI_COMM_WORLD);
    }
    boost::shared_ptr<ParallelDomain> mydomain = pplan.GetDomain(0);
    // Everyone execute their domain.
    mydomain->Start();
    mydomain = boost::shared_ptr<ParallelDomain>();
  }
  else
  {
    // Get the query domain from root.
    MPI_Status status;
    int ret = MPI_Probe(0, 0, MPI_COMM_WORLD, &status);
    int sz;
    ret = MPI_Get_count(&status, MPI_BYTE, &sz);
    char * buf = new char [sz];
    ret = MPI_Recv(buf, sz, MPI_BYTE, 0,0, MPI_COMM_WORLD, &status);
    boost::iostreams::stream<boost::iostreams::array_source> buffy(boost::iostreams::array_source(buf, sz));
    boost::archive::binary_iarchive ia(buffy);
//     std::istringstream iss(buf);
//     boost::archive::xml_iarchive ia (iss);
    ParallelPlan * pplan;
    ia >> BOOST_SERIALIZATION_NVP(pplan);
    // Everyone execute their domain.
    boost::shared_ptr<ParallelDomain> mydomain = pplan->GetDomain(myid);
    mydomain->Start();
    mydomain = boost::shared_ptr<ParallelDomain>();
    delete pplan;
  }
}

DataflowScriptInterpreter::DataflowScriptInterpreter(Reporter *reporter)
 : mCurrentStepName(Workflow::DefaultStepName),
   mReporter(reporter)
{
  mLogger = MetraFlowLoggerManager::GetLogger("DataflowScriptInterpreter");
  mHistorian = new WorkflowHistorianDb();
}

DataflowScriptInterpreter::DataflowScriptInterpreter()
{
  mReporter = &mDefaultReporter;
  mLogger = MetraFlowLoggerManager::GetLogger("DataflowScriptInterpreter");
  mHistorian = new WorkflowHistorianDb();
}

DataflowScriptInterpreter::~DataflowScriptInterpreter()
{
  if (mHistorian)
  {
    delete mHistorian;
  }

  for (std::map<std::wstring, DataflowSymbolTable *>::iterator 
       it = mMapOfSymbolTables.begin();
       it != mMapOfSymbolTables.end();
       it++)
  {
    delete it->second;
  }
}

bool DataflowScriptInterpreter::didParseErrorOccur(std::wstring &msg, 
                                                   int &lineNumber, 
                                                   int &colNumber)
{
  return mReporter->didErrorOccur(msg, lineNumber, colNumber);
}
 

int DataflowScriptInterpreter::createWorkflow(
                             std::wstring filename,
                             std::istream& script,
                             boost::int32_t encoding,
                             bool isAnnotation,
                             Workflow& workflow)
{
  // Parse the script into a workflow
  return parse(filename, script, encoding, true, isAnnotation, workflow);
}

int DataflowScriptInterpreter::parse(const std::wstring& filename,
                                     std::istream& script,
                                     boost::int32_t encoding,
                                     bool isVerifyAndTypeCheck,
                                     bool isAnnotation,
                                     Workflow& workflow)
{
  // Scan the script for basic tokens
  DataflowLexer lexer(script);
  lexer.setTokenObjectFactory(&antlr::CommonHiddenStreamToken::factory);
  lexer.setLog(mLogger);
  
  // Create the filter for the parser
  antlr::TokenStreamHiddenTokenFilter filter(lexer);
  filter.hide(DataflowParser::WS);
	filter.hide(DataflowParser::SL_COMMENT);
	filter.hide(DataflowParser::ML_COMMENT);
  
  // Set up the parser
  DataflowParser parser(filter);
  antlr::ASTFactory ast_factory("MyAST", MyAST::factory);
  parser.initializeASTFactory(ast_factory);
  parser.setASTFactory(&ast_factory);
  parser.setCompositeDictionary(&mCompositeDictionary);
  parser.setFilename(filename);
  parser.setInterpreter(this);
  parser.setWorkflow(&workflow);
  parser.setLog(mLogger);
  parser.setEncoding(encoding);
  parser.setArgEnvironment(ArgEnvironment::getActiveEnvironment());

  // Parse into the tokens and produce an abstract syntax tree (AST)
  try
  {    
    parser.program();
  } 
  catch (antlr::ANTLRException& antlrException) 
  {
    mLogger->logError(antlrException.toString());
    mReporter->reportException(antlrException);
    return 1;
  }
  catch (DataflowException& e)
  {
    mLogger->logError(e.getMessage());
    mReporter->reportException(e);
    return 1;
  }
  if (parser.getHasError())
  {
    mLogger->logError(parser.getErrorMessage());
    // Parser error message should be ASCII, so let's use
    // UTF8 code page.
    std::wstring wMsg;
    ::ASCIIToWide(wMsg, parser.getErrorMessage().c_str(), CP_UTF8);
    mReporter->reportError(wMsg);
    return 1;
  }
  // Parser may have updated the encoding (e.g. a BOM)
  encoding = parser.getEncoding();
  
  // Set up the analyzer
  DataflowTreeParser analyze;
  analyze.initializeASTFactory(ast_factory);
  analyze.setASTFactory(&ast_factory);
  analyze.setLog(mLogger);
  analyze.setSymbolTable(&mMapOfSymbolTables);
  analyze.setCompositeDictionary(&mCompositeDictionary);
  analyze.setFilename(filename);
  analyze.setEncoding(encoding);

  // Walk the parser produced AST tree and created
  // a higher-order AST
  try
  {
    analyze.program(parser.getAST());
  } 
  catch (antlr::ANTLRException& antlrException) 
  {
    mLogger->logError(antlrException.toString());
    mReporter->reportException(antlrException);
    return 1;
  }
  catch (DataflowException& e)
  {
    mLogger->logError(e.getMessage());
    mReporter->reportException(e);
    return 1;
  }
  catch (std::exception& e) 
  {
    mLogger->logError(e.what());
    mReporter->reportException(e);
    return 1;
  }
  catch (...) 
  {
    mLogger->logError("Caught unrecognized exception during generation");
    mReporter->reportException(L"analyzing");
    return 1;
  }
  if (analyze.getHasError())
  {
    std::cerr << "Parse error" << std::endl;
    return 1;
  }
  
  // Transform the AST into a design time plan, creating
  // the operators and channels.
  DataflowTreeGenerator generate;
  generate.setLog(mLogger);
  generate.setSymbolTable(&mMapOfSymbolTables);
  generate.setWorkflow(&workflow);
  generate.setCompositeDictionary(&mCompositeDictionary);
  generate.setFilename(filename);
  generate.setScriptInterpreter(this);
  generate.setEncoding(encoding);

  std::map<std::wstring, DesignTimePlan*>& plans=workflow.getDesignTimePlans();

  try
  {
    generate.program(analyze.getAST());

    if (isVerifyAndTypeCheck)
    {
      // Verify that all ports in the plan are connected
      // We are doing this prior to expanding composites for
      // simplier error reporting.
      for (std::map<std::wstring, DesignTimePlan*>::iterator 
          it = plans.begin(); it != plans.end(); it++)
      {
        DesignTimePlan* planPtr = it->second;
        mCurrentStepName = planPtr->getName();
        planPtr->verifyAllPortsConnected();
      }
    
      // Verify all composite definitions: that all the ports are 
      // connected within the definition.
      mCompositeDictionary.verifyAllPortsConnected();

      // Iterate through all the steps, expanding composites
      // and type checking.
      for (std::map<std::wstring, DesignTimePlan*>::iterator 
          it = plans.begin(); it != plans.end(); it++)
      {
        DesignTimePlan* planPtr = it->second;
        mCurrentStepName = planPtr->getName();

        // Replace composites with sub-graph definition.
        planPtr->expandComposites(mCompositeDictionary);

        // Type check the plan
        planPtr->type_check(isAnnotation);  
      }
    }
  }
  catch (antlr::ANTLRException& antlrException) 
  {
    mLogger->logError(antlrException.toString());
    mReporter->reportException(antlrException);
    return 1;
  }
  catch (TypeCheckException& e)
  {
    e.addLineNumbers(*this);
    mLogger->logError(e.getMessage());
    mReporter->reportException(e);
    return 1;
  }
  catch (DataflowException& e)
  {
    mLogger->logError(e.getMessage());
    mReporter->reportException(e);
    return 1;
  }
  catch (std::exception& e) 
  {
    mLogger->logError(e.what());
    mReporter->reportException(e);
    return 1;
  }
  catch (...) 
  {
    mLogger->logError("Caught unrecognized exception during verifying.");
    mReporter->reportException(L"verifying");
    return 1;
  }

  if (isAnnotation)
  {
      for (std::map<std::wstring, DesignTimePlan*>::iterator 
          it = plans.begin(); it != plans.end(); it++)
      {
        DesignTimePlan *planPtr = it->second;
        std::wstringstream str;
        planPtr->describeDatatypeFlow(str);
        std::string utf8Str;
        ::WideStringToUTF8(str.str(), utf8Str);
        std::cout << utf8Str;
      }
  }

  return 0;
}

bool DataflowScriptInterpreter::isFileIncludeInProgress(
                                    const std::wstring& filename) const
{
  std::map<std::wstring, bool>::const_iterator it;
  it = mIncludedFilenames.find(filename);
  if (it != mIncludedFilenames.end())
  {
    return (!(*it).second);
  }

  return false;
}

bool DataflowScriptInterpreter::isFileAlreadyIncluded(
                                    const std::wstring& filename) const
{
  std::map<std::wstring, bool>::const_iterator it;
  it = mIncludedFilenames.find(filename);
  if (it != mIncludedFilenames.end())
  {
    return ((*it).second);
  }

  return false;
}

bool DataflowScriptInterpreter::resolveIncludeFile(
                                     const std::wstring& fileBeingParsed,
                                     const std::wstring& fname, 
                                     std::wstring &outFullPath) const
{
  // Attempt 1
  // Try to resolve the include file locally (using the current
  // working directory).
  boost::filesystem::wpath fullPath = boost::filesystem::system_complete( 
                 boost::filesystem::wpath(fname, boost::filesystem::native));
  if (boost::filesystem::exists(fullPath))
  {
    outFullPath = fullPath.native_file_string();
    return true;
  }

  // Attempt 2
  // Try to find the file in the extension directories
  RCDLib::IMTRcdPtr rcd(MTPROGID_RCD);
  RCDLib::IMTRcdFileListPtr fileList = rcd->GetExtensionListWithPath();

  for(int i = 0; i < fileList->Count; i++)
  {
    _bstr_t extension = fileList->GetItem(i);
    std::wstring resolvedName = extension;
    resolvedName += L"\\config\\MetraFlow\\Composites\\" + fname;

    fullPath= boost::filesystem::system_complete( 
              boost::filesystem::wpath(resolvedName, boost::filesystem::native));

    if (boost::filesystem::exists(fullPath))
    {
      outFullPath = fullPath.native_file_string();
      return true;
    }
  }

  // Attempt 3
  // Try to find the file under config/MetraFlow
  std::wstring resolvedName = rcd->GetConfigDir();
  resolvedName += L"\\MetraFlow\\ProductCatalog\\Composites\\";
  resolvedName += fname;

  fullPath= boost::filesystem::system_complete( 
              boost::filesystem::wpath(resolvedName, boost::filesystem::native));

  if (boost::filesystem::exists(fullPath))
  {
    outFullPath = fullPath.native_file_string();
    return true;
  }

  // Attempt 4
  // Try to find the file under the same directory as the
  // file being parsed.
  boost::filesystem::wpath scriptPath = boost::filesystem::system_complete( 
                 boost::filesystem::wpath(fileBeingParsed, boost::filesystem::native));

  std::wstring leaf = scriptPath.leaf();

  if (leaf.length() < fileBeingParsed.length())
  {
    std::wstring finalName = fileBeingParsed.substr(0, fileBeingParsed.length() - 
                                                       leaf.length());
    finalName += fname;

    fullPath= boost::filesystem::system_complete( 
                boost::filesystem::wpath(finalName, boost::filesystem::native));
  
    if (boost::filesystem::exists(fullPath))
    {
      outFullPath = fullPath.native_file_string();
      return true;
    }
  }

  return false;
}

int DataflowScriptInterpreter::includeComposite(const std::wstring& filename,
                                                std::istream& script,
                                                boost::int32_t encoding)
{
  mIncludedFilenames[filename] = false;

  // Notice that we throw this workflow away.
  // We are really just using the side-effect of parsing that adds
  // composites to the composite dictionary stored under the interpreter.
  std::map<std::wstring, std::vector<boost::int32_t> > emptyList;
  Workflow workflow(0, false, emptyList, *mReporter, *mHistorian, L"",
                    false, false, L"", true); 

  int result = parse(filename, script, encoding, false, false, workflow);

  mIncludedFilenames[filename] = true;

  return result;
}

int DataflowScriptInterpreter::codeGenerateComposite(const std::wstring& compositeName,
                                                     const std::wstring& script,
                                                     const std::wstring& compositeInstanceName)
{
  std::string utf8Script;
  ::WideStringToUTF8(script, utf8Script);
  std::stringstream s(utf8Script);

  // Notice that we throw this workflow away.
  // We are really just using the side-effect of parsing that adds
  // composites to the composite dictionary stored under the interpreter.
  std::map<std::wstring, std::vector<boost::int32_t> > emptyList;
  Workflow workflow(0, false, emptyList, *mReporter, *mHistorian, L"",
                    false, false, L"", true); 

  int result = parse(compositeInstanceName, s, CP_UTF8, false, false, workflow);

  return result;
}

int DataflowScriptInterpreter::Run(int argc, char * argv[])
{
  boost::shared_ptr<AutoMPI> autoMPI;
  int myrank=0;
  int numprocs=0;
  bool isNewTrackingRun = false;
  bool isTypeCheckOnly = false;
  bool isRetry = false;
  std::wstring trackingID = L"";
  std::wstring retryScriptName;
  boost::filesystem::wpath full_path(boost::filesystem::initial_path<boost::filesystem::wpath>());
  int ret = 0;

  // Singleton initialization.
  NameIDProxy nameID;

  if (NULL != getenv("PMI_KVS"))
  {
    // Running under MPI.
    autoMPI = boost::shared_ptr<AutoMPI>(new AutoMPI(&argc,&argv));
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
  }

  // Default for input file encoding is determined by locale of the system.
  // We support using UTF-8 as well.
  boost::int32_t encoding = CP_ACP;

  // If I am the master
  if (myrank == 0)
  {
    // Specify the command line arguments
    boost::program_options::options_description desc("Allowed options");
    desc.add_options()
      ("help", "produce help message")

      ("arg",
          boost::program_options::value< std::vector<std::string> >(),
          "composite argument values. Format <argname>=<argvalue>")

      ("partitions", 
          boost::program_options::value<boost::int32_t>()->default_value(1), 
          "number of partitions")

      ("trackingNew", 
          boost::program_options::value< std::string >(), 
          "track the execution of this script using this unique tracking ID. "
          "This option is used the first time the script is run.  "
          "--trackingRetry should be used for re-running of the script due "
          "to errors. ")

      ("trackingList", "list tracking IDs for the given script")

      ("trackingReport",
          boost::program_options::value< std::string >(), 
          "tracking ID of script to produce report for")

      ("trackingDelete",
        boost::program_options::value< std::string >(), 
        "date in format YYYY-MMM-DD. Deletes all tracking info older than this")

      ("trackingFile", "indicates that run tracking should use file storage "
                       "rather than database store")

      ("trackingRetry",
          boost::program_options::value< std::string >(), 
          "tracking ID of script to re-run")

      ("typecheck", "perform type checking")

      ("input-file", 
          boost::program_options::value< std::string >(), "input file")

      ("partition-list", 
          boost::program_options::value< std::vector<std::string> >(), 
          "partition constraint definition")

      ("encoding", 
          boost::program_options::value< std::string >(), 
          "input file character encoding")
      ;

    boost::program_options::positional_options_description p;
    p.add("input-file", -1);

    // Parse the command line options
    boost::program_options::variables_map vm;
    boost::program_options::store(
                boost::program_options::command_line_parser(argc, argv).
                  options(desc).positional(p).run(), vm);
    boost::program_options::notify(vm);

    // Switch: encoding
    if (0 < vm.count("encoding"))
    {
      encoding = LookupCodepage(vm["encoding"].as<std::string>());
      if (-1 == encoding)
      {
        std::cerr << "\nInvalid code page: UTF-8 and default locale code page are supported" << std::endl;
          Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), numprocs>0);
          return 1;
      }
    }

    // Switch: tracking
    isNewTrackingRun = (vm.count("trackingNew") > 0);
    if (isNewTrackingRun)
    {
      ::ASCIIToWide(trackingID, vm["trackingNew"].as<std::string>());
    }

    // Switch: trackingFile
    if (vm.count("trackingFile") > 0)
    {
      if (mHistorian)
      {
        delete mHistorian;
      }
      mHistorian = new WorkflowHistorianFile();
    }

    // Switch: trackingList
    if (vm.count("trackingList") > 0 &&  vm.count("input-file") > 0)
    {
      std::wstring wInputFile;
      ::ASCIIToWide(wInputFile, vm["input-file"].as<std::string>());
      full_path= boost::filesystem::system_complete<boost::filesystem::wpath>( 
                   boost::filesystem::wpath(wInputFile,
                                           boost::filesystem::native ) );
      std::string localeHistory;
      ::WideStringToMultiByte(mHistorian->getBriefHistoryAsString(
                                           full_path.native_file_string()), 
                              localeHistory, CP_ACP);
      std::cout << localeHistory;
      std::cout << std::endl;
      Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
            numprocs>0);
      return 0;
    }

    // Switch: trackingReport
    if (vm.count("trackingReport") > 0)
    {
      std::wstring trackingReport;
      ::ASCIIToWide(trackingReport, vm["trackingReport"].as<std::string>());
      std::string localeHistory;
      ::WideStringToMultiByte(mHistorian->getDetailedHistoryAsString(trackingReport),
                              localeHistory, CP_ACP);
      std::cout << localeHistory;
      std::cout << std::endl;
      Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
            numprocs>0);
      return 0;
    }

    // Switch: trackingDelete
    if (vm.count("trackingDelete") > 0)
    {
      string givenDate = vm["trackingDelete"].as<std::string>();
      boost::gregorian::date d(boost::gregorian::from_string(givenDate));
      tm d_tm = to_tm(d);
      time_t deleteTime = mktime(&d_tm);

      mHistorian->discardHistories(deleteTime);
      Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
            numprocs>0);
      return 0;
    }

    // Switch: retry
    isRetry = (vm.count("trackingRetry") > 0);
    if (isRetry)
    {
      ::ASCIIToWide(trackingID, vm["trackingRetry"].as<std::string>());
      isNewTrackingRun = false;
      if (!mHistorian->getScriptName(trackingID, retryScriptName))
      {
        Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
              numprocs>0);
        return 1;
      }
    }
    
    // Switch: typeCheck
    isTypeCheckOnly = (vm.count("typecheck")>0);

    // Switch: arg
    ArgEnvironment *argEnvironment = ArgEnvironment::getActiveEnvironment();
    if (vm.count("arg"))
    {
      // Get the specified name/value pairs for args
      for(std::vector<std::string >::const_iterator 
          it = vm["arg"].as<std::vector<std::string > >().begin();
          it != vm["arg"].as<std::vector<std::string > >().end();
          ++it)
      {
        // TODO: What if someone needs to pass in an argument in something
        // other than default locale (e.g. UTF8)?
        std::wstring wArg;
        ::ASCIIToWide(wArg, *it);
        if (!argEnvironment->storeArg(wArg))
        {
          std::cout << "Improperly specified argument: " << *it << std::endl;
          std::cout << desc << std::endl;
          Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
                numprocs>0);
          return 1;
        }
      }
    }

    // Switch: partitions
    //
    // Set the instrinc variable for the number of partitions in the environment
    argEnvironment->storeIntrinsicArg(L"numPartitions", 
        numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>());

    // Switch: partition-list
    // 
    // Get all of the partition constraint definitions and make them available 
    // to the program.
    std::map<std::wstring, std::vector<boost::int32_t> > partitionConstraintDefinitions;
    if (vm.count("partition-list"))
    {
      for(std::vector<std::string >::const_iterator it = vm["partition-list"].as<std::vector<std::string > >().begin();
          it != vm["partition-list"].as<std::vector<std::string > >().end();
          ++it)
      {
        std::string tmp = *it;
        std::size_t opening = tmp.find_first_of("[");
        std::size_t closing = tmp.find_first_of("]");
        std::wstring name;
        ::ASCIIToWide(name, tmp.substr(0, opening));
        partitionConstraintDefinitions[name] = std::vector<boost::int32_t> ();
        std::string partitionList = tmp.substr(opening+1, closing-opening-1);
        boost::tokenizer<boost::escaped_list_separator<char> > tok(partitionList);
        for(boost::tokenizer<boost::escaped_list_separator<char> >::iterator beg=tok.begin(); beg!=tok.end();++beg)
        {
          partitionConstraintDefinitions[name].push_back(boost::lexical_cast<boost::int32_t>(*beg));
        } 
      }
    }

    // Switch: help
    if (vm.count("help") > 0)
    {
      std::cout << desc << std::endl;
      Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
            numprocs>0);
      return 1;
    }

    // Get the script file name;
    std::wstring scriptName = L"";
    if (isRetry)
    {
      scriptName = retryScriptName;
    }
    else
    {
      if (0==vm.count("input-file"))
      {
        std::cout << "A MetraFlow script must be specified." << std::endl;
        std::cout << desc << std::endl;
        Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
              numprocs>0);
        return 1;
      }
      ::ASCIIToWide(scriptName, vm["input-file"].as<std::string>());
    }

    Timer t;
    {
      ScopeTimer s(&t);

      boost::filesystem::ifstream f;

      if (scriptName == L"-")
      {
        ret = Run(std::cin, 
                  encoding,
                  numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(),
                  numprocs>0, 
                  partitionConstraintDefinitions, 
                  isTypeCheckOnly,
                  false,
                  false,
                  L"");

        autoMPI = boost::shared_ptr<AutoMPI>();
      }
      else
      {
        try
        {
          full_path= boost::filesystem::system_complete( 
            boost::filesystem::wpath(scriptName,
                                     boost::filesystem::native ) );
          if ( !boost::filesystem::exists( full_path ) )
          {
            std::string localeFile;
            ::WideStringToMultiByte(full_path.native_file_string(), localeFile, CP_ACP);
            std::cerr << "\nFile not found: " << localeFile.c_str()
                      << std::endl;
            Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), 
                  numprocs>0);
            return 1;
          }

          f.open(full_path);      

          // Log script
          std::string line;
          while (!f.eof())
          {
            getline(f,line);
            mLogger->logDebug(line);
          }
          f.clear();
          f.seekg(0, ios::beg);
        }
        catch(boost::filesystem::wfilesystem_error& fe)
        {
          std::string localeFile;
          ::WideStringToMultiByte(fe.path1().native_file_string(), localeFile, CP_ACP);
          std::cerr << "\nError reading script input file \"" << localeFile.c_str() << "\"; " << fe.what() << std::endl;
          Abort(numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(), numprocs>0);
          return 1;
        }
      }

      // Run
      ret = Run(f, 
                encoding,
                numprocs>0 ? numprocs : vm["partitions"].as<boost::int32_t>(),
                numprocs>0,
                partitionConstraintDefinitions, 
                isTypeCheckOnly, 
                isNewTrackingRun,
                isRetry,
                trackingID,
                full_path.native_file_string());

      autoMPI = boost::shared_ptr<AutoMPI>();
    }

    if (!isTypeCheckOnly)
    {
      std::cout << "Execution Time: " << t.GetMilliseconds()/60000LL << ":";
      std::cout.width(2);
      std::cout.fill('0');
      std::cout << (t.GetMilliseconds() % 60000LL)/1000LL;
      std::cout.width(1);
      std::cout << ".";
      std::cout.width(3);
      std::cout.fill('0');
      std::cout << ((t.GetMilliseconds() % 60000LL) % 1000LL)  << std::endl;
    }
  }
  else
  {
    while (true)
    {
      // I am a slave; get my query plan from the rank 0 process and execute it.
      // Block waiting for a message
      MPI_Status status;
      int ret = MPI_Probe(0, 0, MPI_COMM_WORLD, &status);
      int sz;
      ret = MPI_Get_count(&status, MPI_BYTE, &sz);
      char * buf = new char [sz];
      ret = MPI_Recv(buf, sz, MPI_BYTE, 0,0, MPI_COMM_WORLD, &status);

      // Check for signal that we are no longer needed. All plans executed.
      if (sz == 1 && buf[0] == 0x01) 
      {
        delete [] buf;
        return 0;
      }

      // Check for signal that we are no longer needed. 
      // This happens if the master had a problem compiling the query.
      if (sz == 1 && buf[0] == 0x00) 
      {
        delete [] buf;
        return 1;
      }

      // We must have received a plan.
      ParallelPlan * pplan(NULL);
      try
      {
#if 0
       {
         std::ofstream ofs("c:\\mainline\\receiver.bin", 
                            std::ios_base::binary | std::ios_base::out);
         ofs << buf;
       }
       std::istringstream iss(buf);
       boost::archive::xml_iarchive ia (iss);
#endif
        boost::iostreams::stream<boost::iostreams::array_source> 
                              buffy(boost::iostreams::array_source(buf, sz));
        boost::archive::binary_iarchive ia(buffy);
        ia >> BOOST_SERIALIZATION_NVP(pplan);
        boost::shared_ptr<ParallelDomain> mydomain = pplan->GetDomain(myrank);
        mydomain->Start();
        mydomain = boost::shared_ptr<ParallelDomain>();
        delete pplan;

        // Block waiting for all MPI processes/threads reach this point
        ret = MPI_Barrier(MPI_COMM_WORLD);
      }
      catch(std::exception& e)
      {
        MetraFlowLoggerPtr logger = 
              MetraFlowLoggerManager::GetLogger("[DataflowScriptInterpreter]");
        logger->logError(e.what());
        if (autoMPI.get()) autoMPI->SetErrorCode(-1);
        delete pplan;
        return 1;
      }
    }
  }

  return ret;
}

void DataflowScriptInterpreter::Abort(boost::int32_t numPartitions, 
                                      bool isCluster)
{
  boost::uint8_t buf(0);
  if (isCluster)
  {
    for(boost::int32_t i=1; i<numPartitions; i++)
    {
      MPI_Send(&buf, 1, MPI_BYTE, i, 0, MPI_COMM_WORLD);
    }
  }
}

void DataflowScriptInterpreter::tellSlavesWeAreDone(
                                      boost::int32_t numPartitions, 
                                      bool isCluster)
{
  boost::uint8_t buf(1);
  if (isCluster)
  {
    for(boost::int32_t i=1; i<numPartitions; i++)
    {
      MPI_Send(&buf, 1, MPI_BYTE, i, 0, MPI_COMM_WORLD);
    }
  }
}

int DataflowScriptInterpreter::Run(
      std::istream& script,
      boost::int32_t encoding,
      boost::int32_t numPartitions, 
      bool isCluster,
      const std::map<std::wstring, std::vector<boost::int32_t> > 
                                                    & partitionListDefinitions,
      bool isTypeCheckOnly,
      bool isNewTrackingRun,
      bool isRetry,
      const std::wstring &trackingID,
      const std::wstring &scriptName)
{
  // The OdbcEnvironment is a reference counted singleton.
  // We are going to make sure we hold on to one instance of
  // the environment for the life of the plan execution.
  // By doing this, ODBC pooling works.  Without this, 
  // the environment is destroyed when our first odbc 
  // connection is destroyed.
  COdbcEnvironment::GetInstance();

  // Create the workflow (holds design time plans) 
  Workflow workflow(numPartitions, isCluster, partitionListDefinitions, 
                    *mReporter, *mHistorian, scriptName, isNewTrackingRun, 
                    isRetry, trackingID, false);

  if (createWorkflow(scriptName, script, encoding, isTypeCheckOnly, workflow) != 0)
  {
    Abort(numPartitions, isCluster);
    COdbcEnvironment::ReleaseInstance();
    return 1;
  }

  // No further processing needed if annotating
  if (isTypeCheckOnly)
  {
    COdbcEnvironment::ReleaseInstance();
    return 0;
  }

  // Run the workflow.
  int errorOccurred = workflow.run();

  if (errorOccurred)
  {
    // Tell the slaves running the other partitions to abort.
    Abort(numPartitions, isCluster);
    COdbcEnvironment::ReleaseInstance();
    return 1;
  }
  else
  {
    tellSlavesWeAreDone(numPartitions, isCluster);
  }

  COdbcEnvironment::ReleaseInstance();
  return 0;
}

int DataflowScriptInterpreter::getLineNumber(const DesignTimeOperator &op)
{
  // Find map of symbols for the step.
  if (mMapOfSymbolTables.find(mCurrentStepName) == mMapOfSymbolTables.end())
  {
    return -1;
  }

  // Find the operator
  DataflowSymbolTable *symbolTable = mMapOfSymbolTables[mCurrentStepName];
  if (symbolTable->find(op.GetName()) != symbolTable->end())
  {
    return ((*symbolTable)[op.GetName()].LineNumber);
  }

  // Failed to find it.
  return -1;
}

int DataflowScriptInterpreter::getColumnNumber(
                                  const DesignTimeOperator &op)
{
  // Find map of symbols for the step.
  if (mMapOfSymbolTables.find(mCurrentStepName) == mMapOfSymbolTables.end())
  {
    return -1;
  }

  // Find the operator
  DataflowSymbolTable *symbolTable = mMapOfSymbolTables[mCurrentStepName];
  if (symbolTable->find(op.GetName()) != symbolTable->end())
  {
    return ((*symbolTable)[op.GetName()].ColumnNumber);
  }

  // Failed to find it.
  return -1;
}

DataflowPreparedPlan::DataflowPreparedPlan(std::istream& script,
                                           boost::int32_t encoding, 
                                           boost::int32_t numPartitions, 
                                           bool isCluster)
  :
  mNumPartitions(numPartitions),
  mIsCluster(isCluster)
{
  // The OdbcEnvironment is a reference counted singleton.
  // We are going to make sure we hold on to one instance of
  // the environment for the life of this DataflowPreparedPlan
  // instance.  By doing this, ODBC pooling works.  
  // Without this, the environment is destroyed when our
  // first odbc connection is destroyed.
  COdbcEnvironment::GetInstance();

  mHistorian = new WorkflowHistorianDb();
  mWorkflow = new Workflow(numPartitions, isCluster, 
                           mPartitionListDefns, mReporter, *mHistorian, L"",
                           false, false, L"", false);

  DataflowScriptInterpreter interpreter;

  if (interpreter.createWorkflow(L"", script, encoding, false, *mWorkflow) != 0)
  {
    Abort();
    throw std::runtime_error("Parse error");
  }
}

DataflowPreparedPlan::DataflowPreparedPlan(std::istream& script,
                                           boost::int32_t encoding, 
                                           boost::int32_t numPartitions, 
                                           bool isCluster,
                                           bool &didErrorOccur,
                                           std::wstring &errMsg, 
                                           int &lineNumber, 
                                           int &colNumber)
  :
  mNumPartitions(numPartitions),
  mIsCluster(isCluster)
{
  // The OdbcEnvironment is a reference counted singleton.
  // We are going to make sure we hold on to one instance of
  // the environment for the life of this DataflowPreparedPlan
  // instance.  By doing this, ODBC pooling works.  
  // Without this, the environment is destroyed when our
  // first odbc connection is destroyed.
  COdbcEnvironment::GetInstance();

  didErrorOccur = false;
  errMsg = L"";
  lineNumber = 0;
  colNumber = 0;
  mHistorian = new WorkflowHistorianDb();
  mWorkflow = new Workflow(numPartitions, isCluster, 
                           mPartitionListDefns, mReporter, *mHistorian, L"",
                           false, false, L"", false);

  DataflowScriptInterpreter interpreter;

  if (interpreter.createWorkflow(L"", script, encoding, false, *mWorkflow) != 0)
  {
    Abort();
    didErrorOccur = true;
    interpreter.didParseErrorOccur(errMsg, lineNumber, colNumber);
  }
}

DataflowPreparedPlan::~DataflowPreparedPlan()
{
  delete mHistorian;
  delete mWorkflow;

  // Free the odbc environment we obtained in the constructor.
  COdbcEnvironment::ReleaseInstance();
}

void DataflowPreparedPlan::Abort()
{
  boost::uint8_t buf(0);
  if (mIsCluster)
  {
    for(boost::int32_t i=1; i<mNumPartitions; i++)
    {
      MPI_Send(&buf, 1, MPI_BYTE, i, 0, MPI_COMM_WORLD);
    }
  }
}

boost::int32_t DataflowPreparedPlan::Execute()
{
  // Run the workflow.
  int errorOccurred = mWorkflow->run();

  // If an error occurred, stop all other running partitions.
  if (errorOccurred)
  {
    Abort();
    return 1;
  }
  else
  {
    DataflowScriptInterpreter::tellSlavesWeAreDone(mNumPartitions, mIsCluster);
  }

  return 0;
}
