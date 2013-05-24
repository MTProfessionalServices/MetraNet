#ifndef __WORKFLOW_INSTRUCTION_STEP_H__
#define __WORKFLOW_INSTRUCTION_STEP_H__

#include "WorkflowInstruction.h"

/**
 * A step instruction is used to execute a step.  Executing a step
 * means producing a run-time plan and executing it.
 */
class WorkflowInstructionStep : public WorkflowInstruction
{
private:
  /** Name of the step to execute. */
  std::wstring mStepName;

public:
  /** 
   * Constructor
   *
   * @param workflow      Workflow containing the instruction.
   * @stepName step name  The name of the step reference in the instruction
   * @description         Description of step for reporting (e.g. a:StepA)
   */
  WorkflowInstructionStep(Workflow *workflow,
                          const std::wstring& stepName,
                          const std::wstring& description);

  /** Destructor */
  ~WorkflowInstructionStep();

  /** 
   * Execute the instruction.
   * After executing, the program counter must be set to the next
   * instruction to execute (typically just increased by one).
   *
   * @return false on failure
   */
  virtual bool execute();

private:
  /** Disallowed - default constructor */
  WorkflowInstructionStep();

  /** Disallowed - copy constructor */
  WorkflowInstructionStep(const WorkflowInstructionStep&);

  /** Disallowed - assignment operator */
  WorkflowInstructionStep& operator = (const WorkflowInstructionStep&);

  /**
   * Given a design time plan, creates a runtime plan.  If an error occurs,
   * the error is reported using mReporter.
   *
   * @param designTimePlan  the design time plan.
   * @param runTimePlan     the created runtime plan.
   * @return 0 on success.
   */
  int createRunTimePlan(DesignTimePlan &designTimePlan,
                        boost::shared_ptr<ParallelPlan> runTimePlan);
};
#endif
