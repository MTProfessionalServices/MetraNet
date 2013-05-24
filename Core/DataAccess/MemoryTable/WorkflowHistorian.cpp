#include <iostream>
#include <sstream>
#include <cstdio>
#include <vector>

#include <boost/filesystem/operations.hpp>
#include <boost/format.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>


#include "metralite.h"
#include "mttime.h"
#include "formatdbvalue.h"
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcColumnMetadata.h>

#include "WorkflowHistorian.h"
#include "ArgEnvironment.h"

std::wstring EncodeString(const std::wstring& toEncode)
{
  return boost::algorithm::replace_all_copy(toEncode, L"'", L"''");
}

WorkflowHistorian::WorkflowHistorian()
  : mIsTracking(false)
{
}

WorkflowHistorian::~WorkflowHistorian()
{
}

std::wstring WorkflowHistorian::getBriefHistoryAsString(
                                              const std::wstring &scriptName)
{
  std::wstringstream sstream;

  vector <RunHistory> history = getBriefHistory(scriptName);
  for (unsigned int j=0; j<history.size(); j++)
  {
    sstream << L"Tracking ID: " << history[j].trackingID 
            << L" Start: " << history[j].startTime;
    
    if (history[j].isCompleted)
    {
      sstream << L" Run: completed\n";
    }
    else
    {
      sstream << L" Run: incomplete\n";
    }
  }

  return sstream.str();
}

std::wstring WorkflowHistorian::getDetailedHistoryAsString(
                                              const TrackingID &trackingID)
{
  std::wstringstream sstream;

  RunHistory runHistory;
  vector <InstructionHistory> iHistory;
  if (!getDetailedHistory(trackingID, runHistory, iHistory))
  {
    return L"";
  }

  for (unsigned int j=0; j<iHistory.size(); j++)
  {
    sstream << j+1 << L".";
    sstream << L" Start: " << iHistory[j].startTime;
    sstream << L" End: "    << iHistory[j].endTime;
    sstream << L"#" << iHistory[j].instructionNumber;
    sstream << L" Description: " << iHistory[j].description << L"\n";
  }

  sstream << L"\n";

  if (runHistory.isCompleted)
  {
    sstream << L"Script run completed.\n";
  }
  else
  {
    sstream << L"Script run incomplete.\n";
  }

  return sstream.str();
}


bool WorkflowHistorian::getLastInstruction(const TrackingID &trackingID,
                                           int &nInstructionStarts,
                                           unsigned int &lastNumber,
                                           ArgEnvironment &lastEnv,
                                           bool &wasLastInstrCompleted,
                                           bool &wasScriptCompleted)
{
  RunHistory runHistory;
  vector <InstructionHistory> iHistory;
  if (!getDetailedHistory(trackingID, runHistory, iHistory))
  {
    return false;
  }

  // There should at least be the history of starting one instruction
  nInstructionStarts = iHistory.size();
  if (nInstructionStarts < 1)
  {
    return false;
  }

  wasScriptCompleted = runHistory.isCompleted;
  lastNumber = 0;
  wasLastInstrCompleted = false;

  unsigned int lastIndex = iHistory.size() - 1;

  lastNumber = iHistory[lastIndex].instructionNumber;
  lastEnv = iHistory[lastIndex].environment;
  wasLastInstrCompleted = iHistory[lastIndex].wasCompleted;

  return true;
}

WorkflowHistorianFile::WorkflowHistorianFile()
  : mOutputFile(NULL),
    mIsInstructionInProgress(false)
{
  mLogger = MetraFlowLoggerManager::GetLogger("WorkflowHistorianFile");

  // Set the location for where we store tracking information.
  mStorageDir.assign(L"C:\\Temp");
  if (_wgetenv(L"TEMP") != NULL)
  {
    mStorageDir.assign(_wgetenv(L"TEMP"));
  }
  else if (_wgetenv(L"TMP") != NULL)
  {
    mStorageDir.assign(_wgetenv(L"TMP"));
  }

  mStorageDir.append(L"\\");
}

WorkflowHistorianFile::~WorkflowHistorianFile()
{
  if (mOutputFile && mOutputFile->is_open())
  {
    mOutputFile->close();
    delete mOutputFile;
  }
}

std::wstring WorkflowHistorianFile::formFilename(const std::wstring& scriptName,
                                                TrackingID id)
{
  std::wstring filename = mStorageDir;
  filename.append(L"trace.");
  filename.append(getFilenameRoot(scriptName));
  filename.append(L".");
  filename.append(id);
  return filename;
}

bool WorkflowHistorianFile::scriptStart(const std::wstring& scriptName,
                                        std::wstring& trackingID)
{
  // We don't expect this, but check.
  if (mOutputFile && mOutputFile->is_open())
  {
    mOutputFile->close();
    delete mOutputFile;
  }

  mStorageFile = formFilename(scriptName, trackingID);

  mOutputFile = new ofstream(mStorageFile.c_str());

  if (!mOutputFile->is_open())
  {
    mLogger->logError(L"Unable to open tracking file: " + mStorageFile);
    mLogger->logError(L"Tracking has been turned off.");
    return false;
  }

  time_t now = ::GetMTTime();
  std::string line;

  *mOutputFile << "0\n";  // Indicates script not complete
  ::WideStringToUTF8(scriptName, line);
  *mOutputFile << line << "\n";
  ::WideStringToUTF8(trackingID, line);
  *mOutputFile << line << "\n";
  ::WideStringToUTF8(toDateString(&now), line);
  *mOutputFile << line << "\n";

  mIsTracking = true;

  return true;
}

bool WorkflowHistorianFile::scriptRestart(const std::wstring& trackingID,
                                          unsigned int &lastInstruction)
{
  // We don't expect this, but check.
  if (mOutputFile && mOutputFile->is_open())
  {
    mOutputFile->close();
    delete mOutputFile;
  }

  // Given a trackingID, determine the scriptName
  std::wstring scriptName;
  if (!determineScriptName(trackingID, scriptName))
  {
    return false;
  }
  
  // Determine the last instruction from previous run
  bool wasLastInstrCompleted, wasScriptCompleted;
  ArgEnvironment lastEnv;
  int nInstructionStarts;
  if (!getLastInstruction(trackingID,
                          nInstructionStarts,
                          lastInstruction, 
                          lastEnv,
                          wasLastInstrCompleted,
                          wasScriptCompleted))
  {
    return false;
  }

  if (wasScriptCompleted)
  {
    std::cout << "In the previous run, this script completed execution." 
              << endl;
    return false;
  }

  // Open the file for writing, advancing to the end.
  mStorageFile = formFilename(scriptName, trackingID);
  mOutputFile = new ofstream(mStorageFile.c_str(),
                             ios::ate | ios::out | ios::in);

  if (!mOutputFile->is_open())
  {
    mLogger->logError(L"Unable to open tracking file: " + mStorageFile);
    mLogger->logError(L"Tracking has been turned off.");
    return false;
  }

  // Restore the environment that was in place prior to the 
  // last instruction starting execution.
  (*ArgEnvironment::getActiveEnvironment()) = lastEnv;

  mIsTracking = true;
  return true;
}

void WorkflowHistorianFile::scriptEnd(bool wasSuccessful)
{
  if (!mIsTracking)
  {
    return;
  }

  // If successful, we need to revise the the number at
  // the beginning of the file indicating complete.
  if (wasSuccessful)
  {
    mOutputFile->seekp(0);
    mOutputFile->write("1",1);
  }

  mOutputFile->close();
  delete mOutputFile;
}

bool  WorkflowHistorianFile::determineScriptName(const std::wstring& trackingID,
                                                 std::wstring& scriptName)
{
  std::wstring prefix(L"trace.");
  std::wstring suffix(L"." + trackingID);

  boost::filesystem::wdirectory_iterator it(mStorageDir);
  boost::filesystem::wdirectory_iterator itEnd;
  for (; it != itEnd; ++it)  
  {
    std::wstring fname = it->leaf();
    if (fname.length() <= prefix.length() + suffix.length())
    {
      continue;
    }

    std::wstring beginning = fname.substr(0, prefix.length());
    std::wstring ending = fname.substr(
                                    fname.length() - suffix.length(), 
                                    suffix.length());

    if (beginning.compare(prefix) != 0 || ending.compare(suffix) != 0)
    {
      continue;
    }

    scriptName = fname.substr(prefix.length(), 
                            fname.length() - prefix.length() - suffix.length());

    return true;
  } 
  
  return false;
}

void WorkflowHistorianFile::discardHistories(time_t olderThanDate)
{
  std::wstring match(L"trace.");
  boost::filesystem::wdirectory_iterator it(mStorageDir);
  boost::filesystem::wdirectory_iterator itEnd;
  for (; it != itEnd; ++it)  
  {
    std::wstring s = it->leaf().substr(0, match.length());
    if (match.compare(s) == 0)
    {
      if (last_write_time(*it) < olderThanDate)
      {
        remove(*it);
      }
    }
  } 
}

bool WorkflowHistorianFile::getDetailedHistory(
                                 TrackingID id,
                                 RunHistory &runHistory,
                                 vector <InstructionHistory> &instrHistory)
{
  bool isFileCorrupted = false;

  // Given a trackingID, determine the scriptName
  std::wstring scriptName;
  if (!determineScriptName(id, scriptName))
  {
    return false;
  }

  std::wstring filename = formFilename(scriptName, id);

  ifstream inFile(filename.c_str());
  if (!inFile.is_open())
  {
    mLogger->logError(L"Unable to read tracking file: " + filename);
    std::string localeFilename;
    ::WideStringToMultiByte(filename, localeFilename, CP_ACP);
    std::cout << "Unable to open tracking file: " << localeFilename << std::endl;
    return false;
  }

  std::string line;
  RunHistory history;

  // Read is was completed.
  getline(inFile, line);
  runHistory.isCompleted = toBool(line);

  // Read script name
  getline(inFile, line);
  ::ASCIIToWide(runHistory.scriptName, line.c_str(), -1, CP_UTF8);

  // Read the tracking ID
  getline(inFile, line);
  ::ASCIIToWide(runHistory.trackingID, line.c_str(), -1, CP_UTF8);

  // Read the starting time
  getline(inFile, line);
  ::ASCIIToWide(runHistory.startTime, line.c_str(), -1, CP_UTF8);
  if (inFile.eof()) 
  {
    isFileCorrupted = true;
  }

  InstructionHistory iHistory;
  bool sawInstruction = false;

  int seqNo = 0;

  while (!isFileCorrupted && inFile.is_open() && !inFile.eof())
  {
    seqNo++;
    iHistory.seqNumber = seqNo;

    iHistory.trackingID =  runHistory.trackingID;

    getline(inFile, line);
    if (inFile.eof()) break;
    iHistory.instructionNumber = toInt(line);
    
    getline(inFile, line);
    ::ASCIIToWide(iHistory.description, line.c_str(), -1, CP_UTF8);
    if (inFile.eof()) break;

    getline(inFile, line);
    time_t startTime = toLong(line);
    iHistory.startTime = toDateString(&startTime);

    std::string serializedEnv;
    getline(inFile, serializedEnv);
    if (inFile.eof()) 
    {
      isFileCorrupted = true;
      break;
    }
    iHistory.environment.deserialize(serializedEnv);

    // Read the ending time of the step. 0 indicates not completed.
    getline(inFile, line);

    if (inFile.eof())
    {
      // We've hit the end of file but the ending time of the
      // last step was never written out.  This means that
      // an uncaught error was thrown last execution.
      // We must repair the tracking file by adding an ending time of 0.
      iHistory.wasCompleted = false;
      iHistory.endTime = L"----------";

      inFile.close();
      ofstream outFile(filename.c_str(), ios::ate | ios::out | ios::in);
      if (!outFile.is_open())
      {
        mLogger->logError(L"Unable to append to tracking file: " + filename);
        std::string localeFilename;
        ::WideStringToMultiByte(filename, localeFilename, CP_ACP);
        std::cout << "Unable to apppend tracking file: "<< localeFilename <<std::endl;
        return false;
      }
      outFile << "0\n";
      outFile.close();
    }
    else
    {
      time_t endTime = toLong(line);
      iHistory.endTime = toDateString(&endTime);
      iHistory.wasCompleted = true;
    }

    instrHistory.push_back(iHistory);

    sawInstruction = true;
  }

  if (inFile.is_open())
  {
    inFile.close();
  }

  if (isFileCorrupted)
  {
    mLogger->logError(L"Corrupted tracking file: " + filename);
    std::string localeFilename;
    ::WideStringToMultiByte(filename, localeFilename, CP_ACP);
    std::cout << "The tracking file: "<< localeFilename <<" is corrupted. "<<std::endl;
    return false;
  }

  return true;
}

std::wstring WorkflowHistorianFile::getFilenameRoot(const std::wstring &filename)
{
  std::wstring result;

  size_t found;
  found = filename.find_last_of(L"/\\");
  if (found == string::npos)
  {
    result = filename;
  }
  else
  {
    result = filename.substr(found+1);
  }

  return result;
}

vector <RunHistory> WorkflowHistorianFile::getBriefHistory(
                                                const std::wstring& scriptName)
{
  vector <RunHistory> result;

  std::wstring match(L"trace." + getFilenameRoot(scriptName));
  boost::filesystem::wdirectory_iterator it(mStorageDir);
  boost::filesystem::wdirectory_iterator itEnd;
  for (; it != itEnd; ++it)  
  {
    std::wstring s = it->leaf().substr(0, match.length());
    if (match.compare(s) == 0)
    {
      std::wstring inFileName = mStorageDir + it->leaf();
      RunHistory runHistory;
      vector <InstructionHistory> instrHistory;
      if (getDetailedHistory(it->leaf().substr(match.length() + 1),
                             runHistory,
                             instrHistory))
      {
        result.push_back(runHistory);
      }
    }
  } 
  
  return result;
}

bool WorkflowHistorianFile::getScriptName(const std::wstring& id,
                                          std::wstring &scriptName)
{
  RunHistory runHistory;
  vector <InstructionHistory> instrHistory;

  if (getDetailedHistory(id, runHistory, instrHistory))
  {
    scriptName = runHistory.scriptName;
    return true;
  }

  return false;
}

void WorkflowHistorianFile::instructionStart(
                        unsigned int instructionNumber,
                        const std::wstring& description,
                        const ArgEnvironment& environment)
{
  if (!mIsTracking)
  {
    return;
  }

  mIsInstructionInProgress = true;
  time_t now = time(NULL);

  *mOutputFile << instructionNumber << "\n";
  std::string line;
  ::WideStringToUTF8(description, line);
  *mOutputFile << line << "\n";
  *mOutputFile << toString(now) << "\n";
  *mOutputFile << environment.serialize() << "\n";
}

void WorkflowHistorianFile::instructionEnd(bool wasSuccessful)
{
  if (!mIsTracking)
  {
    return;
  }

  if (!mIsInstructionInProgress)
  {
    mLogger->logError(L"Inappropriate call to instructionEnd.");
    return;
  }

  if (wasSuccessful)
  {
    time_t now = time(NULL);
    *mOutputFile << toString(now) << "\n";
  }
  else
  {
    *mOutputFile << "0\n";
  }

  mIsInstructionInProgress = false;
}

std::string WorkflowHistorianFile::toString(time_t t) 
{
  char timeAsStr[32];
  sprintf(timeAsStr, "%ld", t);

  string result(timeAsStr);
  return result;
}

bool WorkflowHistorianFile::toBool(const std::string& line)
{
  istringstream s(line);
  int i;
  if (!(s >> i))
  {
    i = 0;
  }

  return (i == 1);
}

int WorkflowHistorianFile::toInt(const std::string& line)
{
  istringstream s(line);
  int result;
  if (!(s >> result))
  {
    result = 0;
  }
  return result;
}

long WorkflowHistorianFile::toLong(const std::string& line)
{
  istringstream s(line);
  long result;
  if (!(s >> result))
  {
    result = 0;
  }
  return result;
}


std::wstring WorkflowHistorianFile::toDateString(time_t *t)
{
  if (*t <= 0)
  {
    return L"------------------------";
  }

  std::wstring result(_wctime(t));
  if (result.length() > 1)
  {
    result = result.substr(0, result.length() - 1);
  }
  return result;
}

WorkflowHistorianDb::WorkflowHistorianDb()
  : mConnection(NULL),
    mIsInstructionInProgress(false),
    mTrackingID(L""),
    mSequenceNumber(0)
{
  mLogger = MetraFlowLoggerManager::GetLogger("WorkflowHistorianDb");
}


WorkflowHistorianDb::~WorkflowHistorianDb()
{
  if (mConnection != NULL)
  {
    delete mConnection;
  }
}

bool WorkflowHistorianDb::scriptStart(const std::wstring& scriptName,
                                      std::wstring& trackingID)
{
  if (!openDatabaseConnection())
  {
    mIsTracking = false;
    return false;
  }

  mTrackingID = trackingID;

  // Execute
  try
  {
    boost::shared_ptr<COdbcPreparedArrayStatement> statement(mConnection->PrepareInsertStatement("t_mf_tracking_scripts"));
    statement->SetWideString(1, trackingID);
    statement->SetWideString(2, scriptName);
    DATE now = (DATE) ::GetMTOLETime();
    statement->SetDatetime(3, &now);
    statement->SetInteger(4, 0);
    statement->AddBatch();
    statement->ExecuteBatch();
  }
  catch(...)
  {
    mLogger->logError(L"Tracking has been turned off. "
                      L"An error occurred inserting into t_mf_tracking_scripts");
    mIsTracking = false;
    return false;
  }

  mIsTracking = true;
  return true;
}

bool WorkflowHistorianDb::scriptRestart(const std::wstring& trackingID,
                                          unsigned int &lastInstruction)
{
  if (!openDatabaseConnection())
  {
    mIsTracking = false;
    return false;
  }

  mIsTracking = true;
  mTrackingID = trackingID;

  // Determine the last instruction from previous run
  bool wasLastInstrCompleted, wasScriptCompleted;
  ArgEnvironment lastEnv;
  int nInstructionStarts;
  if (!getLastInstruction(trackingID,
                          nInstructionStarts,
                          lastInstruction, 
                          lastEnv,
                          wasLastInstrCompleted,
                          wasScriptCompleted))
  {
    return false;
  }

  mSequenceNumber = nInstructionStarts;

  if (wasScriptCompleted)
  {
    std::cout << "In the previous run, this script completed execution." 
              << endl;
    return false;
  }

  // Restore the environment that was in place prior to the 
  // last instruction starting execution.
  (*ArgEnvironment::getActiveEnvironment()) = lastEnv;

  return true;
}

void WorkflowHistorianDb::scriptEnd(bool wasSuccessful)
{
  if (!mIsTracking)
  {
    return;
  }

  boost::wformat updateStmt(
      L"UPDATE t_mf_tracking_scripts "
      L"SET was_completed=1 "
      L"WHERE id_tracking=N'%1%'");

  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  statement->ExecuteUpdateW((updateStmt % EncodeString(mTrackingID)).str());
}

void WorkflowHistorianDb::deleteRun(const TrackingID &trackingID)
{
    // Open database connection
  if (!openDatabaseConnection())
  {
    return;
  }

  // Form delete statements to remove old runs
  boost::wformat deleteStmt1(
      L"delete from t_mf_tracking_scripts "
      L"where id_tracking = N'%1%'");
  boost::wformat deleteStmt2(
      L"delete from t_mf_tracking_instructions "
      L"where id_tracking = N'%1%'");
  boost::wformat deleteStmt3(
      L"delete from t_mf_tracking_env "
      L"where id_tracking = N'%1%'");

  mConnection->SetAutoCommit(false);

  // Execute statements
  boost::shared_ptr<COdbcStatement> s1(mConnection->CreateStatement());
  s1->ExecuteUpdateW((deleteStmt1 % EncodeString(trackingID)).str());
  s1->ExecuteUpdateW((deleteStmt2 % EncodeString(trackingID)).str());
  s1->ExecuteUpdateW((deleteStmt3 % EncodeString(trackingID)).str());

  mConnection->CommitTransaction();
  mConnection->SetAutoCommit(true);
}

void WorkflowHistorianDb::discardHistories(time_t olderThanDate)
{
  // Open database connection
  if (!openDatabaseConnection())
  {
    return;
  }

  // Form select statement to get all old runs
  boost::wformat selectStmt(
      L"select id_tracking "
      L"from t_mf_tracking_scripts "
      L"where dt_start < %1%");

  // Execute statement
  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  DATE dateVal;
  ::OleDateFromTimet(&dateVal, olderThanDate);
  std::wstring strDt;
  ::FormatValueForDB(_variant_t(dateVal, VT_DATE), 
                     mConnection->GetConnectionInfo().IsOracle(),
                     strDt);
  boost::shared_ptr<COdbcResultSet> rs = 
    boost::shared_ptr<COdbcResultSet>(statement->ExecuteQueryW((selectStmt % strDt).str()));

  vector<std::wstring> oldRuns;

  // Process results
  while (rs->Next())
  {
    oldRuns.push_back(rs->GetWideString(1));
  }

  rs->Close();
      
  // Delete all the old runs
  for (unsigned int i=0; i<oldRuns.size(); i++)
  {
    deleteRun(oldRuns[i]);
  }
}

bool WorkflowHistorianDb::getDetailedHistory(
                                 TrackingID id,
                                 RunHistory &runHistory,
                                 vector <InstructionHistory> &instrHistory)
{
  if (!openDatabaseConnection())
  {
    return false;
  }

  // Get the runHistory information
  if (!getBriefHistory(id, runHistory))
  {
    return false;
  }

  // Form select statement to get instruction information
  boost::wformat selectStmt(
      L"select seq_no, instruction_no, dt_start, "
      L"dt_end, description "
      L"from t_mf_tracking_instructions "
      L"where id_tracking=N'%1%' "
      L"order by seq_no");

  // Execute statement
  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs = 
    boost::shared_ptr<COdbcResultSet>(statement->ExecuteQueryW((selectStmt % EncodeString(id)).str()));

  // Process results
  while (rs->Next())
  {
    InstructionHistory iHistory;
    iHistory.seqNumber = rs->GetInteger(1);
    iHistory.trackingID = id;
    iHistory.instructionNumber = rs->GetInteger(2);

    DATE startTime = rs->GetOLEDate(3);
    iHistory.startTime = oleDateToString(startTime);

    DATE endTime = rs->GetOLEDate(4);
    iHistory.wasCompleted = !(rs->WasNull());

    if (iHistory.wasCompleted)
    {
      iHistory.endTime = oleDateToString(endTime);
    }
    else
    {
      iHistory.endTime = L"----------------------";
    }

    iHistory.description = rs->GetWideString(5);

    instrHistory.push_back(iHistory);
  }

  // Read in the environments
  for (unsigned int i=0; i<instrHistory.size(); i++)
  {
    readArgEnvFromDb(instrHistory[i].seqNumber, instrHistory[i].environment);
  }

  rs->Close();

  return true;
}

vector <RunHistory> WorkflowHistorianDb::getBriefHistory(
                                                const std::wstring& scriptName)
{
  vector <RunHistory> result;

  // Open database connection
  if (!openDatabaseConnection())
  {
    return result;
  }

  // Form select statement to get all matching scripts
  boost::wformat selectStmt(
      L"select id_tracking, dt_start, was_completed "
      L"from t_mf_tracking_scripts "
      L"where script_name=N'%1%'");

  // Execute statement
  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs = boost::shared_ptr<COdbcResultSet>
    (statement->ExecuteQueryW((selectStmt % EncodeString(scriptName)).str()));

  // Process results
  while (rs->Next())
  {
    RunHistory runHistory;
    runHistory.trackingID = rs->GetWideString(1);
    runHistory.scriptName = scriptName;

    DATE d = rs->GetOLEDate(2);
    runHistory.startTime = oleDateToString(d);

    runHistory.isCompleted = (rs->GetInteger(3) != 0);
    result.push_back(runHistory);
  }

  rs->Close();
      
  return result;
}

bool WorkflowHistorianDb::getBriefHistory(const std::wstring& trackingID,
                                          RunHistory &runHistory)
{
  // Open database connection
  if (!openDatabaseConnection())
  {
    return false;
  }

  // Form select statement to get all matching scripts
  boost::wformat selectStmt(
      L"select script_name, dt_start, was_completed "
      L"from t_mf_tracking_scripts "
      L"where id_tracking=N'%1%'");

  // Execute statement
  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs = boost::shared_ptr<COdbcResultSet>
    (statement->ExecuteQueryW((selectStmt % EncodeString(trackingID)).str()));

  // Process results
  if (rs->Next())
  {
    runHistory.trackingID = trackingID;
    runHistory.scriptName = rs->GetWideString(1);

    DATE d = rs->GetOLEDate(2);
    runHistory.startTime = oleDateToString(d);

    runHistory.isCompleted = (rs->GetInteger(3) != 0);
    rs->Close();
    return true;
  }

  rs->Close();
  return false;
}

bool WorkflowHistorianDb::getScriptName(const std::wstring& id,
                                        std::wstring &scriptName)
{
  // Open database connection
  if (!openDatabaseConnection())
  {
    return false;
  }

  // Form select statement to get all matching scripts
  boost::wformat selectStmt(
      L"select script_name "
      L"from t_mf_tracking_scripts "
      L"where id_tracking=N'%1%'");

  // Execute statement
  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs = boost::shared_ptr<COdbcResultSet>
    (statement->ExecuteQueryW((selectStmt % EncodeString(id)).str()));

  // Process results
  if (rs->Next())
  {
    scriptName = rs->GetWideString(1);
    return true;
  }

  rs->Close();
  return false;
}

void WorkflowHistorianDb::writeArgEnvToDb(
                        const std::map<std::wstring, std::wstring>& nonIntrinsicArgs,
                        const std::map<std::wstring, std::wstring>& intrinsicArgs)
{
  try
  {
    boost::shared_ptr<COdbcPreparedArrayStatement> statement(mConnection->PrepareInsertStatement("t_mf_tracking_env", 100));

    boost::int32_t batchSize=0;
    for (std::map<std::wstring, std::wstring>::const_iterator 
           it=nonIntrinsicArgs.begin(); it != nonIntrinsicArgs.end(); it++)
    {
      statement->SetWideString(1, mTrackingID);
      statement->SetInteger(2, mSequenceNumber);
      statement->SetWideString(3, it->first);
      statement->SetWideString(4, it->second);
      statement->SetInteger(5, 0);
      statement->AddBatch();
      if (++batchSize >= 100)
      {
        batchSize = 0;
        statement->ExecuteBatch();
      }
    }

    for (std::map<std::wstring, std::wstring>::const_iterator 
           it=intrinsicArgs.begin(); it != intrinsicArgs.end(); it++)
    {
      statement->SetWideString(1, mTrackingID);
      statement->SetInteger(2, mSequenceNumber);
      statement->SetWideString(3, it->first);
      statement->SetWideString(4, it->second);
      statement->SetInteger(5, 1);
      statement->AddBatch();
      if (++batchSize >= 100)
      {
        batchSize = 0;
        statement->ExecuteBatch();
      }
    }

    if (batchSize > 0)
    {
      statement->ExecuteBatch();
    }
  }
  catch(...)
  {
    mLogger->logError(L"An error occurred inserting into table t_mf_tracking_env");
    return;
  }
}

void WorkflowHistorianDb::readArgEnvFromDb(
                        int seqNumber,
                        ArgEnvironment& argEnv)
{
  // Form select statement to get instruction information
  boost::wformat selectStmt(
      L"select name, value, arg_type "
      L"from t_mf_tracking_env "
      L"where id_tracking=N'%1%' and seq_no=%2%");

  // Execute statement
  boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs = boost::shared_ptr<COdbcResultSet>
    (statement->ExecuteQueryW((selectStmt % EncodeString(mTrackingID) % seqNumber).str()));

  // Process results
  while (rs->Next())
  {
    std::wstring name = rs->GetWideString(1);
    std::wstring value = rs->GetWideString(2);
    int argType = rs->GetInteger(3);
    
    if (argType == 1)
    {
      argEnv.storeIntrinsicArg(name, value);
    }
    else
    {
      argEnv.storeArg(name, value);
    }
  }
}

void WorkflowHistorianDb::instructionStart(
                        unsigned int instructionNumber,
                        const std::wstring& description,
                        const ArgEnvironment& environment)
{
  if (!mIsTracking || mConnection == NULL)
  {
    return;
  }

  mConnection->SetAutoCommit(false);

  mSequenceNumber++;

  mIsInstructionInProgress = true;

  // Execute
  try
  {
    boost::shared_ptr<COdbcPreparedArrayStatement> statement(mConnection->PrepareInsertStatement("t_mf_tracking_instructions"));
    statement->SetWideString(1, mTrackingID);
    statement->SetInteger(2, mSequenceNumber); 
    statement->SetInteger(3, instructionNumber);
    DATE now = (DATE) ::GetMTOLETime();
    statement->SetDatetime(4, &now);
    statement->SetWideString(6, description);
    statement->AddBatch();
    statement->ExecuteBatch();
  }
  catch(...)
  {
    try
    {
      mConnection->RollbackTransaction();
      mConnection->SetAutoCommit(true);
    }
    catch(...)
    {
    }
    mLogger->logError(L"An error occurred inserting into table t_mf_tracking_instructions");
  }

  // Write the out the environment to the database
  const std::map<std::wstring, std::wstring>& nonInstrinsicArgs =
    environment.getNonIntrinsicArgs();
  const std::map<std::wstring, std::wstring>& instrinsicArgs =
    environment.getIntrinsicArgs();

  writeArgEnvToDb(nonInstrinsicArgs, instrinsicArgs);

  mConnection->CommitTransaction();
  mConnection->SetAutoCommit(true);
}

void WorkflowHistorianDb::instructionEnd(bool wasSuccessful)
{
  if (!mIsTracking || mConnection == NULL)
  {
    return;
  }

  if (!mIsInstructionInProgress)
  {
    mLogger->logError(L"Inappropriate call to instructionEnd.");
    return;
  }

  if (wasSuccessful)
  {
    boost::wformat updateStmt(
      L"UPDATE t_mf_tracking_instructions "
      L"SET dt_end=%1% "
      L"WHERE id_tracking=N'%2%' AND seq_no=%3%");

    boost::shared_ptr<COdbcStatement> statement(mConnection->CreateStatement());
    statement->ExecuteUpdateW((updateStmt % 
                               ((const wchar_t *)(_bstr_t)::GetMTTimeForDB()) %
                               EncodeString(mTrackingID) %
                               mSequenceNumber).str());
  }

  mIsInstructionInProgress = false;
}

std::wstring WorkflowHistorianDb::oleDateToString(const DATE &d)
{
  std::wstring result;

  BSTR bstrVal;
  HRESULT hr = ::VarBstrFromDate(d, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  if (FAILED(hr))
  {
    return L"----------------------";
  }

  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal);

  std::wstringstream sstream;
  sstream << bstrtVal;

  result = sstream.str();

  // Standardize the length of this date
  result.append((22 - result.length() > 0) ?
                (22 - result.length()) : 0, L' ');
  return result;
}

bool WorkflowHistorianDb::openDatabaseConnection()
{
  if (mConnection != NULL)
  {
    return true;
  }

  // Open database connection
  COdbcConnectionInfo netMeter = 
                      COdbcConnectionManager::GetConnectionInfo("NetMeter");
  mConnection = new COdbcConnection(netMeter);

  if (mConnection == NULL)
  {
    mLogger->logError("Unable to open connection to the database NetMeter.");
    return false;
  }

  mConnection->SetAutoCommit(true);
  return true;
}
