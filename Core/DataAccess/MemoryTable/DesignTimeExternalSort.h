#ifndef __DESIGNTIMEEXTERNALSORT_H__
#define __DESIGNTIMEEXTERNALSORT_H__

#include "Scheduler.h"
#include "SortMergeCollector.h"

class DesignTimeExternalSort : public DesignTimeOperator
{
public:
  METRAFLOW_DECL DesignTimeExternalSort();
  METRAFLOW_DECL ~DesignTimeExternalSort();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL void AddSortKey(const DesignTimeSortKey & aKey);
  METRAFLOW_DECL void SetAllowedMemory(std::size_t allowedMemory);
  METRAFLOW_DECL void SetTempDirectory(const std::wstring& tempDir);
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeExternalSort* clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg*>& args, 
                                        int nInputs, int nOutputs) const;
		
private: 
  //datastructure to store the keys
  std::vector<DesignTimeSortKey> mSortKey;
  std::size_t mAllowedMemory;
  std::wstring mTempDir;
};

#endif
