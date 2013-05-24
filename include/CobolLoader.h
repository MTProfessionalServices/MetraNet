#ifndef __COBOLLOADER_H__
#define __COBOLLOADER_H__
#pragma once
#include <tchar.h>




template <class EntryPoint,char* FuncName>
class MTCobolLoader {
public:
  MTCobolLoader() : mModule(NULL), mFunc(NULL) {}
  virtual ~MTCobolLoader();
  bool Init(TCHAR* pDllStr);

protected:
  HMODULE mModule;
  EntryPoint mFunc;
};

template <class EntryPoint,char* FuncName>
bool MTCobolLoader<EntryPoint,FuncName>::Init(TCHAR* pDllStr)
{
 mModule = LoadLibrary(pDllStr);
  if(mModule != NULL)  {
    FARPROC aProc;

    char* pFuncName = FuncName;
    aProc = GetProcAddress(mModule,FuncName);
    mFunc = (EntryPoint)aProc;
    return true;
  }
  else {
   return false;
  }
}

template <class EntryPoint,char* FuncName>
MTCobolLoader<EntryPoint,FuncName>::~MTCobolLoader<EntryPoint,FuncName>()
{
  // Freeing the library causing the app to crash
  if(mModule) {
    FreeLibrary(mModule);
  }
}



#endif //__COBOLLOADER_H__