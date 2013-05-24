#ifndef __PIPELINEAPPLICATION_H__
#define __PIPELINEAPPLICATION_H__

#include <metra.h>
#include <OdbcConnection.h>

// Application object that contains global resources.  In this case, I am only
// implementing code to allocate a singleton (performance optimization) for ODBC environment.  If this
// is done using a static member it seems to cause COM+ crashes (see old code in OdbcConnection.cpp)!
class PipelineApplication
{
private:
  COdbcEnvironment * mEnv;
protected:
  PipelineApplication()
  {
    mEnv = COdbcEnvironment::GetInstance();
  }

  ~PipelineApplication()
  {
    if(mEnv) 
    {
      COdbcEnvironment::ReleaseInstance();
    }
  }
};

#endif
