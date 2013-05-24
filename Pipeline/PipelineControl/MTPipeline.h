// MTPipeline.h : Declaration of the CMTPipeline

#ifndef __MTPIPELINE_H_
#define __MTPIPELINE_H_

#include "resource.h"       // main symbols

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Pipeline.Messages.tlb> inject_statement("using namespace mscorlib;")

#import <MTConfigLib.tlb>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTPipelineLibExt.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#include <NTLogger.h>
#include <pipelineconfig.h>
#include <generate.h>
#include <NTThreadLock.h>
#include <comsingleton.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

/////////////////////////////////////////////////////////////////////////////
// CMTPipeline
class ATL_NO_VTABLE CMTPipeline : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPipeline, &CLSID_MTPipeline>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPipeline, &IID_IMTPipeline, &LIBID_PIPELINECONTROLLib>
{
public:
	CMTPipeline();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPIPELINE)

DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTPipeline>)

BEGIN_COM_MAP(CMTPipeline)
	COM_INTERFACE_ENTRY(IMTPipeline)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	HRESULT FinalConstruct();

// IMTPipeline
public:
	STDMETHODIMP ExamineSession(BSTR xml,
															/*[out, retval]*/ IMTSession * * session);

	STDMETHODIMP ExamineSessions(BSTR xml,
															/*[out, retval]*/ IMTSessionSet * * session);

	STDMETHOD(get_SessionFailures)(/*[out, retval]*/ IMTSessionFailures * *pVal);
	STDMETHOD(ExportSession)(/*[in]*/ IMTSession * session,
													 /*[out, retval]*/ BSTR * buffer);
	STDMETHOD(get_SessionServer)(IMTSessionServer * * server);

	STDMETHOD(get_ConfigurationDirectory)(/*[out, retval]*/ BSTR * dir);

	STDMETHOD(get_IsMultiInstance)(/*[out, retval]*/ VARIANT_BOOL * multi);

	STDMETHOD(AddPortMapping)(/*[in]*/ int port, BSTR instance);

	STDMETHOD(MultiInstanceSetup)(/*[in]*/ int port);

  STDMETHOD(GetSessionSetMessage)(BSTR aSessionSetID, BSTR sessionID,
																	/*[out]*/ BSTR * newUID,
																	/*[out, retval]*/ BSTR * message);

  STDMETHOD(GetLostMessage)(BSTR messageID, /*[out, retval]*/ BSTR * message);

	STDMETHOD(GetLostSessions)(/*[out, retval]*/ IMTCollection * * sessions);

	STDMETHOD(SubmitMessage)(BSTR message, /*[in, optional]*/ VARIANT txn);

  STDMETHOD(Login)(BSTR login, BSTR login_namespace, BSTR password);

  STDMETHOD(RequiresEncryption)(BSTR message,
																/*[out, retval]*/ VARIANT_BOOL * encrypt);

	STDMETHOD(put_SessionContext)(IMTSessionContext * apSessionContext);
private:
	HRESULT Init();
	HRESULT GetMeteredMessageInternal(BSTR sessionID, std::string & arMessage);

	HRESULT InitializeGenerator();

	HRESULT InitializeLogger();

	HRESULT InitializeMessageUtils();

	HRESULT InitializeParser();

	HRESULT ReadConfiguration();

	HRESULT ExportSessionToPropSet(MTConfigLib::IMTConfigPropSetPtr aTopSet,
																 MTPipelineLib::IMTSessionPtr aSession);

private:
	NTLogger mLogger;
	BOOL mLoggerInitialized;

	PipelineInfo mPipelineInfo;
	BOOL mConfigurationRead;

	PipelineObjectGenerator mGenerator;
	BOOL mGeneratorInitialized;

	RoutingQueueList mRoutingQueues;
	BOOL mRoutingQueuesInitialized;
	
	MetraTech_Pipeline_Messages::IMessageUtilsPtr mMessageUtils;

	BOOL mUtilsInitialized;

	// parser is used for validation only
	PipelineMSIXParser<NullSessionBuilder> mParser;
	BOOL mParserInitialized;
	NTThreadLock mParserLock;			// lock for mParser

	MTPipelineLib::IMTSessionServerPtr mSessionServer;

	// login context
	MTPipelineLibExt::IMTSessionContextPtr mSessionContext;

private:
	// the last message retrieved in GetSessionSetMessage
	// that call is often made repeatedly
	MTConfigLib::IMTConfigPropSetPtr mLastSessionSetMessage;
	_bstr_t mLastSessionSetID;
};

#endif //__MTPIPELINE_H_
