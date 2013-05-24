/**************************************************************************
 * @doc MTCOMERR
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * @index | MTCOMERR
 ***************************************************************************/

#ifndef _MTCOMERR_H
#define _MTCOMERR_H

#include <errobj.h>
#include <string>
#include <MTSourceInfo.h>
#include <NTLogger.h>

ErrorObject * CreateErrorFromComError(const _com_error & arError);

HRESULT ReturnComError(const _com_error & arError);

inline HRESULT LogAndReturnComError(const NTLogger& arLogger, const _com_error & arError)
{
	ErrorObject* errObj = CreateErrorFromComError(arError);
	const_cast<NTLogger&>(arLogger).LogErrorObject(errObj->IsUserError() ? LOG_DEBUG : LOG_ERROR, errObj);
	delete errObj;

	return ReturnComError(arError);
}


void StringFromComError(std::string & arBuffer,
												const char * apMsg, const _com_error & arError);

void StringFromComError(string & arBuffer,
												const char * apMsg, const _com_error & arError);

void PassThroughComError();


// ----------------------------------------------------------------
// Name:        MT_THROW_COM_ERROR
// Description: Throws _com_error objects based  on several overloaded methods.
//              __FILE__ and __LINE__ will be automagically filled in.
//              The general form is:
//
//                MT_THROW_COM_ERROR( <optional IID>, 
//                                    <errorcode|charptr|wcharptr>,
//                                    <optional arguments> )
// Examples:
//              MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);
//              MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
//              MT_THROW_COM_ERROR(IID_IMTPriceableItem, MTPC_INVALID_PRICEABLE_ITEM_KIND, kind);
//              MT_THROW_COM_ERROR("System is hosed")
//              MT_THROW_COM_ERROR(L"System is hosed big time")
//              MT_THROW_COM_ERROR("Cannot find property: %s", apPropertyName)
// ----------------------------------------------------------------
#define MT_THROW_COM_ERROR  throw MTSourceInfo(__FILE__, __LINE__).CreateComError

#endif /* _MTCOMERR_H */
