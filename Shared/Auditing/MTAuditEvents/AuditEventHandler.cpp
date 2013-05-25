// AuditEventHandler.cpp : Implementation of CAuditEventHandler
#include "StdAfx.h"
#include "MTAuditEvents.h"
#include "AuditEventHandler.h"

#import "MTAuditDBWriter.tlb"
#import "MTAuditEvents.tlb"

#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CAuditEventHandler


STDMETHODIMP CAuditEventHandler::HandleEvent(IAuditEvent *apAuditEvent)
{
	try
	{
		MTAUDITDBWRITERLib::IAuditEventPtr auditevent(apAuditEvent);

		if (auditevent->GetSuccess() == VARIANT_TRUE)
		{
			// write success
			MTAUDITDBWRITERLib::IAuditDBWriterPtr pAuditWriter(__uuidof(MTAUDITDBWRITERLib::AuditDBWriter));
			pAuditWriter->Write(auditevent);
		}
		else
		{
			// write failure
			MTAUDITDBWRITERLib::IFailureAuditDBWriterPtr pFailureAuditWriter(__uuidof(MTAUDITDBWRITERLib::FailureAuditDBWriter));
			pFailureAuditWriter->Write(auditevent);
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}
