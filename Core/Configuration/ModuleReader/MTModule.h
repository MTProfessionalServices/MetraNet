// MTModule.h : Declaration of the CMTModule

#ifndef __MTMODULE_H_
#define __MTMODULE_H_

#include "resource.h"       // main symbols

#import <mtmodulereader.tlb>

#include <errobj.h>
#include <NTLogger.h>
#include <autologger.h>
#include <vector>

using std::vector;

namespace {
	char ModuleLogTag[] = "ModuleReader";
}


#import <MTConfigLib.tlb>
using namespace MTConfigLib;


/////////////////////////////////////////////////////////////////////////////
//typedef CComModule<IMTSubModule> IMTSubModulePtr;

/*
template <class T>
  class SmartPointerContainer {

};
 template<class T> bool operator==(const SmartPointerContainer<T> p,const SmartPointerContainer<T> p2) { return true; } 
typedef SmartPointerContainer<MODULEREADERLib::IMTSubModulePtr> SubModPtr;
*/

typedef MODULEREADERLib::IMTModuleDescriptorPtr IMTModuleDescriptorPtr;
typedef MODULEREADERLib::IMTModulePtr IMTModulePtr;
bool operator==(IMTModuleDescriptorPtr a,IMTModuleDescriptorPtr b);


/////////////////////////////////////////////////////////////////////////////
// CMTModule
class ATL_NO_VTABLE CMTModule : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTModule, &CLSID_MTModule>,
	public ISupportErrorInfo,
  public IDispatchImpl<IMTModule, &IID_IMTModule, &LIBID_MODULEREADERLib>,
  public ObjectWithError
{
public:
	CMTModule();
  virtual ~CMTModule();

DECLARE_REGISTRY_RESOURCEID(IDR_MTMODULE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTModule)
  COM_INTERFACE_ENTRY(IMTModule)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTModule
public: // generated code
	STDMETHOD(RemoveAllSubModules)();
	STDMETHOD(get_AbsolutePath)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_AbsolutePath)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ModuleDataPath)(/*[out, retval]*/ BSTR* pVal);
  STDMETHOD(put_ModuleDataPath)(/* [in] */ BSTR newVal);
	STDMETHOD(get_Item)(/*[in]*/ long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_RemoteHost)(/*[in]*/ BSTR* pVal);
	STDMETHOD(put_RemoteHost)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ModuleDataFileName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ModuleDataFileName)(/*[in]*/ BSTR newVal);
  STDMETHOD(WriteSet)(/*[in]*/ ::IMTConfigPropSet* pSet);
	STDMETHOD(GetSubModuleByIndex)(/*[in]*/ long aIndex,/*[out,retval]*/ IMTModule** ppMod);
	STDMETHOD(put_ModDescriptor)(/*[in]*/ IMTModuleDescriptor* newVal);
	STDMETHOD(Write)();
  STDMETHOD(ReadSet)(/*[in]*/ ::IMTConfigPropSet* pSet);
	STDMETHOD(Read)();
  STDMETHOD(get_ModuleSpecificInfo)(/*[out, retval]*/ ::IMTConfigPropSet** pVal);
  STDMETHOD(put_ModuleSpecificInfo)(/*[out, retval]*/ ::IMTConfigPropSet* pVal);
	STDMETHOD(get_ConfigFile)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ConfigFile)(/*[out, retval]*/ BSTR pVal);
  STDMETHOD(GetSubModule)(/*[in]*/ BSTR aName, /*[out]*/ ::IMTModule** ppSubMod);
  STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR Val);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);

protected: // methods
  BOOL ProcessModuleFile(IMTConfigPropSetPtr&,bool FromFile = true);
  BOOL WriteModuleFile(IMTConfigPropSetPtr&);
  BOOL ProcessSubset(IMTConfigPropSetPtr&);
  BOOL GetSubModuleInternal(long aIndex,::IMTModule**);
  BOOL GetModuleInSubDir(_bstr_t&,MODULEREADERLib::IMTModule**);
  void GetFullModName(_bstr_t&,_bstr_t&);
  BOOL CreateDirPath(const _bstr_t&,_bstr_t&);

protected: // data
  vector<IMTModuleDescriptorPtr > mSubModuleList;
  bstr_t mFileName;
  bstr_t mRemoteHost;
  bstr_t mName;
  bstr_t mFilePath;
  bstr_t mConfigFile;
  MTAutoInstance<MTAutoLoggerImpl<ModuleLogTag> >			mLogger;
  MTConfigLib::IMTConfigPropSetPtr mModSpecific;
  MTConfigLib::IMTConfigPropSetPtr mpMainMod;
	_variant_t mbAbsolutePath;

  _variant_t* mpVariantList;

};

#endif //__MTMODULE_H_
