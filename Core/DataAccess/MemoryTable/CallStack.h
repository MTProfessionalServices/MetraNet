#ifndef __CALLSTACK_H__
#define __CALLSTACK_H__

#include "MetraFlowConfig.h"
#include <string>

class ToolHelpApi;

class CallStack
{
private:
  DWORD_PTR mInstructionPointers[20];
  std::size_t mNumInstructionPointers;
  ToolHelpApi& mToolHelp;
  void Init(CONTEXT& context);
public:
  METRAFLOW_DECL CallStack();
  METRAFLOW_DECL CallStack(CONTEXT& context);
  METRAFLOW_DECL ~CallStack();
  METRAFLOW_DECL void ToString(std::string& msg);
};


#endif
