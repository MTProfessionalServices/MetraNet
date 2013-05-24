#include "mpi.h"

#include <iostream>
#include <sstream>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/archive/binary_oarchive.hpp>

#include "Timer.h"
#include "LogAdapter.h"

#include "Workflow.h"
#include "WorkflowInstructionStep.h"
#include "Scheduler.h"
#include "Reporter.h"

WorkflowInstructionStep::WorkflowInstructionStep(
                                            Workflow *workflow,
                                            const std::wstring& stepName,
                                            const std::wstring& description) :
  mStepName(stepName),
  WorkflowInstruction(workflow, description)
{
}

WorkflowInstructionStep::~WorkflowInstructionStep()
{
}

bool WorkflowInstructionStep::execute()
{
  // Create the run time plan
  boost::shared_ptr<ParallelPlan> runTimePlan;
  runTimePlan = boost::shared_ptr<ParallelPlan>
                    (new ParallelPlan(mWorkflow->getNumberOfPartitions(), 
                                      mWorkflow->getIsClustered()));

  DesignTimePlan *designTimePlan = 
                  mWorkflow->getDesignTimePlan(mStepName);

  if (!designTimePlan)
  {
    mLogger->logError(L"Failed to find plan: " + mStepName);
    return false;
  }

  mLogger->logDebug(L"Executing step: " + mDescription);

  designTimePlan->add_partition_lists(mWorkflow->getPartitionListDefns());

  if (createRunTimePlan(*designTimePlan, runTimePlan) != 0)
  {
    return false;
  }

  Timer serializationTimer;
  Timer sendPlanTimer;

  // Send plans to slaves (if any) and then start execution.
  std::ostringstream plans;
  if (runTimePlan->GetNumDomains() > 1)
  {
    try
    {
      ScopeTimer sc(&serializationTimer);
      boost::archive::binary_oarchive oa(plans);
      ParallelPlan * tmp = runTimePlan.get();
      oa << BOOST_SERIALIZATION_NVP(tmp); 
    }
    catch(std::exception & e)
    {
      std::cerr << "Exception while serializing plan: " << e.what()<< std::endl;
      return false;
    }
  }

  for(boost::int32_t id = 1; id < runTimePlan->GetNumDomains(); id++)
  {
    std::string localeDescription;
    ::WideStringToMultiByte(mDescription, localeDescription, CP_ACP);
    std::cout << "Using MPI_Send to send " << localeDescription << std::endl;
    ScopeTimer sc(&sendPlanTimer);
    std::string s = plans.str();
    std::size_t bufsz = s.size() + 1;
    int ret = MPI_Send(const_cast<char *>(s.c_str()), bufsz, MPI_BYTE, id, 0, 
                       MPI_COMM_WORLD);
  }    

  // Free the memory of the serialized plans.  This
  // can be significant with a lot of parallelism.
  // Note that we should also free the memory associated with domains
  // that we have serialized; we don't really need them anymore and they
  // may be large if there is a lot of cluster parallelism.

  if (mWorkflow->getIsTimingEchoed())
  {
    std::cout << "Serialization= " << serializationTimer.GetMilliseconds() 
              << "; SendPlan= " << sendPlanTimer.GetMilliseconds() << std::endl;
  }

  // Run
  boost::shared_ptr<ParallelDomain> myDomain = runTimePlan->GetDomain(0);
  myDomain->Start();
  
  // Synchronize completion with the slaves (if any)
  if (runTimePlan->GetNumDomains() > 1)
  {
    MPI_Barrier(MPI_COMM_WORLD);
  }

  // Save only my domain and free the others to free up memory.
  myDomain = boost::shared_ptr<ParallelDomain>();

  mWorkflow->advanceInstructionCounter();

  return true;
}

int WorkflowInstructionStep::createRunTimePlan(
                             DesignTimePlan &designTimePlan,
                             boost::shared_ptr<ParallelPlan> pplan)
{
  Timer codeGenerateTimer;

  try
  {
    ScopeTimer sc(&codeGenerateTimer);
    designTimePlan.code_generate(*pplan);
  } 
  catch (DataflowException& e)
  {
    mLogger->logError(e.getMessage());
    mWorkflow->getReporter().reportException(e);
    return 1;
  }
  catch (std::exception& e) 
  {
    mLogger->logError(e.what());
    mWorkflow->getReporter().reportException(e);
    return 1;
  }
  catch (...) 
  {
    mLogger->logError("Caught unrecognized exception during generation.");
    mWorkflow->getReporter().reportException(L"generating");
    return 1;
  }

  if (mWorkflow->getIsTimingEchoed())
  {
    std::cout << "CodeGenerate= " << codeGenerateTimer.GetMilliseconds() 
              << std::endl;
  }

  return 0;
}

