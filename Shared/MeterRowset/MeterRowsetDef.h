// MeterRowsetDef.h : Declaration of the CMeterRowset

#ifndef __METERROWSET_H_
#define __METERROWSET_H_

#include "resource.h"       // main symbols

#include <string>
#include <map>
#include <list>
#include <vector>
#include <memory>

#include <NTLogger.h>
#include <ServicesCollection.h>

#import <COMMeter.tlb>
using COMMeterLib::ISessionPtr;
using COMMeterLib::ISessionSetPtr;
using COMMeterLib::IBatchPtr;

#import <rowsetinterfaceslib.tlb> rename("EOF", "RowsetEOF")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 
#import <MTEnumConfig.tlb>
#import <PipelineControl.tlb> rename( "EOF", "RowsetEOF" ) 
using RowSetInterfacesLib::IMTSQLRowsetPtr;

// the following are only needed by MetraTech.UsageServer.tlb
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib; using namespace ROWSETLib; using MTAuthInterfacesLib::IMTSessionContextPtr;")

class ColumnMapping
{
public:
	void Init(const wchar_t * apPropName, DataType aType, BOOL aRequired);

	DataType GetType() const
	{ return mType; }

	const wchar_t * GetPropName() const
	{ return mPropName.c_str(); }

	BOOL GetIsRequired() const
	{ return mRequired; }


private:
	// MSIX property type
	DataType mType;

	// MSIX property name
	std::wstring mPropName;

	// if true, value must not be NULL in the rowset
	BOOL mRequired;
};

class CommonProp
{
public:
	void Init(const wchar_t * apPropName, DataType aType, _variant_t aValue);

	DataType GetType() const
	{ return mType; }

	const wchar_t * GetPropName() const
	{ return mPropName.c_str(); }

	const _variant_t & GetValue() const
	{ return mValue; }

private:
	// MSIX property type
	DataType mType;

	// MSIX property name
	std::wstring mPropName;

	// supplied value
	_variant_t mValue;
};


struct ChildInfo
{ 
 	::IMTSQLRowsetPtr rowset; 
	std::wstring serviceName;
};
 


/////////////////////////////////////////////////////////////////////////////
// CMeterRowset
class ATL_NO_VTABLE CMeterRowset : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMeterRowset, &CLSID_MeterRowset>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMeterRowset, &IID_IMeterRowset, &LIBID_METERROWSETLib>
{
public:
	CMeterRowset() : mMeterErrorCount(0), mMeteredCount(0)
	{
		m_pUnkMarshaler = NULL;
		mpBatch = NULL;
	}

	~CMeterRowset();

DECLARE_REGISTRY_RESOURCEID(IDR_METERROWSET)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMeterRowset)
	COM_INTERFACE_ENTRY(IMeterRowset)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	STDMETHOD(FinalConstruct)();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMeterRowset
public:
	STDMETHOD(InitSDK)(BSTR aServerAccess);
	STDMETHOD(InitForService)(BSTR serviceName);

	STDMETHOD(GenerateBatchID)(/*[out, retval]*/ BSTR * apBatchID);
	STDMETHOD(get_BatchID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_BatchID)(/*[in]*/ BSTR newVal);

	STDMETHOD(get_SessionSetSize)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_SessionSetSize)(/*[in]*/ long newVal);

	STDMETHOD(AddColumnMapping)(BSTR aColumnName, DataType aPropType, BSTR aPropName, VARIANT_BOOL aRequired);
	STDMETHOD(AddChildColumnMapping)(BSTR aColumnName, DataType aPropType, BSTR aPropName, VARIANT_BOOL aRequired, BSTR aServiceName);
  STDMETHOD(AddChildRowset)(::IMTSQLRowset * apRowset, BSTR aServiceName);
	STDMETHOD(AddCommonProperty)(BSTR aName, DataType aType, VARIANT aValue);

	STDMETHOD(MeterRowset)(::IMTSQLRowset * apRowset);
	STDMETHOD(WaitForCommitWithPause)(/*[in]*/ long lExpectedCommitCount, /*[in]*/ long lTimeOutInSeconds, /*[in]*/ long lpause);
	STDMETHOD(WaitForCommit)(/*[in]*/ long lExpectedCommitCount, /*[in]*/ long lTimeOutInSeconds);
	STDMETHOD(WaitForCommitEx)(/*[in]*/ long lExpectedCommitCount, /*[in]*/ long lTimeOutInSeconds, /*[in]*/ BSTR BatchName, /*[in]*/ BSTR BatchNamespace, /*[in]*/ BSTR BatchSeqNum);

	STDMETHOD(get_MeterErrorCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_MeteredCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_CommittedCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_CommittedSuccessCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_CommittedErrorCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(CreateAdapterBatch)(/*[in]*/ long RunID, 
																/*[in]*/ BSTR AdapterName, 
																/*[in]*/ BSTR SequenceNumber, 
																/*[out, retval]*/ IBatch** pNewBatch);
	STDMETHOD(CreateAdapterBatchEx)(/*[in]*/ long RunID, 
																	/*[in]*/ BSTR AdapterName, 
																	/*[in]*/ BSTR SequenceNumber, 
																	/*[out, retval]*/ IBatch** pNewBatch);

  STDMETHOD(InitializeFromRowset)(::IMTSQLRowset * apRowset, BSTR aServiceName);
  STDMETHOD(MeterPopulatedRowset)();
  STDMETHOD(get_ServiceDefinition)(/*[out, retval]*/ BSTR *pVal);

	STDMETHOD(PopulateSession)(ISession * session, ::IMTSQLRowset *apRowset);

  STDMETHOD(put_TransactionID)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_ListenerTransactionID)(/*[in]*/ BSTR newVal);

  STDMETHOD(put_MeterSynchronously)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_MeterSynchronously)(/*[out, retval]*/ VARIANT_BOOL *pVal);

  STDMETHOD(put_SyncMeteringRetries)(/*[in]*/ long newVal);
  STDMETHOD(get_SyncMeteringRetries)(/*[out, retval]*/ long* pVal);
  
  STDMETHOD(put_SyncMeteringRetrySleepInterval)(/*[in]*/ long newVal);
  STDMETHOD(get_SyncMeteringRetrySleepInterval)(/*[out, retval]*/ long* pVal);

private:
	typedef std::map<std::wstring, ColumnMapping> ColumnMap;
	typedef std::vector<const ColumnMapping *> ColumnMappingVector;
	typedef std::map<std::wstring, ColumnMap *> ServiceColumnMap;
	typedef std::vector<ChildInfo> ChildInfoVector;
	typedef std::list<CommonProp> CommonPropList;

private:
	const ColumnMapping * GetColumnMapping(const wchar_t * apColumn, const wchar_t * apService);
	HRESULT AddColumnMappingsFromService(const std::wstring& aServiceName);
	HRESULT AddColumnMapping(BSTR aColumnName, DataType aPropType, BSTR aPropName,
													 VARIANT_BOOL aRequired, const std::wstring& aServiceName);

	//throws
	void AddRowToSession(ISessionPtr& apSession, const ::IMTSQLRowsetPtr& apRowset, const ColumnMappingVector& arColumnMappings);
	void AddCommonPropsToSession(ISessionPtr& arSession, bool aIsChild);

	void AttemptSessionSetClose(ISessionSetPtr& arSessionSet); 
 

	wstring ConvertSessionIDToString(const unsigned char * apSessionID);

	unsigned long PopulateSession(ISessionPtr parentSession,
																::IMTSQLRowsetPtr parentRowset,
																ColumnMappingVector parentColumnMappings,
																std::vector<const ColumnMappingVector*> childColumnMappingsColl);

  bool inline IsTransactionSet() {return mTransactionID.length() > 0;}
  bool inline IsListenerTransactionSet() {return mListenerTransactionID.length() > 0;}

private:
	long mMeterErrorCount;
	long mMeteredCount;

	long mCommittedErrorCount;
	long mCommittedSuccessCount;

	long mSessionSetSize;

	ServiceColumnMap mServiceColumnMap;
	CommonPropList mCommonPropList;
	ChildInfoVector mChildRowsets;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	COMMeterLib::IMeterPtr mMeter;
	IBatchPtr mpBatch;

	std::wstring mServiceName;
	_bstr_t		 mBatchID;

	CServicesCollection mServices;

	// message logger
	NTLogger mLogger;

  _bstr_t mTransactionID;
  _bstr_t mListenerTransactionID;

  bool mbSync;
  long mlSyncRetries;
  long mlSyncSleep;

  //InitializeFromRowset and MeterPolulatedRowset methods
  ::IMTSQLRowsetPtr mRowset;
};

#endif //__METERROWSET_H_
