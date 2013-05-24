// COMUsageServer.h : Declaration of the CCOMUsageServer

#ifndef __COMUSAGESERVER_H_
#define __COMUSAGESERVER_H_

// disable warning ...
#pragma warning( disable : 4786)

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <UsageServerConstants.h>

#include <vector>
#include <map>
#include <string>

#import <MTDataExporter.tlb> no_namespace
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 
#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )

class AdapterInfo;
class CycleTypeAdapterInfo;

// typedefs ...
typedef std::vector<AdapterInfo *> AdapterColl;
typedef std::vector<AdapterInfo *>::iterator AdapterCollIter;

typedef std::vector<AdapterColl> AdapterCollList;
typedef std::vector<AdapterColl>::iterator AdapterCollListIter;
typedef std::vector<AdapterColl>::const_iterator AdapterCollListConstIter;

typedef std::map<std::wstring, CycleTypeAdapterInfo *>	CycleTypeAdapterColl;
typedef std::map<std::wstring, CycleTypeAdapterInfo *>::iterator	CycleTypeAdapterCollIter;

class CycleTypeAdapterInfo
{
public:
  CycleTypeAdapterInfo() : mNumGroups(0) {};
  ~CycleTypeAdapterInfo() { mList.clear(); };

  void AddAdapterColl (AdapterColl &arAdapterColl) 
  { mList.push_back (arAdapterColl); mNumGroups++;};
  AdapterColl & GetAdapterColl(const int &arGroupNum);

	int CountAdapters() const
	{
		unsigned int count = 0;
		for (AdapterCollListConstIter it = mList.begin(); it != mList.end(); it++)
		{
			// TODO: this is very inefficient
			count += (*it).size();
		}
		return (int) count;
	}

private:
  long    mNumGroups;
  AdapterCollList mList;
  AdapterColl mNullColl;
};

inline AdapterColl & CycleTypeAdapterInfo::GetAdapterColl(const int &arGroupNum) 
{ 
  if (arGroupNum < mNumGroups)
  {
    return mList[arGroupNum]; 
  }
  else
  {
    return mNullColl;
  }
} 

class AdapterInfo
{
public:
  AdapterInfo(IMTDataExporterPtr& arAdapter, const _bstr_t &arAdapterName,
							const int &arRunID) 
		: mpAdapter1(arAdapter),
			mpAdapter2(NULL),
			mName (arAdapterName), 
			mRunID (arRunID),
			mVersion(1),
			mSuccessful(TRUE)
	{}

  AdapterInfo(IMTDataExporter2Ptr& arAdapter2, const _bstr_t &arAdapterName,
							const int &arRunID) 
		: mpAdapter2(arAdapter2),
			mpAdapter1(NULL),
			mName (arAdapterName), 
			mRunID (arRunID),
			mVersion(2),
			mSuccessful(TRUE)
	{}

  AdapterInfo(IMTDataExporter2Ptr& arAdapter2, const _bstr_t &arAdapterName,
							const int &arRunID, const _bstr_t &arAdapterProgId, const _bstr_t &arAdapterConfigFile) 
		: mpAdapter2(arAdapter2),
			mpAdapter1(NULL),
			mName (arAdapterName), 
      mProgID (arAdapterProgId),
      mConfigFile (arAdapterConfigFile),
			mRunID (arRunID),
			mVersion(2),
			mSuccessful(TRUE)
	{}

  ~AdapterInfo() {}

  IMTDataExporterPtr& GetAdapterV1()
  {return mpAdapter1;}
  IMTDataExporter2Ptr& GetAdapterV2()
  {return mpAdapter2;}
  long GetVersion() const
  {return mVersion;}

  const int GetRecurringEventRunID() const
  { return mRunID;}
  const _bstr_t GetAdapterName() const
  { return mName;}
  const BOOL IsSuccessful() const
  { return mSuccessful; }
  void MarkAsFailed()
  { mSuccessful = FALSE;}


private:
  AdapterInfo();

  _bstr_t mName;
  _bstr_t mProgID;
  _bstr_t mConfigFile;

  int     mRunID;
  IMTDataExporterPtr  mpAdapter1;
  IMTDataExporter2Ptr mpAdapter2;
  BOOL    mSuccessful;
	long mVersion;
};

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageServer
class ATL_NO_VTABLE CCOMUsageServer : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageServer, &CLSID_COMUsageServer>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMUsageServer, &IID_ICOMUsageServer, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageServer();
  virtual ~CCOMUsageServer();

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGESERVER)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUsageServer)
	COM_INTERFACE_ENTRY(ICOMUsageServer)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageServer
public:
	STDMETHOD(InvokeAdapterForInterval)(BSTR aProgId, BSTR aDisplayName, long aIntervalID, BSTR aConfigFile);
	STDMETHOD(SetUsageIntervalState)(/*[in]*/ long aIntervalID, /*[in]*/ MTUsageIntervalState aNewState);
  STDMETHOD(RerunRecurringEvent)(long aRunID, VARIANT_BOOL aFullRun);
	STDMETHOD(DoRecurringEvent)(BSTR aUsageCyclePeriodType, MTRecurringEvent aEvent);
	STDMETHOD(GetAccountUsageMap)(long aAccountID, /*[out,retval]*/ LPDISPATCH *apAccountUsageMap);
	STDMETHOD(GetUsageCycleTypes)(/*[out,retval]*/ LPDISPATCH *apUsageCycleTypes);
	STDMETHOD(GetUsageCycles)(/*[out,retval]*/ LPDISPATCH *apUsageCycles);
	STDMETHOD(GetUsageIntervals)(BSTR aStatus,/*[out,retval]*/ LPDISPATCH *apUsageIntervals);
	STDMETHOD(AddPCIntervals)(DATE aStart, DATE aEnd);

private:

  HRESULT GetIntervalStateStringForDatabase (MTUsageIntervalState aState, _bstr_t &aStateString);

  HRESULT GetUsageIntervalCollection (const _bstr_t &arState, 
    const _bstr_t &arPeriodType,ICOMUsageIntervalColl * & arpUIColl);

  HRESULT ReadRecurringEventFile (const _bstr_t &arPeriodTag, 
    const _bstr_t &arEventPeriod, const long &arIntervalID, const _bstr_t &arState, 
    const _bstr_t &arPeriodType, const std::wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset,
    CycleTypeAdapterColl &arPerAccount, CycleTypeAdapterColl &arPerInterval, long &arNumGroups);
  
  HRESULT UpdateUsageIntervalStatus (const _bstr_t &arNextState, 
    const long &arIntervalID, ICOMUsageIntervalColl * & arpUIColl);

  HRESULT GetAccountUsageMapForInterval (const long &arIntervalID,
    ICOMUsageIntervalColl * & arpUIColl, ICOMAccountUsageMap * & arpAcctMap);

  HRESULT InvokeAdapterExportData (CycleTypeAdapterColl &arCycleTypeAdapterColl, 
    std::wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset, const long &arAcctID, 
    const long &arIntervalID, COMDBOBJECTSLib::ICOMSummaryViewPtr &arpSummaryView, const long &arGroupNum);

  HRESULT InvokeAdapterExportComplete (CycleTypeAdapterColl &arCycleTypeAdapterColl, 
    std::wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset, const long &arIntervalID, 
    const long &arGroupNum);

  HRESULT InvokeAdapterExecute(CycleTypeAdapterColl &arPerInterval, 
		std::wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset,
															 const long &arIntervalID, const long &arGroupNum);
  
  NTLogger          mLogger;
};

#endif //__COMUSAGESERVER_H_
