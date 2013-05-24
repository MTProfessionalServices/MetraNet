#include "WorkflowInstruction.h"


WorkflowInstruction::WorkflowInstruction(Workflow *workflow,
                                         const std::wstring& description)
  : mWorkflow(workflow),
    mDescription(description)
{
  mLogger = MetraFlowLoggerManager::GetLogger("[MF Workflow Instruction]");
}

WorkflowInstruction::~WorkflowInstruction()
{
}

const std::wstring& WorkflowInstruction::getDescription() const
{
  return mDescription;
}

void WorkflowInstruction::setDescription(const std::wstring &s)
{
  mDescription = s;
}

