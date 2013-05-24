/**************************************************************************
 * @doc MTATLERR
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 *
 * @index | MTATLERR
 ***************************************************************************/

#ifndef _MTATLERR_H
#define _MTATLERR_H

template<class T>
HRESULT ErrorFromErrorObject(const ErrorObject * apError)
{
	// TODO: do we want the default - DISP_E_EXCEPTION, or the code in the
	// object?

	if (!apError)
		return E_FAIL;							// what else can we do?

	std::string message(apError->GetProgrammerDetail())
	if (message.length() > 0)
		return AtlReportError(T::GetObjectCLSID(), message.c_str(), GUID_NULL,
													apError->GetCode());

	// no message - just return the code
	return apError->GetCode();
}


template<class T>
HRESULT ErrorFromComError(const _com_error & arError)
{
	return AtlReportError(T::GetObjectCLSID(), message, GUID_NULL,
												apError->GetCode());
}

#endif /* _MTATLERR_H */
