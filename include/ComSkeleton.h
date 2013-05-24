#ifndef __COMSKELETON_H__
#define __COMSKELETON_H__

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0500
#endif

#define _ATL_APARTMENT_THREADED

//BP: temporarily disable warning for deprecated methods
#pragma warning(disable : 4996)

//#include <metra.h>
#include <windows.h>
#ifndef ASSERT
#include <crtdbg.h>
#define ASSERT _ASSERT
#define ASSERTE _ASSERTE
#endif
#include <mtcom.h>

#include <atlbase.h>
//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>
#include "SkeletonLib.h"


#define MT_INTERFACE_ENTRY(a,b) \
  	{a, \
	offsetofclass(b, _ComMapClass), \
	_ATL_SIMPLEMAPENTRY}, \


template <class T, class IImplementedInterface,
  const CLSID* pclsid,const CLSID* aIID,
#ifdef MT_SUPPORT_IDispatch
  const CLSID* aLIBID,
#endif
  class ThreadModel = CComMultiThreadModel>

class ATL_NO_VTABLE MTImplementedInterface : 
	public CComObjectRootEx<ThreadModel>,
	public CComCoClass<T, pclsid>,
	public ISupportErrorInfo,

#ifdef MT_SUPPORT_IDispatch
		public IDispatchImpl<IImplementedInterface,aIID,aLIBID>
#else
	public IImplementedInterface
#endif
{
public:
  MTImplementedInterface() 
  {
    ASSERT(pclsid);
  }

BEGIN_COM_MAP(T)
  MT_INTERFACE_ENTRY(aIID,IImplementedInterface)
#ifdef MT_SUPPORT_IDispatch
	COM_INTERFACE_ENTRY(IDispatch)
#endif
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()


	// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid)
	{
		if (InlineIsEqualGUID(*aIID, riid))
			return S_OK;
		else
			return S_FALSE;
	}

	

	static HRESULT WINAPI UpdateRegistry(BOOL bRegister)
	{
		if (bRegister)
			return RegisterPlugInClassHelper(_Module.m_hInst,
																			 GetObjectCLSID(),
																			 _PlugInProgId,
																			 _PlugInVersionIndProgId,
																			 _PlugInThreadModelString);
		else
			return _Module.UnregisterClassHelper(GetObjectCLSID(),
																					 _PlugInProgId, _PlugInVersionIndProgId);
	}

};

//
// globals that must be defined by your plug-in
//
extern __declspec(selectany) TCHAR  _PlugInProgId[];
extern __declspec(selectany) TCHAR  _PlugInVersionIndProgId[];
extern __declspec(selectany) TCHAR  _PlugInThreadModelString[];

// PLUGIN_OBJECT_MAP defines this for you
extern _ATL_OBJMAP_ENTRY * _PlugInObjectMap;

//
// a macro to help defining the object map holding a single.
// example of use:
//     PLUGIN_OBJECT_MAP(CLSID_SimplePlugIn, MTSimplePlugIn)
//
#define PLUGIN_OBJECT_MAP(classid, classname)		\
BEGIN_OBJECT_MAP(ObjectMap)											\
	OBJECT_ENTRY(classid, classname)							\
END_OBJECT_MAP()																\
_ATL_OBJMAP_ENTRY * _PlugInObjectMap = ObjectMap;

//
// a macro to help you define your progids and thread model
// example of use:
//     PLUGIN_PROGIDS("MetraPipeline.SimplePlugIn.1",
//                    "MetraPipeline.SimplePlugIn",
//                    "Free")
//
#define PLUGIN_PROGIDS(progid, viprogid, thread)	\
__declspec(selectany) TCHAR _PlugInProgId[] = _T(progid);								\
__declspec(selectany) TCHAR _PlugInVersionIndProgId[] = _T(viprogid);		\
__declspec(selectany) TCHAR _PlugInThreadModelString[] = _T(thread);

//
// a combination of PLUGIN_OBJECT_MAP and PLUGIN_PROGIDS
// example of use:
//     PLUGIN_INFO(CLSID_SimplePlugIn, MTSimplePlugIn,
//                 "MetraPipeline.SimplePlugIn.1",
//                 "MetraPipeline.SimplePlugIn",
//                 "Free")
// 
#define PLUGIN_INFO(classid, classname, progid, viprogid, thread)	\
  PLUGIN_OBJECT_MAP(classid, classname)														\
  PLUGIN_PROGIDS(progid, viprogid, thread)

#endif // __COMSKELETON_H__
