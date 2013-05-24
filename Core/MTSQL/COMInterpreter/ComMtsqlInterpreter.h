// ComMtsqlInterpreter.h : Declaration of the CComMtsqlInterpreter

#ifndef __COMMTSQLINTERPRETER_H_
#define __COMMTSQLINTERPRETER_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <vector>

class MTSQLInterpreter;
class DispatchGlobalCompileEnvironment;
class DispatchGlobalRuntimeEnvironment;
class MTSQLExecutable;
class BatchQuery;

/////////////////////////////////////////////////////////////////////////////
// CComMtsqlInterpreter
class ATL_NO_VTABLE CComMtsqlInterpreter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CComMtsqlInterpreter, &CLSID_ComMtsqlInterpreter>,
	public IComMtsqlInterpreter,
	public IDispatch
{
public:
	CComMtsqlInterpreter()
	{
		mProgram = "CREATE PROCEDURE @a INTEGER AS SET @a = 190;";
		mInterpreter = NULL;
		mExecutable = NULL;
    mQuery = NULL;
    mIsQuery = false;
    mCurrentRequest = -1;
    mSupportVarchar = false;
	}

	~CComMtsqlInterpreter();

DECLARE_REGISTRY_RESOURCEID(IDR_COMMTSQLINTERPRETER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CComMtsqlInterpreter)
	COM_INTERFACE_ENTRY(IComMtsqlInterpreter)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IComMtsqlInterpreter
public:
	// IDispatch implementation
        HRESULT STDMETHODCALLTYPE GetTypeInfoCount( 
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT STDMETHODCALLTYPE GetTypeInfo( 
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT STDMETHODCALLTYPE GetIDsOfNames( 
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        HRESULT STDMETHODCALLTYPE Invoke( 
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);

private:
	_bstr_t mProgram;
  bool mIsQuery;
  unsigned int mCurrentRequest;
	MTSQLInterpreter *mInterpreter;
  BatchQuery * mQuery;
	std::vector<DispatchGlobalCompileEnvironment*> mCompileEnvironment;
	std::vector<DispatchGlobalRuntimeEnvironment*> mRuntimeEnvironment;
	MTSQLExecutable* mExecutable;
  bool mSupportVarchar;

  void Cleanup();
  void PushRequest();
};

#endif //__COMMTSQLINTERPRETER_H_
