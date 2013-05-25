#ifndef __AUDITIDGENERATOR_H__
#define __AUDITIDGENERATOR_H__

#include <NTThreadLock.h>
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")

class AuditIdGenerator
{
private:
  static NTThreadLock mThreadLock;
  static MetraTech_DataAccess::IIdGenerator2Ptr mIdGenerator;
public:
  static MetraTech_DataAccess::IIdGenerator2Ptr Get();
};

#endif
