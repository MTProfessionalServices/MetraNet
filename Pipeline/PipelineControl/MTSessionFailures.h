// MTSessionFailures.h : Declaration of the CMTSessionFailures

#ifndef __MTSESSIONFAILURES_H_
#define __MTSESSIONFAILURES_H_

#include <metra.h>
#include "resource.h"       // main symbols

#include <mtprogids.h>

#import <MTConfigLib.tlb>

#include <string>

#include <errobj.h>
#include <sessionerr.h>

#include <msmqlib.h>

#include <NTLogger.h>

#import <PipelineControl.tlb> rename("EOF", "RowsetEOF")

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTPipelineLibExt.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Pipeline.Messages.tlb> inject_statement("using namespace mscorlib;")
#import <COMMeter.tlb>
#import <GenericCollection.tlb>

#include <dbparser.h>

#include <OdbcConnMan.h>
#include <OdbcResultSet.h>
#include <OdbcStatement.h>
#include <OdbcSessionTypeConversion.h>

typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;

class CMSIXDefinition;
class CMSIXProperties;
class ISessionFailuresStrategy;

typedef vector<SessionErrorObject *> ErrorObjectList;

/////////////////////////////////////////////////////////////////////////////
// CMTSessionFailures
class ATL_NO_VTABLE CMTSessionFailures : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSessionFailures, &CLSID_MTSessionFailures>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSessionFailures, &IID_IMTSessionFailures, &LIBID_PIPELINECONTROLLib>
{
public:
	CMTSessionFailures();

	HRESULT FinalConstruct();

	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSIONFAILURES)

BEGIN_COM_MAP(CMTSessionFailures)
	COM_INTERFACE_ENTRY(IMTSessionFailures)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSessionFailures
public:
	STDMETHOD(Refresh)();
	STDMETHOD(AbandonSession)(BSTR sessionID, /*[in, optional]*/ VARIANT txn);
	STDMETHOD(AbandonLostSession)(BSTR sessionID);
	STDMETHOD(ResubmitSession)(BSTR sessionID);
	STDMETHOD(ResubmitLostSession)(BSTR sessionID);
  STDMETHOD(Login)(BSTR login, BSTR login_namespace, BSTR password);
  STDMETHOD(put_SessionContext)(IMTSessionContext * apSessionContext);
	// automation methods
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Item)(VARIANT aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

	//
	// statics - used here and in MTSessionError
	//
public:

	static HRESULT SaveXMLMessage(BSTR sessionID,
																const char * apMessage,
																GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete);
	static HRESULT LoadXMLMessage(BSTR sessionID, std::string & arMessage,
																PIPELINECONTROLLib::IMTTransactionPtr txn);
	static BOOL HasSavedXMLMessage(BSTR sessionID,
																 PIPELINECONTROLLib::IMTTransactionPtr);
	static HRESULT DeleteSavedXMLMessage(BSTR sessionID,
																			 PIPELINECONTROLLib::IMTTransactionPtr);

private:
	HRESULT Init();


	void ClearErrors();

	static bool IsDBQueueModeEnabled();
	static ISessionFailuresStrategy* NewDBSessionFailures();

private:
	ErrorObjectList mErrorObjects;

	NTLogger mLogger;

	// login context
	MTPipelineLibExt::IMTSessionContextPtr mSessionContext;

	BOOL mIsOracle;

    BOOL mDBQueuesUsed;

	// queue-mode specific calls are delegated to the appropriate strategy
	ISessionFailuresStrategy* mSessionFailures;
};


class ISessionFailuresStrategy
{
public:
	virtual HRESULT Refresh(ErrorObjectList& failures) = 0;

	virtual HRESULT ResubmitSuspendedMessage(BSTR messageID) = 0;
	virtual HRESULT DeleteSuspendedMessage(BSTR messageID) = 0;

	virtual SessionErrorObject * FindError(const wchar_t * apLabel) = 0;

	virtual HRESULT SaveXMLMessage(BSTR sessionID,
																 const char * apMessage,
																 GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete) = 0;

	virtual bool    HasSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr) = 0;
	virtual HRESULT LoadXMLMessage(BSTR sessionID,
																 std::string & arMessage,
																 PIPELINECONTROLLib::IMTTransactionPtr txn) = 0;
	virtual HRESULT DeleteSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr) = 0;
};


class MSMQSessionFailures : public ISessionFailuresStrategy
{
public:
	// default constructor used by static Load/SaveXML*methods
	MSMQSessionFailures() : mLogger(NULL) { };
	MSMQSessionFailures(PipelineInfo & pipelineInfo, NTLogger * logger);

	virtual HRESULT Refresh(ErrorObjectList & failures);
	virtual HRESULT ResubmitSuspendedMessage(BSTR messageID);
	virtual HRESULT DeleteSuspendedMessage(BSTR messageID);
	virtual SessionErrorObject * FindError(const wchar_t * apLabel);

	virtual HRESULT SaveXMLMessage(BSTR sessionID,
																 const char * apMessage,
																 GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete);

	virtual bool    HasSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr);
	virtual HRESULT LoadXMLMessage(BSTR sessionID,
																 std::string & arMessage,
																 PIPELINECONTROLLib::IMTTransactionPtr txn);
	virtual HRESULT DeleteSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr);

private:

	enum FailedSessionState
	{
		STATE_DELETED,
		STATE_RESUBMITTED,
	};

private:

	HRESULT InitErrorQueue(MessageQueue & arQueue);

	HRESULT InitQueue(MessageQueue & arQueue,
										const wchar_t * apMachine,
										const wchar_t * apQueueName);

	HRESULT RemoveFromErrorQueue(const wchar_t * apSessionID,
															 PIPELINECONTROLLib::IMTTransactionPtr aTxn);

	HRESULT RemoveFromAuditQueue(const wchar_t * apMachine,
															 const wchar_t * apQueueName,
															 const wchar_t * apSessionID);

	HRESULT HandleErrorMessage(const wchar_t * apLabel,
														 const char * apBody, int aBodySize,
														 ErrorObjectList& failures);

	HRESULT InternalAbandonSession(BSTR sessionID, BOOL aDeleteError,
																 BOOL aDeleteFromRQ,
																 PIPELINECONTROLLib::IMTTransactionPtr aTxn);

	HRESULT InternalResubmitSession(BSTR sessionID, BOOL aRemoveFromError,
																	BOOL aRemoveFromRQ,
																	PIPELINECONTROLLib::IMTTransactionPtr aTxn);

	HRESULT RetrieveErrorObject(const wchar_t * apLabel,
															SessionErrorObject & arError);

	HRESULT InitializeMessageUtils();

	HRESULT MarkFailure(const wchar_t * apUID,
											FailedSessionState aState,
											PIPELINECONTROLLib::IMTTransactionPtr aTxn);

private:
	NTLogger* mLogger;
	
	BOOL mUsePrivateQueues;

	std::wstring mMachineName;
	std::wstring mQueueName;

	std::wstring mResubmitQueueName;
	std::wstring mResubmitQueueMachine;

	MetraTech_Pipeline_Messages::IMessageUtilsPtr mMessageUtils;
	BOOL mUtilsInitialized;
};



template <class _InsertStmt>
class DBSessionFailures : public ISessionFailuresStrategy
{
public:
	DBSessionFailures<_InsertStmt>(BOOL aIsOracle);

	virtual HRESULT Refresh(ErrorObjectList& failures);
	virtual HRESULT ResubmitSuspendedMessage(BSTR messageID);
	virtual HRESULT DeleteSuspendedMessage(BSTR messageID);
	virtual SessionErrorObject * FindError(const wchar_t * apLabel);

	virtual HRESULT SaveXMLMessage(BSTR sessionID,
																 const char * apMessage,
																 GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete);

	virtual bool HasSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr)
	{
		// in 4.0 there is never an explicit saved message
		// the source message (t_svc) is updated directly
		return true;
	}

	// always reloads the message from the t_svc table
	virtual HRESULT LoadXMLMessage(BSTR sessionID,
		std::string & arMessage,
		PIPELINECONTROLLib::IMTTransactionPtr txn);

	//
  // OBSOLETE as of v4.0
	//
	virtual HRESULT DeleteSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr)
	{
		// it is impossible to delete the saved XML since
		// we don't keep track of the original like before
		return E_NOTIMPL;
	}


private:
  SessionErrorObject * GetErrorObjectFromDB(COdbcConnectionPtr conn, 
																						const wchar_t * apLabel);

  HRESULT GetErrorObjectsFromDB(COdbcConnectionPtr conn, 
																ErrorObjectList & failures)
	{
		return GetErrorObjectsFromDB(conn, L"", failures);
	}

  HRESULT GetErrorObjectsFromDB(COdbcConnectionPtr conn, 
																const std::wstring & filterClause,
																ErrorObjectList & failures);
	
  bool GenerateMSIXFromDB(COdbcConnectionPtr conn, 
													SessionErrorObject * apErrObj,
													int parentServiceDefID,
													std::map<vector<unsigned char>, int> & children);


private:
	enum { UID_LENGTH = 16 };

  // the following are lazily initialized when GenerateMSIXFromDB is first called
	bool mGenerateMSIXInitialized;
	BOOL mIsOracle;
  CServicesCollection mServices;
	COMMeterLib::IMeterPtr mMeter;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  NAMEIDLib::IMTNameIDPtr mNameID; 
  CMTCryptoAPI mCrypto;


	NTLogger mLogger;

};

#endif //__MTSESSIONFAILURES_H_
