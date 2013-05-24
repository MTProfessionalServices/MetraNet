#ifndef __FLOW_INSTRUCTION_H__
#define __FLOW_INSTRUCTION_H__

#include "LogAdapter.h"

class Workflow;

/**
 * This the base class for an instructions.
 * Control flow statements inside a MetraFlow script are
 * translated into a sequence of instructions DataflowScriptInterpreter.  
 * An example instruction: run this step(plan).  
 * <p>
 * Even if given a script that appears to have no control statements,
 * the interpreter will produce an instruction to run the default
 * step of main.
 */
class WorkflowInstruction 
{
protected:

  /** A descriptive for the instruction. */
  std::wstring mDescription;

  /** Workflow containing this instruction. */
  Workflow *mWorkflow;

  /** Logger */
  MetraFlowLoggerPtr mLogger;

public:
  /** 
   * Constructor
   *
   * @param workflow     Workflow containing the instruction.
   * @param description  A description of the instruction.
   */
  WorkflowInstruction(Workflow *workflow,
                      const std::wstring& description);

  /** Destructor */
  ~WorkflowInstruction();

  /** Get description */
  const std::wstring& getDescription() const;

  /** Set description */
  void setDescription(const std::wstring& newDescription);

  /** 
   * Execute the instruction.
   * After executing, the program counter must be set to the next
   * instruction to execute (typically just increased by one).
   *
   * @return false on failure
   */
  virtual bool execute() = 0;

private:
  /** Disallowed - default constructor */
  WorkflowInstruction();

  /** Disallowed - copy constructor */
  WorkflowInstruction(const WorkflowInstruction&);

  /** Disallowed - assignment operator */
  WorkflowInstruction& operator = (const WorkflowInstruction&);
};
#endif
