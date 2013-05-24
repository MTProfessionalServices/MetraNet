#pragma warning(disable : 4748)	// Disable warning /GS can not protect parameters...

#include <shlwapi.h>
#include <DbgHelp.h>
#include <tlhelp32.h>
#include <boost/thread/mutex.hpp>
#include <boost/lexical_cast.hpp>
#include "CallStack.h"


// The toolhelp API
// The API is single threaded, so we create a mutex to serialize access.
// We do run time dynamic linking to toolhelp so we can run in an environment
// without it.

class ToolHelpApi
{
public:

  typedef BOOL (__stdcall *STACKWALK64PROC)(DWORD, HANDLE, HANDLE,
                                            LPSTACKFRAME64, PVOID,
                                            PREAD_PROCESS_MEMORY_ROUTINE64,
                                            PFUNCTION_TABLE_ACCESS_ROUTINE64,
                                            PGET_MODULE_BASE_ROUTINE64,
                                            PTRANSLATE_ADDRESS_ROUTINE64);
  typedef PVOID (__stdcall *SYMFUNCTIONTABLEACCESS64PROC)(HANDLE, DWORD64);
  typedef DWORD64 (__stdcall *SYMGETMODULEBASE64PROC)(HANDLE, DWORD64);
  typedef BOOL (__stdcall *SYMCLEANUPPROC)(HANDLE);
  typedef BOOL (__stdcall *SYMGETSYMFROMADDR64PROC)(HANDLE, DWORD64,
                                                    PDWORD64, PIMAGEHLP_SYMBOL64);
  typedef BOOL (__stdcall *SYMGETLINEFROMADDR64PROC)(HANDLE, DWORD64, PDWORD,
                                                     PIMAGEHLP_LINE64);
  typedef BOOL (__stdcall *SYMINITIALIZEPROC)(HANDLE, PCTSTR, BOOL);
  typedef DWORD (__stdcall *SYMGETOPTIONSPROC)(void);
  typedef DWORD (__stdcall *SYMSETOPTIONSPROC)(DWORD);
  typedef BOOL (__stdcall *SYMGETSEARCHPATHPROC)(HANDLE, PTSTR, DWORD);
  typedef DWORD64 (__stdcall *SYMLOADMODULE64PROC)(HANDLE, HANDLE, PCSTR,
                                                   PCSTR, DWORD64, DWORD);
  typedef BOOL (__stdcall *SYMGETMODULEINFO64PROC)(HANDLE, DWORD64,
                                                   PIMAGEHLP_MODULE64);

  boost::mutex mToolHelpLock;

  STACKWALK64PROC mStackWalk64;
  SYMFUNCTIONTABLEACCESS64PROC mSymFunctionTableAccess64;
  SYMGETMODULEBASE64PROC mSymGetModuleBase64;
  SYMCLEANUPPROC mSymCleanup;
  SYMGETSYMFROMADDR64PROC mSymGetSymFromAddr64;
  SYMGETLINEFROMADDR64PROC mSymGetLineFromAddr64;
  SYMINITIALIZEPROC mSymInitialize;
  SYMGETOPTIONSPROC mSymGetOptions;
  SYMSETOPTIONSPROC mSymSetOptions;
  SYMGETSEARCHPATHPROC mSymGetSearchPath;
  SYMLOADMODULE64PROC mSymLoadModule64;
  SYMGETMODULEINFO64PROC mSymGetModuleInfo64;

  ToolHelpApi();
  ~ToolHelpApi();

  static ToolHelpApi& GetInstance();
  static void ReleaseInstance(ToolHelpApi&);

private:
  HMODULE mToolHelpDll;
};

ToolHelpApi::ToolHelpApi()
  :
  mStackWalk64(NULL),
  mSymFunctionTableAccess64(NULL),
  mSymGetModuleBase64(NULL),
  mSymCleanup(NULL),
  mSymGetSymFromAddr64(NULL),
  mSymGetLineFromAddr64(NULL),
  mSymInitialize(NULL),
  mSymGetOptions(NULL),
  mSymSetOptions(NULL),
  mSymGetSearchPath(NULL),
  mSymLoadModule64(NULL),
  mSymGetModuleInfo64(NULL),
  mToolHelpDll(NULL)
{
  mToolHelpDll = ::LoadLibrary(L"dbghelp.dll");
  if (mToolHelpDll)
  {
    mStackWalk64 = reinterpret_cast<STACKWALK64PROC>(::GetProcAddress(mToolHelpDll, "StackWalk64"));
    mSymFunctionTableAccess64 = reinterpret_cast<SYMFUNCTIONTABLEACCESS64PROC>(::GetProcAddress(mToolHelpDll, "SymFunctionTableAccess64"));
    mSymGetModuleBase64 = reinterpret_cast<SYMGETMODULEBASE64PROC>(::GetProcAddress(mToolHelpDll, "SymGetModuleBase64"));
    mSymCleanup = reinterpret_cast<SYMCLEANUPPROC>(::GetProcAddress(mToolHelpDll, "SymCleanup"));
    mSymGetSymFromAddr64 = reinterpret_cast<SYMGETSYMFROMADDR64PROC>(::GetProcAddress(mToolHelpDll, "SymGetSymFromAddr64"));
    mSymGetLineFromAddr64 = reinterpret_cast<SYMGETLINEFROMADDR64PROC>(::GetProcAddress(mToolHelpDll, "SymGetLineFromAddr64"));
    mSymInitialize = reinterpret_cast<SYMINITIALIZEPROC>(::GetProcAddress(mToolHelpDll, "SymInitialize"));
    mSymGetOptions = reinterpret_cast<SYMGETOPTIONSPROC>(::GetProcAddress(mToolHelpDll, "SymGetOptions"));
    mSymSetOptions = reinterpret_cast<SYMSETOPTIONSPROC>(::GetProcAddress(mToolHelpDll, "SymSetOptions"));
    mSymGetSearchPath = reinterpret_cast<SYMGETSEARCHPATHPROC>(::GetProcAddress(mToolHelpDll, "SymGetSearchPath"));
    mSymLoadModule64 = reinterpret_cast<SYMLOADMODULE64PROC>(::GetProcAddress(mToolHelpDll, "SymLoadModule64"));
    mSymGetModuleInfo64 = reinterpret_cast<SYMGETMODULEINFO64PROC>(::GetProcAddress(mToolHelpDll, "SymGetModuleInfo64"));
  }
}

ToolHelpApi::~ToolHelpApi()
{
  if (mToolHelpDll)
    ::FreeLibrary(mToolHelpDll);
}

ToolHelpApi& ToolHelpApi::GetInstance()
{
  static ToolHelpApi * sApi = NULL;
  static int sRefCount = 0;
  static boost::mutex sMutex;
  boost::mutex::scoped_lock lk(sMutex);
  if (0 == sRefCount++)
  {
    sApi = new ToolHelpApi();
  }
  return *sApi;
}

void ToolHelpApi::ReleaseInstance(ToolHelpApi & )
{
}

// A process with symbols
class Process
{
private:
  bool mIsValid;
  Process();
  ~Process();
public:
  static Process& GetInstance();
  static void ReleaseInstance(Process& process);

  bool IsValid() const
  {
    return mIsValid;
  }
};

class AutoToolHelpApi
{
private:
  ToolHelpApi& mToolHelp;
public:
  AutoToolHelpApi()
    :
    mToolHelp(ToolHelpApi::GetInstance())
  {
  }
  
  ~AutoToolHelpApi()
  {
    ToolHelpApi::ReleaseInstance(mToolHelp);
  }

  ToolHelpApi* operator->()
  {
    return &mToolHelp;
  }
};

class AutoToolhelpSnapshot
{
private:
  HANDLE mHandle;
public:
  AutoToolhelpSnapshot()
    :
    mHandle(INVALID_HANDLE_VALUE)
  {
    mHandle = ::CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, ::GetCurrentProcessId());
  }

  ~AutoToolhelpSnapshot()
  {
    if (mHandle != INVALID_HANDLE_VALUE)
      ::CloseHandle(mHandle);
  }

  operator HANDLE()
  {
    return mHandle;
  }
};

Process::Process()
  :
  mIsValid(false)
{
  AutoToolHelpApi toolHelp;

  HANDLE process = ::GetCurrentProcess();

  BOOL ret = toolHelp->mSymInitialize(process, NULL, FALSE);
  if (!ret) return;
  DWORD options = toolHelp->mSymGetOptions();
  options |= SYMOPT_LOAD_LINES;
  options |= SYMOPT_FAIL_CRITICAL_ERRORS;
  options |= SYMOPT_UNDNAME;
  options = toolHelp->mSymSetOptions(options);

  static const DWORD maxSearchPath = 1024;
  TCHAR buf[maxSearchPath] = {0};
  ret = toolHelp->mSymGetSearchPath(process, buf, maxSearchPath);
  if (!ret) return;

  AutoToolhelpSnapshot snapshot;
  if (snapshot == INVALID_HANDLE_VALUE) return;
  
  MODULEENTRY32W module;
  module.dwSize = sizeof(MODULEENTRY32W);
  ret = ::Module32FirstW(snapshot, &module);
  while (ret)
  {
    DWORD64 base;
    base = toolHelp->mSymLoadModule64(process,
                                     0,
                                     reinterpret_cast<PSTR>(module.szExePath),
                                     reinterpret_cast<PSTR>(module.szModule),
                                     reinterpret_cast<DWORD64>(module.modBaseAddr),
                                     module.modBaseSize);

    if (base == 0)
    {
      DWORD err = ::GetLastError();
      if (err != ERROR_MOD_NOT_FOUND && err != ERROR_INVALID_HANDLE)
        return;
    }

    ret = ::Module32NextW(snapshot, &module);
  }

  mIsValid = true;
}

Process::~Process()
{
}

Process& Process::GetInstance()
{
  static Process * sApi = NULL;
  static int sRefCount = 0;
  static boost::mutex sMutex;
  boost::mutex::scoped_lock lk(sMutex);
  if (0 == sRefCount++)
  {
    sApi = new Process();
  }
  return *sApi;
}

void Process::ReleaseInstance(Process & )
{
}

CallStack::CallStack()
  :
  mNumInstructionPointers(0),
  mToolHelp(ToolHelpApi::GetInstance())
{
  CONTEXT context;
  memset(&context, 0, sizeof(CONTEXT));
  context.ContextFlags = CONTEXT_FULL;
  __asm { call x };
    __asm x: pop eax
  __asm { mov context.Eip, eax };
  __asm { mov context.Ebp, ebp };
  __asm { mov context.Esp, esp };

  Init(context);
}

CallStack::CallStack(CONTEXT& context)
  :
  mNumInstructionPointers(0),
  mToolHelp(ToolHelpApi::GetInstance())
{
  Init(context);
}

CallStack::~CallStack()
{
  ToolHelpApi::ReleaseInstance(mToolHelp);
}

void CallStack::Init(CONTEXT& context)
{
  STACKFRAME64 frame;
  memset(&frame, 0, sizeof(STACKFRAME64));

#ifdef _M_IX86
  DWORD imageType = IMAGE_FILE_MACHINE_I386;
  frame.AddrPC.Offset    = context.Eip;
  frame.AddrPC.Mode      = AddrModeFlat;
  frame.AddrFrame.Offset = context.Ebp;
  frame.AddrFrame.Mode   = AddrModeFlat;
  frame.AddrStack.Offset = context.Esp;
  frame.AddrStack.Mode   = AddrModeFlat;
#elif
  a = b;
#endif

  HANDLE process = ::GetCurrentProcess();
  HANDLE thread = ::GetCurrentThread();

  for(unsigned int i=0; i<20; i++)
  {
    boost::mutex::scoped_lock sl(mToolHelp.mToolHelpLock);

    if (!mToolHelp.mStackWalk64(imageType,
                              process,
                              thread,
                              &frame,
                              &context,
                              0,
                              mToolHelp.mSymFunctionTableAccess64,
                              mToolHelp.mSymGetModuleBase64,
                              NULL))
      break;

    if (frame.AddrFrame.Offset == 0)
      continue;

    // Save the instruction pointer of the frame.
    mInstructionPointers[mNumInstructionPointers++] = (DWORD_PTR) (frame.AddrPC.Offset);
  }
}

void CallStack::ToString(std::string& msg)
{
  static const DWORD kStackWalkMaxNameLen(128);
  HANDLE process = ::GetCurrentProcess();

  Process& symbols(Process::GetInstance());
  if (!symbols.IsValid())
    return;

  // Walk the stack of instruction pointers and try to lookup symbol,
  for(std::size_t i=0; i<mNumInstructionPointers; i++)
  {
    boost::mutex::scoped_lock sl(mToolHelp.mToolHelpLock);
    std::string str;

    DWORD_PTR instructionPointer = mInstructionPointers[i];
    // Try to locate a symbol for this frame.
    DWORD64 symbolDisplacement = 0;
    ULONG64 buffer[(sizeof(IMAGEHLP_SYMBOL64) +
                    sizeof(TCHAR)*kStackWalkMaxNameLen +
                    sizeof(ULONG64) - 1) / sizeof(ULONG64)];
    IMAGEHLP_SYMBOL64* symbol = reinterpret_cast<IMAGEHLP_SYMBOL64*>(buffer);
    memset(buffer, 0, sizeof(buffer));
    symbol->SizeOfStruct = sizeof(IMAGEHLP_SYMBOL64);
    symbol->MaxNameLength = kStackWalkMaxNameLen;
    BOOL ret = mToolHelp.mSymGetSymFromAddr64(process,            
                                              instructionPointer,         
                                              &symbolDisplacement,       
                                              symbol);  
    if (ret)
    {
      // Try to get source info
      IMAGEHLP_LINE64 line;
      memset(&line, 0, sizeof(IMAGEHLP_LINE64));
      line.SizeOfStruct = sizeof(IMAGEHLP_LINE64);
      DWORD lineDisplacement;
      ret = mToolHelp.mSymGetLineFromAddr64(process,
                                            instructionPointer,
                                            &lineDisplacement,
                                            &line);
      if (ret)
      {
        str += static_cast<char*>(line.FileName);
        str += " (";
        str += boost::lexical_cast<std::string>(line.LineNumber);
        str += "): ";
        str += symbol->Name;
        str += "\n";
      }
      else
      {
        str += "unknown (0):";
        str += symbol->Name;
        str += "\n";
      }

    }
    else
    {
      IMAGEHLP_MODULE64 module;
      module.SizeOfStruct = sizeof(IMAGEHLP_MODULE64);
      if (mToolHelp.mSymGetModuleInfo64(process, 
                                        instructionPointer,
                                        &module)) {
        str += "(";
        str += static_cast<char*>(module.ModuleName);
        str += ")\n";
      } 
      else 
      {
        str += "???\n";
      }
    }
    msg += str;
  }
}

