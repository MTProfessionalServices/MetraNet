/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#ifndef __ARCHIVED_H_
#define __ARCHIVED_H_

#include "resource.h"       // main symbols

#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <autologger.h>
#include <mtcomerr.h>
#include <mtprogids.h>

#include "MTAccountStatesLogging.h"

#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")

#include "MTAccountStateImpl.h"

/////////////////////////////////////////////////////////////////////////////
// CArchived
class ATL_NO_VTABLE CArchived : 
	public MTAccountStateImpl<CArchived, &CLSID_Archived>,
	public ISupportErrorInfo
{
public:
	CArchived()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_ARCHIVED)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CArchived)
	COM_INTERFACE_ENTRY(IMTAccountStateInterface)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()


	void FinalRelease()
	{
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

public: // required by base class
	void InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr);

// IArchived
public:

	STDMETHOD(ChangeState)(IMTSessionContext* pCtx,
												 IMTSQLRowset* pRowset,
												 long lAccountID, 
												 long lIntervalID,
												 BSTR statename, 
												 DATE StartDate,
												 DATE EndDate);
	STDMETHOD(ReverseState)(IMTSessionContext* pCtx,
												 IMTSQLRowset* pRowset,
												 long lAccountID, 
												 long lIntervalID, 
												 BSTR statename, 
												 DATE StartDate,
												 DATE EndDate);

	STDMETHOD(CanChangeToPendingActiveApproval)(long lAccountID, DATE StartDate);
	STDMETHOD(CanChangeToActive)(long lAccountID, DATE StartDate);
	STDMETHOD(CanChangeToSuspended)(long lAccountID, DATE StartDate);
	STDMETHOD(CanChangeToPendingFinalBill)(long lAccountID, DATE StartDate);
	STDMETHOD(CanChangeToClosed)(long lAccountID, DATE StartDate);
	STDMETHOD(CanChangeToArchived)(long lAccountID, DATE StartDate);

protected:
	MTAutoInstance<MTAutoLoggerImpl<aArchivedLogTitle> > mLogger;
};

#endif //__ARCHIVED_H_
