/**************************************************************************
 * @doc INSERTSESSION
 *
 * Copyright 2000 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#pragma warning (disable: 4786)
#include <PlugInSkeleton.h>
#include <propids.h>
#include <map>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.PlugIns.tlb> inject_statement("using namespace mscorlib;")

using MTPipelineLib::IMTSessionSetPtr;
using MTPipelineLib::IMTSessionPtr;

using std::map;
using std::wstring;

// generate using uuidgen
CLSID CLSID_BATCHUPDATE = { /* 177e3db7-b29a-4de9-b506-a16c68f1c2f8 */
    0x177e3db7,
    0xb29a,
    0x4de9,
    {0xb5, 0x06, 0xa1, 0x6c, 0x68, 0xf1, 0xc2, 0xf8}
  };

class ATL_NO_VTABLE BatchUpdate
	: public MTPipelinePlugIn<BatchUpdate, &CLSID_BATCHUPDATE>
{
public:
	virtual ~BatchUpdate()
	{ }
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			 MTPipelineLib::IMTNameIDPtr aNameID,
																			 MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSessionSet)
	{
		return E_NOTIMPL;
	}

private:
	HRESULT UpdateBatchStatus(MTPipelineLib::IMTSessionSetPtr aSet);

private:
	// interface to the logging system
	MTPipelineLib::IMTLogPtr mLogger;
};

PLUGIN_INFO(CLSID_BATCHUPDATE, BatchUpdate,
						"MetraPipeline.BatchUpdate.1", "MetraPipeline.BatchUpdate", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT BatchUpdate::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																		 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																		 MTPipelineLib::IMTNameIDPtr aNameID,
																		 MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mLogger = aLogger;

	PipelinePropIDs::Init();

	return S_OK;
}


HRESULT BatchUpdate::UpdateBatchStatus(MTPipelineLib::IMTSessionSetPtr aSet)
{
	map<wstring, int> batchCounts;

	SetIterator<IMTSessionSetPtr, IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	bool first = true;

	MTPipelineLib::IMTSessionPtr firstSession = NULL;

	while (TRUE)
	{
		IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		// store away the first session.  We may need it later
		// to get the pipeline's transaction object
		if (first)
		{
			first = false;

			firstSession = session;
		}


		if (session->PropertyExists(PipelinePropIDs::CollectionIDCode(),
																MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
		{
			wstring id =
				session->GetStringProperty(PipelinePropIDs::CollectionIDCode());
			 
			map<wstring, int>::iterator it;
			it = batchCounts.find(id);
			if (it == batchCounts.end())
			{
				// not found in the map
				batchCounts[id] = 1;
			}
			else
			{
				// increment the count
				++(it->second);
			}
		}
	}

	if (batchCounts.size() > 0)
	{
		// copy the info into the more awkward Hashtable
		MetraTech_Pipeline_PlugIns::IBatchCountsPtr objBatchCounts(__uuidof(MetraTech_Pipeline_PlugIns::BatchCounts));

		map<wstring, int>::const_iterator it;
		for (it = batchCounts.begin(); it != batchCounts.end(); ++it)
		{
			const wstring & batchID = it->first;
			int count = it->second;

			if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
			{
				_bstr_t buffer("Batch '");
				buffer += batchID.c_str();
				char intBuffer[256];
				buffer += "' has ";
				sprintf(intBuffer, "%d", count);
				buffer += intBuffer;
				buffer += " sessions";

				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
			}
			objBatchCounts->AddBatchCount(batchID.c_str(), count);
		}

		// get the transaction object, creating it if necessary
		MTPipelineLib::IMTTransactionPtr transaction;
		transaction = firstSession->GetTransaction(VARIANT_TRUE);

    GUID writerGuid = __uuidof(MetraTech_Pipeline_PlugIns::BatchIDWriter);

    MetraTech_Pipeline_PlugIns::IBatchIDWriterPtr batchIDWriter = transaction->CreateObjectWithTransactionByCLSID(&writerGuid);
		batchIDWriter->UpdateBatchCounts(objBatchCounts);
	}
	else
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"no sessions associated with batches");
	}

	return S_OK;
}


HRESULT BatchUpdate::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	HRESULT hr = S_OK;
	
	try 
	{
		hr = UpdateBatchStatus(aSet);
	}
	catch(_com_error& comerror)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, comerror.Description());
		hr = ReturnComError(comerror);
	}

	return hr;
}



