
#include <iostream>
#include <sstream>

#include "LogAdapter.h"
#include "ArgEnvironment.h"
#include "WorkflowPredicate.h"
#include "Workflow.h"
#include "WorkflowInstructionIf.h"

WorkflowInstructionIf::WorkflowInstructionIf(
                                            Workflow *workflow,
                                            const std::wstring& description) :
  mNumberToJump(1),
  mPredicate(NULL),
  WorkflowInstruction(workflow, description)
{
}

WorkflowInstructionIf::~WorkflowInstructionIf()
{
  if (mPredicate)
  {
    delete mPredicate;
  }
}

bool WorkflowInstructionIf::execute()
{
  if (!mPredicate || mPredicate->evaluate())
  {
    mWorkflow->advanceInstructionCounter();
  }
  else
  {
    mWorkflow->advanceInstructionCounter(mNumberToJump);
  }

  return true;
}

void WorkflowInstructionIf::setNumberToJump(boost::int32_t numberToJump)
{
  mNumberToJump = numberToJump;
}

void WorkflowInstructionIf::setPredicate(WorkflowPredicate* predicate)
{
  mPredicate = predicate;

  std::wstringstream sstream;
  sstream << L"if " << mPredicate->toString();
  setDescription(sstream.str());
}

WorkflowInstructionJump::WorkflowInstructionJump(
                                            Workflow *workflow,
                                            const std::wstring& description) :
  mNumberToJump(1),
  WorkflowInstruction(workflow, description)
{
}

WorkflowInstructionJump::~WorkflowInstructionJump()
{
}

bool WorkflowInstructionJump::execute()
{
  mWorkflow->advanceInstructionCounter(mNumberToJump);
  return true;
}

void WorkflowInstructionJump::setNumberToJump(boost::int32_t numberToJump)
{
  mNumberToJump = numberToJump;
}
