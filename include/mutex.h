#ifndef __MUTEX_H__
#define __MUTEX_H__

#include <metra.h>
#include <errutils.h>
#include <makeunique.h>

class NTMutex
{
private:
  HANDLE mMutex;

public:
  static SECURITY_ATTRIBUTES * GetDefaultSecurityAttributes(SECURITY_ATTRIBUTES& sa, SECURITY_DESCRIPTOR& sd)
  {
    const char * functionName="NTMutex::GetDefaultSecurityAttributes()";
    /*
     * create a NULL security descriptor
     * TODO: create a more restricted discretionary access control list.
     */
    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    sa.bInheritHandle = TRUE;
    sa.lpSecurityDescriptor = &sd;
    if (!::InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION))
    {
      throw MTErrorObjectException(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
    }

    if (!::SetSecurityDescriptorDacl(&sd, TRUE, (PACL)NULL, FALSE))
    {
      throw MTErrorObjectException(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
    }
    return &sa;
  }
public:
  NTMutex(const std::string& aName)
    :
    mMutex(0)
  {
    const char * functionName="NTMutex::NTMutex()";
    SECURITY_ATTRIBUTES sa;
    SECURITY_DESCRIPTOR sd;
    std::string name(aName);

    ::MakeUnique(name);

    // Make sure the mutex is global so that it works with terminal services.
    name.insert(0, "Global\\");
    mMutex = ::CreateMutexA(GetDefaultSecurityAttributes(sa, sd), FALSE, name.c_str());
    if(mMutex == 0)
    {
      throw MTErrorObjectException(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);      
    }
  }

  ~NTMutex()
  {
    if(mMutex == 0)
    {
      ::CloseHandle(mMutex);
      mMutex = 0;
    }
  }

  void Lock()
  {
    const char * functionName="NTMutex::Lock()";
    ASSERT(mMutex);
    DWORD waitResult = ::WaitForSingleObject(mMutex, INFINITE); 

    // No special case for abandon; it is ok if another process has yielded by croaking...
    if(waitResult != WAIT_OBJECT_0 && waitResult != WAIT_ABANDONED)
    {
      throw MTErrorObjectException(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);      
    }
  }

  void Unlock()
  {
    if (mMutex)
    {
      BOOL result = ::ReleaseMutex(mMutex);
      ASSERT(result);
    }
  }
};

#endif
