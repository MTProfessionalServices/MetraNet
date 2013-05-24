#ifndef __WORKFLOW_HISTORIAN_H__
#define __WORKFLOW_HISTORIAN_H__

#include <ctime>
#include <vector>

#include <iostream>
#include <fstream>

#include "LogAdapter.h"
#include "ArgEnvironment.h"

class COdbcConnection;

/** Type definition for a TrackingID */
typedef std::wstring TrackingID;

/** 
 * Contains a summary description of a run.
 */
typedef struct
{
  /** The tracking ID associated with the run of the script */
  TrackingID trackingID;

  /** Name of the script that was run. */
  std::wstring scriptName;

  /** The time the tracking ID was assigned (just prior to run of 1st step) */
  std::wstring startTime;

  /** 
   * True if the script completed. 
   */
  bool isCompleted;

} RunHistory;

/**
 * Contains a summary of the run of a particular
 * instruction (a control flow statement) in a script.
 */
typedef struct
{
  /** The tracking ID associated with the run of the script */
  TrackingID trackingID;

  /** 
   * The instruction number. Instructions numbering corresponds to
   * the ordering of control flow statements in the main script.
   * Note that in a run, numbers of the instructions executed 
   * may not be sequential due to if-statements.
   */
  int instructionNumber;

  /** 
   * The sequence number.  A sequential 1-based index of all the
   * instructions that have been attempted in the history of
   * the run.
   */
  int seqNumber;

  /** The time the instruction was started. */
  std::wstring startTime;

  /** The time the instruction was completed. */
  std::wstring endTime;

  /** Was this instruction completed? */
  bool wasCompleted;

  /** Description of the instruction. */
  std::wstring description;

  /** Argument environment as it was prior to this step being run. */
  ArgEnvironment environment;

} InstructionHistory;

/**
 * Maintains detailed histories of runs of scripts.  WorkflowHistorian
 * is an abstract class.  WorkflowHistorianFile is a file-based
 * storage implementation of the class.
 *
 * The WorkflowHistorian, by default, does NOT record histories.
 * Recording is only performed if scriptStart() or scriptRestart()
 * is called.
 */
class WorkflowHistorian
{

public:
  /** 
   * Constructor
   */
  WorkflowHistorian();

  /** Destructor */
  ~WorkflowHistorian();

  /**
   * Track the given script. Returns a unique tracking ID for 
   * this instance of running the script.
   *
   * @param scriptName  name of script
   * @param trackingID  a tracking ID that for tracking calls.
   *                    This must be a globally unique ID (GUID).
   * @return true if successfully starting tracking.
   */
  virtual bool scriptStart(const std::wstring& scriptName,
                           std::wstring& trackingID) = 0;

  /**
   * Start track the re-run of the given script. 
   * This will also set the argument environment (ArgEnvironment)
   * to be the arg environment stored for the last instruction.
   *
   * @param trackingID             a tracking ID of the previous run.
   * @param lastInstructionNumber  set instruction number that should be run
   * @param 
   *
   * @return true if successfully starting tracking.
   */
  virtual bool scriptRestart(const std::wstring& trackingID,
                             unsigned int &lastInstructionNumber) = 0;

  /**
   * Complete the recording a particular run by marking the
   * run as completed.
   *
   * @param wasSuccessful  true if run completed.
   */
  virtual void scriptEnd(bool wasSuccessful) = 0;

  /**
   * Start the recording of the run of an instruction.
   * Note that this records not only the given information, but
   * also maintains the order that instructions were executed in.
   */
  virtual void instructionStart(unsigned int instructionNumber,
                                const std::wstring& description,
                                const ArgEnvironment& environment) = 0;
  /**
   * Complete the recording of the run of an instruction.
   */
  virtual void instructionEnd(bool wasCompleted) = 0;

  /**
   * Delete all stored information for tracking IDs older than
   * the given date.
   *
   * @param  @olderThanDate  format must be YYYY-MM-DD
   */
  virtual void discardHistories(time_t olderThanDate) = 0;

  /**
   * Given a script, return the histories of running the script.
   */
  virtual vector <RunHistory> getBriefHistory(const std::wstring& scriptName)
                                                                           = 0;
  /**
   * Given a script, returns a string listing past runs of script.
   */
  std::wstring getBriefHistoryAsString(const std::wstring& scriptName);

  /**
   * Given a tracking ID, return a string
   * decribing the details of the run.
   */
  std::wstring getDetailedHistoryAsString(const TrackingID& id);

  /**
   * Given a tracking ID, return a detailed history of the run.
   * The instrHistory contains a vectory of the instruction of instruction
   * execution.  The order of this array matches the order that the instructions
   * were executed in.  Note that this order is different than
   * instruction-number order.  Due to if-statements, instructions are not
   * necessarily executed in instruction-number order.
   *
   * If this method fails to read the information, then an error message
   * should be written to the log file and possible to standard out.
   *
   * @param trackingID   identifies a particular script run
   * @param runHistory   top level run details
   * @param instrHistory history of steps that at least started
   * @return false on error
   */
  virtual bool getDetailedHistory(TrackingID id,
                                  RunHistory &runHistory,
                                  vector <InstructionHistory> &instrHistory)=0;

  /**
   * Get the number (zero-based) of the last instruction
   * that was executed.  Typically, this instruction was not completed.
   *
   * @param trackingID   identifies the tracking information to look up
   * @param nInstructionStarts  the number of instructions that have been 
   *                     executed so far (instr may or may not have completed).
   * @param lastNumber   number (zero-based) of last instruction. Will return 0 
   *                     and false if no instruction has been executed.
   * @param lastEnv      the argument environment that was in place
   *                     prior to executing the last instruction.
   * @param wasLastInstrCompleted   false, if this last instruction 
   *                     was started but not completed. true if last instruction
   *                     completed (this is unexpected).
   * @param wasScriptCompleted  true if the script completed execution.
   * @return             false if unable to return result
   */
  bool getLastInstruction(const TrackingID& id,
                          int &nInstructionStarts,
                          unsigned int &lastNumber,
                          ArgEnvironment &lastEnv,
                          bool &wasLastInstrCompleted,
                          bool &wasScriptCompleted);

  /** 
   * Given the trackingID of a previous run, get the associated script name.
   *
   * @param scriptName  set to name of script.
   * @return false  if tracking ID is incorrect.
   */
  virtual bool getScriptName(const std::wstring& trackingID,
                             std::wstring& scriptName) = 0;

protected:
  bool mIsTracking;

private:
  /** Disallowed - copy constructor */
  WorkflowHistorian(const WorkflowHistorian&);

  /** Disallowed - assignment operator */
  WorkflowHistorian& operator = (const WorkflowHistorian&);
};

class WorkflowHistorianFile : public WorkflowHistorian
{

public:
  /** 
   * Constructor
   */
  WorkflowHistorianFile();

  /** Destructor */
  ~WorkflowHistorianFile();

  /**
   * Track the given script. Returns a unique tracking ID for 
   * this instance of running the script.
   */
  virtual bool scriptStart(const std::wstring& scriptName,
                           std::wstring& trackingID);
  /**
   * Start track the re-run of the given script. 
   */
  virtual bool scriptRestart(const std::wstring& trackingID,
                             unsigned int &lastInstructionNumber);
  /**
   * Complete the recording a particular run by marking the
   * run as completed.
   */
  virtual void scriptEnd(bool wasSuccessful);

  /**
   * Delete all stored information for tracking IDs older than
   * the given date.
   */
  virtual void discardHistories(time_t olderThanDate);

  /**
   * Given a tracking ID, return a detailed history of the run.
   *
   * @return  false on error.
   */
  virtual bool getDetailedHistory(TrackingID id,
                                  RunHistory &runHistory,
                                  vector <InstructionHistory> &instrHistory);

  /**
   * Given a script, return the history of running the script.
   */
  virtual vector <RunHistory> getBriefHistory(const std::wstring& scriptName);

  /**
   * Start the recording of the run of an instruction.
   */
  virtual void instructionStart(
                        unsigned int instructionNumber,
                        const std::wstring& description,
                        const ArgEnvironment& environment);

  /**
   * Complete the recording of the run of an instruction.
   */
  virtual void instructionEnd(bool wasCompleted);

  /** 
   * Given the trackingID of a previous run, get the associated script name.
   *
   * @param scriptName  set to name of script.
   * @return false  if tracking ID is incorrect.
   */
  virtual bool getScriptName(const std::wstring& trackingID,
                             std::wstring& scriptName);

private:
  /** Disallowed - copy constructor */
  WorkflowHistorianFile(const WorkflowHistorianFile&);

  /** Disallowed - assignment operator */
  WorkflowHistorianFile& operator = (const WorkflowHistorianFile&);

  /** 
   * Given a tracking ID, determing the corresponding script name.
   *
   * @param scriptName  output: root name of the corresponding script.
   * @return  false if tracking file not found.
   */
  bool determineScriptName(const std::wstring& trackingID,
                           std::wstring& scriptName);

  /** Form the filename where the history is stored. */
  std::wstring formFilename(const std::wstring& scriptName,
                           TrackingID id);

  /** Get root name of file (no directory prefixes) */
  std::wstring getFilenameRoot(const std::wstring &filename);

  /** Convert time to string. */
  static std::string toString(time_t t);

  /** Convert string to bool */
  static bool toBool(const std::string& s);

  /** Convert string to int */
  static int toInt(const std::string& s);

  /** Convert string to long */
  static long toLong(const std::string& s);

  /** Convert time to a readable date */
  static std::wstring toDateString(time_t *t);

private:
  /** Directory where we are storing tracking information. */
  std::wstring mStorageDir;

  /** File where we are storing tracking information. */
  std::wstring mStorageFile;

  /** Output stream for tracking information currently being written. */
  ofstream *mOutputFile;

  /** Is an instruction in progress */
  bool mIsInstructionInProgress;

  /** Logger */
  MetraFlowLoggerPtr mLogger;

};

class WorkflowHistorianDb : public WorkflowHistorian
{

public:
  /** 
   * Constructor
   */
  WorkflowHistorianDb();

  /** Destructor */
  ~WorkflowHistorianDb();

  /**
   * Track the given script. Returns a unique tracking ID for 
   * this instance of running the script.
   */
  virtual bool scriptStart(const std::wstring& scriptName,
                           std::wstring& trackingID);
  /**
   * Start track the re-run of the given script. 
   */
  virtual bool scriptRestart(const std::wstring& trackingID,
                             unsigned int &lastInstructionNumber);
  /**
   * Complete the recording a particular run by marking the
   * run as completed.
   */
  virtual void scriptEnd(bool wasSuccessful);

  /**
   * Delete all stored information for tracking IDs older than
   * the given date.
   */
  virtual void discardHistories(time_t olderThanDate);

  /**
   * Given a tracking ID, return a detailed history of the run.
   *
   * @return  false on error.
   */
  virtual bool getDetailedHistory(TrackingID id,
                                  RunHistory &runHistory,
                                  vector <InstructionHistory> &instrHistory);

  /**
   * Given a script, return the history of running the script.
   */
  virtual vector <RunHistory> getBriefHistory(const std::wstring& scriptName);

  /**
   * Start the recording of the run of an instruction.
   */
  virtual void instructionStart(
                        unsigned int instructionNumber,
                        const std::wstring& description,
                        const ArgEnvironment& environment);

  /**
   * Complete the recording of the run of an instruction.
   */
  virtual void instructionEnd(bool wasCompleted);

  /** 
   * Given the trackingID of a previous run, get the associated script name.
   *
   * @param scriptName  set to name of script.
   * @return false  if tracking ID is incorrect.
   */
  virtual bool getScriptName(const std::wstring& trackingID,
                             std::wstring& scriptName);

private:
  /** Disallowed - copy constructor */
  WorkflowHistorianDb(const WorkflowHistorianDb&);

  /** Disallowed - assignment operator */
  WorkflowHistorianDb& operator = (const WorkflowHistorianDb&);

  /** Delete all references to the given run from the tracking tables. */
  void deleteRun(const TrackingID &trackingID);

  /**
   * Given a trackingID, get history of run.
   *
   * @return false if trackingID not found.
   */
  bool getBriefHistory(const std::wstring& id,
                       RunHistory &runHistory);

  /** Convert OLE date to string */
  std::wstring oleDateToString(const DATE &d);

  /**
   * Open database connection, if not already open.
   * On error, log error and return false.
   */
  bool openDatabaseConnection();

  /** Write an arg environment setting to the database. */
  void writeArgEnvToDb(
    const std::map<std::wstring, std::wstring>& nonIntrinsicArgs,
    const std::map<std::wstring, std::wstring>& intrinsicArgs);

  /** 
   * Read all arg environment setting for a given sequence number 
   *
   * @param seqNumber  identifies the sequence number in the run that
   *                   we want the environment for.
   * @param env        the read arguments are loaded into this environment.
   */
  void readArgEnvFromDb(int seqNumber,
                        ArgEnvironment& env);

private:
  /** Database connection */
  COdbcConnection *mConnection;

  /** Is an instruction in progress */
  bool mIsInstructionInProgress;

  /** The current tracking ID */
  std::wstring mTrackingID;

  /** 
   * The current instruction sequence number.  The sequence number
   * of the instruction we last worked on.
   */
  int mSequenceNumber;

  /** Logger */
  MetraFlowLoggerPtr mLogger;

};
#endif
