#ifndef __WORKFLOW_H__
#define __WORKFLOW_H__

#include <map>
#include <vector>

#include <boost/cstdint.hpp>

#include "LogAdapter.h"

class DesignTimePlan;
class ParallelPlan;
class WorkflowInstruction;
class Reporter;
class WorkflowHistorian;

/**
 * A Workflow is a set of design time plans and a series of instructions
 * describing the control for the plans.  A workflow is created from a
 * MetraFlow script.
 */
class Workflow
{
private:
  /** A map of step name to design time plan. */
  std::map<std::wstring, DesignTimePlan*> mSteps;

  /** The sequence of workflow instructions describing the control flow. */
  std::vector<WorkflowInstruction*> mInstructions;

  /** 
   * Counter of next instruction number to execute.
   * This is a zero-based index into mInstructions.
   */
  unsigned int mInstructionCounter;

  /** Number of partitions to execute workflow on */
  boost::int32_t mNumberOfPartitions;

  /** 
   * True if clustered, meaning we are using MPI to communicate
   * to slave processes. 
   */
  bool mIsClustered;

  /** Defines a named partition lists, definining subsets of partitions. */
  const std::map<std::wstring, std::vector<boost::int32_t> > 
                                                   & mPartitionListDefns;
  /** Historian of script run */
  WorkflowHistorian &mHistorian;

  /** Name of the script we are running */
  std::wstring mFilename;

  /** Error reporter */
  Reporter &mReporter;

  /** Are we tracking a new run? */
  bool mIsNewTrackingRun;

  /** Are we re-running a script from were we left off? */
  bool mIsRerun;

  /** Tracking ID or empty string if not tracking. */
  std::wstring mTrackingID;

  /** Is timing information echoed to standard out? */
  bool mIsTimingEchoed;

  /** Logger */
  MetraFlowLoggerPtr mLogger;

public:
  /** 
   * This is name of the default step that all workflows contain.
   * This default step holds the design time plan for any dataflow
   * specified in the body of the script.
   */
  static const std::wstring DefaultStepName;

  /** 
   * Constructor
   *
   * @param numPartitions       the number of partitions.
   * @param isCluster           true if clustered
   * @param partitionListDefns  definitions of partition lists
   * @param reporter            reporter to use for error messages
   * @param historian           the historian to use to record events
   * @param scriptName          name of Metraflow script
   * @param isNewTrackingRun    true if we should record what happens
   * @param isRerun             true if we should resume a previous run
   * @param trackingID          identifies the last run of the script
   * @param isTimingEchoed      true if timing should be echoed to stdout
   */
  Workflow(boost::int32_t numPartitions,
           bool isCluster,
           const std::map<std::wstring, std::vector<boost::int32_t> > 
                                                   & partitionListDefns,
           Reporter& reporter,
           WorkflowHistorian& historian,
           const std::wstring& scriptName,
           bool isNewTrackingRun,
           bool isRerun,
           const std::wstring &trackingID,
           bool isTimingEchoed);

  /** Destructor */
  ~Workflow();

  /**
   * Add the instruction to the end of the series of instructions
   * for this workflow.  This class assumes ownership of the instruction
   * pointer.
   */
  void addInstruction(WorkflowInstruction *instruction);

  /**
   * Add the given step to the list of known steps.
   *
   * @return  If a step by this name has already
   *          been defined returns false, otherwise true.
   */
  bool addStepDeclaration(const std::wstring& stepName);

  /** Advance the instruction counter to the next instruction. */
  void advanceInstructionCounter(int advanceBy=1);

  /** 
   * Get the design time plan for the given step. 
   * Return NULL if not found.
   */
  DesignTimePlan* getDesignTimePlan(const std::wstring& stepName);

  /** Get a map (by step name) of all the design time plans */
  std::map<std::wstring, DesignTimePlan*>& getDesignTimePlans();

  /** Get number of partitions */
  boost::int32_t getNumberOfPartitions() const;

  /** Get is clustered.  True indicates MPI is being used. */
  bool getIsClustered() const;

  /** Get named partition lists, definining subsets of partitions. */
  const std::map<std::wstring, std::vector<boost::int32_t> > 
                                              & getPartitionListDefns() const;

  /** Get the instruction number of the last instruction */
  boost::int32_t getLastInstructionNumber() const;

  /** Get error reporter */
  Reporter & getReporter() const;

  /** Is timing information echoed to standard out? */
  bool getIsTimingEchoed() const;

  /** Is this step in the workflow? */
  bool isKnownStep(const std::wstring& stepName);

  /**
   * Run the workflow.
   *
   * @return 0 on success, 1 on failure.
   */
  int run();

  /**
   * Set the given design time plan under the given step
   * declaration name.  The workflow takes ownership of
   * the given pointer.
   *
   * @return  If a step by this name has already
   *          been defined, return false, otherwise true.
   */
  bool setDesignTimePlan(const std::wstring& stepName, DesignTimePlan *plan);

  /** Set the instruction counter. */
  void setInstructionCounter(unsigned int instructionNumber);

private:
  /** Disallowed - default constructor */
  Workflow();

  /** Disallowed - copy constructor */
  Workflow(const Workflow&);

  /** Disallowed - assignment operator */
  Workflow& operator = (const Workflow&);
};

#endif
