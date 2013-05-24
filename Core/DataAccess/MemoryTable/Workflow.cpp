#include "mpi.h"

#include <iostream>
#include <sstream>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/archive/binary_oarchive.hpp>

#include "Timer.h"

#include "Workflow.h"
#include "WorkflowInstructionStep.h"
#include "WorkflowHistorian.h"
#include "Scheduler.h"
#include "Reporter.h"
#include "ArgEnvironment.h"

const std::wstring Workflow::DefaultStepName = L"main";

Workflow::Workflow(
  boost::int32_t numPartitions, 
  bool isCluster,
  const std::map<std::wstring, std::vector<boost::int32_t> > 
                                                    & partitionListDefns,
  Reporter &reporter,
  WorkflowHistorian &historian,
  const std::wstring &filename,
  bool isNewTrackingRun,
  bool isRerun,
  const std::wstring &trackingID,
  bool isTimingEchoed) :

    mInstructionCounter(0),
    mNumberOfPartitions(numPartitions),
    mIsClustered(isCluster),
    mPartitionListDefns(partitionListDefns),
    mHistorian(historian),
    mFilename(filename),
    mReporter(reporter),
    mIsNewTrackingRun(isNewTrackingRun),
    mIsRerun(isRerun),
    mTrackingID(trackingID),
    mIsTimingEchoed(isTimingEchoed)
{
  mLogger = MetraFlowLoggerManager::GetLogger("[MF Workflow]");

  // If both rerun and isNewTrackingRun are specified,
  // we assume the user just meant to rerun.
  if (mIsNewTrackingRun && mIsRerun)
  {
    mIsNewTrackingRun = false;
  }

  // There is always a default plan containing an dataflow described
  // in the main body of the script.

  DesignTimePlan *plan = new DesignTimePlan();
  plan->setName(DefaultStepName);
  mSteps[DefaultStepName] = plan;

  // The first instruction in a workflow is to execute
  // the default step (the default DesignTimePlan)

  WorkflowInstructionStep* instr = 
      new WorkflowInstructionStep(this, DefaultStepName, DefaultStepName);

  mInstructions.push_back(instr);
}

Workflow::~Workflow()
{
  for (unsigned int i=0; i<mInstructions.size(); i++)
  {
    delete mInstructions[i];
  }

  for (std::map<std::wstring, DesignTimePlan*>::iterator 
       it = mSteps.begin(); it != mSteps.end(); it++)
  {
    if (it->second)
    {
      delete it->second;
    }
  }
}

void Workflow::addInstruction(WorkflowInstruction *instruction)
{
  mInstructions.push_back(instruction);
}

bool Workflow::addStepDeclaration(const std::wstring &stepName)
{
  if (mSteps.find(stepName) != mSteps.end())
  {
    return false;
  }

  mSteps[stepName] = NULL;
  return true;
}

void Workflow::advanceInstructionCounter(int advanceBy)
{
  mInstructionCounter += advanceBy;
}

DesignTimePlan* Workflow::getDesignTimePlan(const std::wstring &stepName)
{
  if (mSteps.find(stepName) == mSteps.end())
  {
    return NULL;
  }

  return mSteps.find(stepName)->second;
}
  
std::map<std::wstring, DesignTimePlan*>& Workflow::getDesignTimePlans()
{
  return mSteps;
}

boost::int32_t Workflow::getLastInstructionNumber() const
{
  return mInstructions.size();
}

boost::int32_t Workflow::getNumberOfPartitions() const
{
  return mNumberOfPartitions;
}

bool Workflow::getIsClustered() const
{
  return mIsClustered;
}

const std::map<std::wstring, std::vector<boost::int32_t> > 
             & Workflow::getPartitionListDefns() const
{
  return mPartitionListDefns;
}

Reporter & Workflow::getReporter() const
{
  return mReporter;
}

bool Workflow::getIsTimingEchoed() const
{
  return mIsTimingEchoed;
}

bool Workflow::isKnownStep(const std::wstring &stepName)
{
  return (mSteps.find(stepName) != mSteps.end());
}

int Workflow::run()
{
  bool isOk = true;
  mInstructionCounter = 0;

  // If we are in tracking mode (a new run, or a re-run),
  // we will turn on the historian (scriptStart() or scriptRestart()).
  // Otherwise, the historian will do nothing.
  if (mIsNewTrackingRun)
  {
    isOk = mHistorian.scriptStart(mFilename, mTrackingID);
  }
  else if (mIsRerun)
  {
    isOk = mHistorian.scriptRestart(mTrackingID, mInstructionCounter);
  }

  // Abandon ship if something went wrong.
  if (!isOk)
  {
    return false;
  }

  // Loop through the instructions
  while (mInstructionCounter < mInstructions.size())
  {
    mHistorian.instructionStart(
                  mInstructionCounter,
                  mInstructions[mInstructionCounter]->getDescription(),
                  *ArgEnvironment::getActiveEnvironment());

    if (!mInstructions[mInstructionCounter]->execute())
    {
      mHistorian.instructionEnd(false);
      mHistorian.scriptEnd(false);
      return 1;
    }

    mHistorian.instructionEnd(true);
  }

  mHistorian.scriptEnd(true);

  return 0;
}

bool Workflow::setDesignTimePlan(const std::wstring &stepName,
                                 DesignTimePlan *plan)
{
  if (mSteps.find(stepName) != mSteps.end() &&
      mSteps.find(stepName)->second != NULL)
  {
    return false;
  }

  mSteps[stepName] = plan;
  return true;
}

void Workflow::setInstructionCounter(unsigned int instructionNumber)
{
  mInstructionCounter = instructionNumber;
}
