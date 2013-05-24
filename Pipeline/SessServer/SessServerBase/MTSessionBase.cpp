/**************************************************************************
 * @doc MTSESSIONBASE
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
 * Created by: Boris Boruchovich 
 *			   Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

//----- System includes.
#include <propids.h>
#include <float.h>
#include <transactionconfig.h>
#include <autocrypto.h>
#include <stdutils.h>
#include <string>

//----- MetraTech includes
#include <metra.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <rwcom.h>
#include <mtcomerr.h>
#include <MSIX.h>
#include <errobj.h>

//----- Session server includes.
#include "accessgrant.h"

//----- Local includes.
#include "MTSessionBaseDef.h"
#include "MTSessionSetBaseDef.h"
#include "MTSessionServerBaseDef.h"

//----- Imports.
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

//----- Namespaces.
using namespace std;

//----- The end of the world - Mon Jan 18 22:14:07 2038
#define MAX_TIMET_AS_OLE 50424.134803241

//----- Construction/destruction
CMTSessionBase::CMTSessionBase()
	: mpSharedSession(NULL),
	  mpHeader(NULL),
	  mpMappedView(NULL)
{
}
CMTSessionBase::~CMTSessionBase()
{
	MT_ASSERT_LOCK_ACCESS()

	//----- Important to release the shared object when the COM object goes away
	if (mpSharedSession)
	{
		mpSharedSession->Release(mpHeader);
		mpSharedSession = NULL;
	}
}

//----- Shared mem usage
void CMTSessionBase::SetSharedInfo(MappedViewHandle * apHandle,
								   SharedSessionHeader * apHeader,
								   SharedSession * apSession)
{
	mpMappedView = apHandle;

	// NOTE: must set mpMappedView before trying to use SharedAccess
	MT_ASSERT_LOCK_ACCESS()

	mpHeader = apHeader;

	// important to watch the reference counts on this shared object
	if (mpSharedSession)
	{
		mpSharedSession->Release(mpHeader);
	}
	mpSharedSession = apSession;
	mpSharedSession->AddRef();
}

bool CMTSessionBase::MarkComplete()
{
	MT_LOCK_ACCESS()

	BOOL groupComplete = FALSE;
	mpSharedSession->MarkComplete(mpHeader, groupComplete);

#if 0
	//Dump the Session out
	mpSharedSession->DumpSession(mpHeader);
#endif

	if (groupComplete)
		return true;

	return false;
}

bool ConvertPropertyType(SharedPropVal::Type type, MTPipelineLib::MTSessionPropType* pSessionPropType)
{
	switch (type)
	{
		case SharedPropVal::OLEDATE_PROPERTY:
		case SharedPropVal::TIMET_PROPERTY:
			*pSessionPropType = MTPipelineLib::SESS_PROP_TYPE_DATE;
			break;

		case SharedPropVal::TIME_PROPERTY:
			*pSessionPropType =	MTPipelineLib::SESS_PROP_TYPE_TIME;
			break;

		case SharedPropVal::UNICODE_PROPERTY:
		case SharedPropVal::TINYSTRING_PROPERTY:
		case SharedPropVal::EXTRA_LARGE_STRING_PROPERTY:
			*pSessionPropType =	MTPipelineLib::SESS_PROP_TYPE_STRING;
			break;

		case SharedPropVal::LONG_PROPERTY:
			*pSessionPropType =	MTPipelineLib::SESS_PROP_TYPE_LONG;
			break;

		case SharedPropVal::LONGLONG_PROPERTY:
			*pSessionPropType =	MTPipelineLib::SESS_PROP_TYPE_LONGLONG;
			break;

		case SharedPropVal::ENUM_PROPERTY:
			*pSessionPropType =	MTPipelineLib::SESS_PROP_TYPE_ENUM;
			break;

		case SharedPropVal::DOUBLE_PROPERTY:
			*pSessionPropType =	MTPipelineLib::SESS_PROP_TYPE_DOUBLE;
			break;

		case SharedPropVal::BOOL_PROPERTY:
			*pSessionPropType = MTPipelineLib::SESS_PROP_TYPE_BOOL;
			break;

		case SharedPropVal::DECIMAL_PROPERTY:
			*pSessionPropType = MTPipelineLib::SESS_PROP_TYPE_DECIMAL;
			break;

		case SharedPropVal::OBJECT_PROPERTY:
			*pSessionPropType = MTPipelineLib::SESS_PROP_TYPE_OBJECT;
			break;

		case SharedPropVal::FREE_PROPERTY:
		case SharedPropVal::ASCII_PROPERTY:
		default:
			ASSERT(0);
			return false;
	}

	return true;
}

// ----------------------------------------------------------------
// Description: Return the Pipeline's internal session ID for this session object.
//              The session ID is the index of this session within shared memory,
//              and is unrelated to the session's UID.
// Return Value: session ID.
// ----------------------------------------------------------------
long CMTSessionBase::get_SessionID()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetSessionID(mpHeader);
}

int CMTSessionBase::get_ObjectOwnerID()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetObjectOwnerID();
}

void CMTSessionBase::put_ObjectOwnerID(/*[in]*/ long id)
{
	MT_LOCK_ACCESS()
	mpSharedSession->SetObjectOwnerID(id);
}

// ----------------------------------------------------------------
// Description: Return a session's service ID.
// Return Value: session's service ID
// ----------------------------------------------------------------
long CMTSessionBase::get_ServiceID()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetServiceID();
}

// ----------------------------------------------------------------
// Description: Return a session's parent ID.  This is equivalent of the
//              SessionID property of the parent session.
// Return Value: session's parent's session ID
// ----------------------------------------------------------------
long CMTSessionBase::get_ParentID()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetParentID();
}

long CMTSessionBase::get_DatabaseID()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetRealID();
}

void CMTSessionBase::put_DatabaseID(long aVal)
{
	MT_LOCK_ACCESS()
	mpSharedSession->SetRealID(aVal);
}

// ----------------------------------------------------------------
// Description: Return the session's Unique ID (UID), unencoded.
//              The UID is generated by the SDK and is unique across systems.
// Return Value: session's UID
// ----------------------------------------------------------------
const unsigned char* CMTSessionBase::get_UID()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetUID();
}

// ----------------------------------------------------------------
// Description: Return the session's Unique ID (UID) base64 encoded into a string.
// Return Value: session's UID
// ----------------------------------------------------------------
string CMTSessionBase::get_UIDAsString()
{
  MT_LOCK_ACCESS()

	const unsigned char* uid = mpSharedSession->GetUID();

	// encode it to ASCII
	string asciiUID;
	MSIXUidGenerator::Encode(asciiUID, uid);
	return asciiUID;
}

// ----------------------------------------------------------------
// Description: If this is a child session, return the parent session's Unique ID (UID) base64 encoded into a string.
// Return Value: parent session's UID
// ----------------------------------------------------------------
string CMTSessionBase::get_ParentUIDAsString()
{
	MT_LOCK_ACCESS()

  string asciiUID;
	
	long parentId = mpSharedSession->GetParentID();
	if (parentId != -1)
	{
		SharedSession *sess = mpHeader->GetSession(parentId);
		const unsigned char* uid = sess->GetUID();
    MSIXUidGenerator::Encode(asciiUID, uid);
	}
	
	return asciiUID;
}

// ----------------------------------------------------------------
// Description: Return TRUE if the session is part of a compound session and has
//              children.
// Return Value: true if the session is a parent, false otherwise.
// ----------------------------------------------------------------
bool CMTSessionBase::get_IsParent()
{
  MT_LOCK_ACCESS()
	return mpSharedSession->IsParent() ? true : false;
}

bool CMTSessionBase::get_CompoundMarkedAsFailed()
{
	MT_LOCK_ACCESS()

	if (mpSharedSession->GetCurrentState() == SharedSession::MARKED_AS_FAILED)
		return true;
	else
	{
		SharedSession * sess = mpSharedSession;
		long parentId = sess->GetParentID();
		while (parentId != -1)
		{
			sess = mpHeader->GetSession(parentId);
			parentId = sess->GetParentID();
		}

		ASSERT(sess);
		ASSERT(parentId == -1);

		if (sess->GetCurrentState() == SharedSession::MARKED_AS_FAILED)
			return true;
		else
			return false;
	}

	// Should never get here.
}

void CMTSessionBase::AddEvents(int events)
{
	MT_LOCK_ACCESS()
	mpSharedSession->AddEvents(events);
}

int CMTSessionBase::get_Events()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->GetAllEvents();
}

/********************************** Get/Set property methods ***/
void CMTSessionBase::PropertyError(HRESULT aError, long aPropId)
{
	static BOOL propIdsInitialize = FALSE;

	if (!propIdsInitialize)
		PipelinePropIDs::Init();

	// NOTE: since creating a name ID object to generate a verbose error string
	// is expensive, it's not done for some of the pipeline's "special" reserved
	// properties which frequently don't exist.
	if (aPropId != PipelinePropIDs::ProfileStageCode()
		&& aPropId != PipelinePropIDs::NewParentIDCode()
		&& aPropId != PipelinePropIDs::NewParentInternalIDCode()
		&& aPropId != PipelinePropIDs::NextStageCode())
	{
		try
		{
			MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

			string name = nameid->GetName(aPropId);
			StrToLower(name);

			string errorStr("Invalid property, name: ");
			errorStr += name;
			throw MTException(errorStr.c_str(), aError);
		}
		catch (_com_error &)
		{
			// fall through
		}
		throw MTException("Property name unknown", aError);
	}
	
	//----- This is the cheapest way to return the error in this case.
	throw MTException("Property error", aError);
}

// ----------------------------------------------------------------
// Description: Get the boolean value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
bool CMTSessionBase::GetBoolProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = GetSharedProp(aPropId);
	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	if (prop->GetType() != SharedPropVal::BOOL_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);

	return prop->GetBooleanValue() ? true : false;
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a bool.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetBoolProperty(long aPropId, bool aValue)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetBooleanValue(aValue);
}

// ----------------------------------------------------------------
// Description: Get the double value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
double CMTSessionBase::GetDoubleProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);

	if (prop == NULL)
		//----- property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	if (prop->GetType() != SharedPropVal::DOUBLE_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);

	return prop->GetDoubleValue();
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a double.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetDoubleProperty(long aPropId, double aValue)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	if (_isnan(aValue))
		throw MTException("Double is NaN");

	if (!_finite(aValue))
		throw MTException("Double is infinity");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetDoubleValue(aValue);
}

// ----------------------------------------------------------------
// Description: Get the long value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
long CMTSessionBase::GetLongProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);

	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	switch(prop->GetType())
	{
		case SharedPropVal::LONG_PROPERTY:
			return prop->GetLongValue();
		case SharedPropVal::ENUM_PROPERTY:
			return prop->GetEnumValue();
		default:
			PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);
			return 0;
	}

	// Should never get here
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a long.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetLongProperty(long aPropId, long aLong)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetLongValue(aLong);
}

// ----------------------------------------------------------------
// Description: Get the OLE automation DATE value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
DATE CMTSessionBase::GetOLEDateProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);

	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	// NOTE: conversion between time_t and OLEDATE are
	// the only type conversions performed
	if (prop->GetType() == SharedPropVal::TIMET_PROPERTY)
	{
		//---- Make sure we have a writable version of the 
		SharedPropVal * writeable =	mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		TimetToOleDate(writeable);
		prop = writeable;
		ASSERT(prop->GetType() == SharedPropVal::OLEDATE_PROPERTY);
	}
	else if (prop->GetType() != SharedPropVal::OLEDATE_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);

	return prop->GetOLEDateValue();
}

// ----------------------------------------------------------------
// Description: Set the value of a property as an OLE automation date.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetOLEDateProperty(long aPropId, DATE aDate)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	if (aDate == 0.0 || aDate > MAX_TIMET_AS_OLE)
		throw MTException("Date property value out of range.");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetOLEDateValue(aDate);
}

// ----------------------------------------------------------------
// Description: Get the date/time value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value - date/time expressed in Unix time/GMT.
// ----------------------------------------------------------------
time_t CMTSessionBase::GetDateTimeProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);
	if (prop == NULL)
		//---- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	if (prop->GetType() == SharedPropVal::OLEDATE_PROPERTY)
	{
		//---- Make sure we have a writable version of the 
		SharedPropVal * writeable =	mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		OleDateToTimet(writeable);
		prop = writeable;
		ASSERT(prop->GetType() == SharedPropVal::TIMET_PROPERTY);
	}
	else if (prop->GetType() != SharedPropVal::TIMET_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);

	return prop->GetDateTimeValue();
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a date/time.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value - date/time expressed in Unix time/GMT.
// ----------------------------------------------------------------
void CMTSessionBase::SetDateTimeProperty(long aPropId, time_t aDateTime)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	if (aDateTime < 0)
		throw MTException("Bad datetime value");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetDateTimeValue(aDateTime);
}

// ----------------------------------------------------------------
// Description: Get the time of day value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Time of day value (seconds after midnight)
// ----------------------------------------------------------------
long CMTSessionBase::GetTimeProperty(long propid)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = GetSharedProp(propid);
	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, propid);

	if (prop->GetType() != SharedPropVal::TIME_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, propid);

	return prop->GetTimeValue();
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a time of day.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Time of day (seconds after midnight)
// ----------------------------------------------------------------
void CMTSessionBase::SetTimeProperty(long aPropId, long aLong)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetTimeValue(aLong);
}

// ----------------------------------------------------------------
// Description: Get the string value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
BSTR CMTSessionBase::GetStringProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);

	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	BSTR bstrStr;
	if (prop->GetType() == SharedPropVal::TINYSTRING_PROPERTY)
	{
		const wchar_t * str = prop->GetTinyStringValue();
		bstrStr = ::SysAllocString(str);
	}
	// TODO: convert type?
	else if (prop->GetType() == SharedPropVal::UNICODE_PROPERTY)
	{
		long id = prop->GetUnicodeIDValue();
		const wchar_t * str = mpHeader->GetWideString(id);
		if (!str)
			throw MTException("Failed to get wide string for property");

		bstrStr = ::SysAllocString(str);
	}
	else if (prop->GetType() == SharedPropVal::EXTRA_LARGE_STRING_PROPERTY)
	{
		wchar_t * str = prop->CopyExtraLargeStringValue(mpHeader);
		ASSERT(str);
		if (!str)
			throw MTException("Failed to copy extra large string value");

		bstrStr = ::SysAllocString(str);

		//----- Must free the buffer
		delete [] str;
	}
	else PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);

	return bstrStr;
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a string.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetStringProperty(long aPropId, const wchar_t* str)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop = GetOrCreateSharedProp(aPropId);
	if (prop == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	if ((wcslen(str) * sizeof(wchar_t)) < SharedSessionHeader::TINY_STRING_MAX)
	{
		//----- Small enough to go into the SharedPropVal directly
		prop->SetTinyStringValue(str);
	}
	else if ((wcslen(str) * sizeof(wchar_t)) < SharedSessionHeader::LARGE_STRING_MAX)
	{
		//----- Set the value
		long id = AllocateWideString(str);
		if (id == -1)
			throw MTException("Failed to allocate memory for wide string", PIPE_ERR_SHARED_OBJECT_FAILURE);

		prop->SetUnicodeIDValue(id);
	}
	else // Extra large
	{
		if (!prop->SetExtraLargeStringValue(mpHeader, str))
			//----- Must be no space left
			throw MTException("Unable to set extra large string value, must be out of memory", PIPE_ERR_SHARED_OBJECT_FAILURE);
	}
}

// ----------------------------------------------------------------
// Description: Get the enum value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
long CMTSessionBase::GetEnumProperty(long propid)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, propid);
	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, propid);

	if (prop->GetType() != SharedPropVal::ENUM_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, propid);

	return prop->GetEnumValue();
}

// ----------------------------------------------------------------
// Description: Set the value of a property as an enum.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetEnumProperty(long aPropId, long aEnum)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop = GetOrCreateSharedProp(aPropId);
	if (prop == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetEnumValue(aEnum);
}

// ----------------------------------------------------------------
// Description: Get the DECIMAL value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
DECIMAL CMTSessionBase::GetDecimalProperty(long propid)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, propid);
	if (prop == NULL)
		//---- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, propid);

	if (prop->GetType() != SharedPropVal::DECIMAL_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, propid);

	DECIMAL dec;
	const unsigned char * buffer = prop->GetDecimalValue();
	memcpy(&dec, buffer, sizeof(DECIMAL));
	return dec;
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a DECIMAL.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetDecimalProperty(long aPropId, DECIMAL propVal)
{
  SetDecimalProperty(aPropId, &propVal);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a DECIMAL.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetDecimalProperty(long aPropId, const DECIMAL * propVal)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop = GetOrCreateSharedProp(aPropId);
	if (prop == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	prop->SetDecimalValue((const unsigned char *) propVal);
}

// ----------------------------------------------------------------
// Description: Get the object value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value - a variant holding an IDispatch interface pointer.
// ----------------------------------------------------------------
VARIANT CMTSessionBase::GetObjectProperty(long propid)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop =
		mpSharedSession->GetReadablePropertyWithID(mpHeader, propid);

	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, propid);

	if (prop->GetType() != SharedPropVal::OBJECT_PROPERTY)
		PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, propid);

	IUnknown* pUnk;
	prop->GetObjectValue(&pUnk);
	if (pUnk == NULL)
	{	_variant_t nullPointer((IDispatch *) NULL, false);
		return nullPointer;
	}
	else
	{
		// attach to it (don't addref)
		_variant_t val(pUnk);

		// _variant_t val(obj, false);
		return val;
	}

	// Should never get here
}

// ----------------------------------------------------------------
// Description: Set the object value of a property.
// Arguments:   propid - Property ID of the property to get.
//              propval - Property value - a variant holding an IDispatch interface pointer.
// ----------------------------------------------------------------
void CMTSessionBase::SetObjectProperty(long propid, VARIANT propval)
{
	if (propid == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop = GetOrCreateSharedProp(propid);
	if (prop == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	_variant_t var(propval);
	IUnknownPtr iunknown = var;
	prop->SetObjectValue(iunknown);
}

// ----------------------------------------------------------------
// Description: Get the __int64 value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
__int64 CMTSessionBase::GetLongLongProperty(long aPropId)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);

	if (prop == NULL)
		//----- Property doesn't exist
		PropertyError(PIPE_ERR_INVALID_PROPERTY, aPropId);

	switch(prop->GetType())
	{
		case SharedPropVal::LONGLONG_PROPERTY:
			return prop->GetLongLongValue();
		case SharedPropVal::LONG_PROPERTY:
			return prop->GetLongValue();
		case SharedPropVal::ENUM_PROPERTY:
			return prop->GetEnumValue();
		default:
			PropertyError(PIPE_ERR_PROP_TYPE_MISMATCH, aPropId);
			return 0;
	}

	// Should never get here
}

// ----------------------------------------------------------------
// Description: Get the __int64 value of a property as a string.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
BSTR CMTSessionBase::GetLongLongPropertyAsString(long aPropId)
{
	MT_LOCK_ACCESS()

	__int64 val = GetLongLongProperty(aPropId);

  TCHAR buffer[65];

  if (_i64tot_s(val, buffer, _countof(buffer), 10) != 0)
  {
    throw MTException("Unable to convert int64 to string");
  }

	BSTR bstr = ::SysAllocString(buffer);

  return bstr;
}

// ----------------------------------------------------------------
// Description: Set the value of a property as an __int64.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
void CMTSessionBase::SetLongLongProperty(long aPropId, __int64 aLongLong)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	SharedPropVal * prop;
	if ((prop = GetOrCreateSharedProp(aPropId)) == NULL)
		throw MTException("Failed to get/create shared property", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set the value
	prop->SetLongLongValue(aLongLong);
}

// ----------------------------------------------------------------
// Description: Return TRUE if the given property exists
// Arguments:   propid - Property ID of the property to test
// Return Value: true if property exists.
// ----------------------------------------------------------------
bool CMTSessionBase::PropertyExists(long aPropId, MTPipelineLib::MTSessionPropType aType)
{
	if (aPropId == -1)
		throw MTException("Bad property ID");

	MT_LOCK_ACCESS()

	const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);
	if (prop == NULL)
		//----- Property doesn't exist
		return false;
	else
	{
		switch (prop->GetType())
		{
			case SharedPropVal::DECIMAL_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_DECIMAL);
			case SharedPropVal::OLEDATE_PROPERTY:
			case SharedPropVal::TIMET_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_DATE);
			case SharedPropVal::TIME_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_TIME);
			case SharedPropVal::ASCII_PROPERTY:
			case SharedPropVal::UNICODE_PROPERTY:
			case SharedPropVal::TINYSTRING_PROPERTY:
			case SharedPropVal::EXTRA_LARGE_STRING_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_STRING);
			case SharedPropVal::LONG_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_LONG);
			case SharedPropVal::LONGLONG_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_LONGLONG);
			case SharedPropVal::DOUBLE_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_DOUBLE);
			case SharedPropVal::BOOL_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_BOOL);
			case SharedPropVal::ENUM_PROPERTY:
				return (aType == MTPipelineLib::SESS_PROP_TYPE_ENUM);
			case SharedPropVal::OBJECT_PROPERTY:
				if (aType == MTPipelineLib::SESS_PROP_TYPE_OBJECT)
				{
					//----- Object property only exists if object exists
					IUnknown * obj = NULL;
					prop->GetObjectValue(&obj);
					if(obj != NULL)
					{	obj->Release();
						return true;
					}
				}
				return false;
			default:
				ASSERT(0);
				break;
		}
	}

	return false;
}

/********************************** property get/set helpers ***/
SharedPropVal * CMTSessionBase::GetOrCreateSharedProp(long aPropId)
{
	SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
	if (prop == NULL)
		prop = AddSharedProp(aPropId);

	if (prop)
		// clear any existing string in this property
		ClearProperty(prop);

	// If prop is null, the shared area is out of memory
	return prop;
}

void CMTSessionBase::OleDateToTimet(SharedPropVal * apProp)
{
	ASSERT(apProp->GetType() == SharedPropVal::OLEDATE_PROPERTY);

	time_t timeT;
	DATE date = apProp->GetOLEDateValue();
	::TimetFromOleDate(&timeT, date);
	apProp->SetDateTimeValue(timeT);
}

void CMTSessionBase::TimetToOleDate(SharedPropVal * apProp)
{
	ASSERT(apProp->GetType() == SharedPropVal::TIMET_PROPERTY);

	time_t timeT = apProp->GetDateTimeValue();
	DATE date;
	::OleDateFromTimet(&date, timeT);
	apProp->SetOLEDateValue(date);
}


const SharedPropVal * CMTSessionBase::GetSharedProp(long aNameId) const
{
	return mpSharedSession->GetReadablePropertyWithID(mpHeader, aNameId);
}

SharedPropVal * CMTSessionBase::AddSharedProp(long aNameId)
{
	// property reference ID is ignored
	long ref;

	return mpSharedSession->AddProperty(mpHeader, ref, aNameId);
}


void CMTSessionBase::ClearProperty(SharedPropVal * apProp)
{
	apProp->Clear(mpHeader);
}

/**************************************** database interface ***/
BOOL CMTSessionBase::DescendantScan(void * apArg, SharedSessionHeader * apHeader,
									SharedSession * apSession)
{
	CMTSessionBase::ChildScanInfo * info = (CMTSessionBase::ChildScanInfo *) apArg;

	long parent = info->mParentId;
	SessionList * list = info->mpList;

	if (apSession->GetParentID() == parent)
	{
		// this child has a matching parent
		list->push_back(apSession);

		// possibly add all grandchildren as well
		if (info->mAllDescendants && apSession->IsParent())
		{
			// recurse to find more children
			CollectDescendants(apHeader, apSession, *list);
		}
	}

	// keep scanning
 	return TRUE;
}

void CMTSessionBase::CollectDescendants(SharedSessionHeader * apHeader,
																		SharedSession * apSession,
																		SessionList & arList)
{
	// recursively add all descendents
	// NOTE: this can be expensive!
	// TODO: this can definitely be optimized

	if (!apSession->IsParent())
		return;

	ChildScanInfo info;
	info.mParentId = apSession->GetSessionID(apHeader);
	info.mpList = &arList;
	info.mAllDescendants = TRUE;
	apHeader->AllSessions(DescendantScan, &info);
}

void CMTSessionBase::CollectChildren(SharedSessionHeader * apHeader,
									 SharedSession * apSession,
									 SessionList & arList)
{
	// add all children, but no other descendants
	// TODO: this can definitely be optimized

	if (!apSession->IsParent())
		return;

	ChildScanInfo info;
	info.mParentId = apSession->GetSessionID(apHeader);
	info.mpList = &arList;
	info.mAllDescendants = FALSE;
	apHeader->AllSessions(DescendantScan, &info);
}

// ----------------------------------------------------------------
// Description: Return a set containing all the children of this session.
// Return Value: a set of all the session's children
// ----------------------------------------------------------------
CMTSessionSetBase* CMTSessionBase::SessionChildren()
{
	// TODO: this session server object is only
	// used to create child sets.  Do we need a copy
	// in every session object
	CMTSessionServerBase* pServer = CMTSessionServerBase::CreateInstance();

	CMTSessionSetBase* pSetBase;
	long childsetID = mpSharedSession->GetChildSetID();
	if (childsetID == -1)
		pSetBase = pServer->CreateSessionSet();
	else
		pSetBase = pServer->GetSessionSet(childsetID);

	pServer->Release();
	return pSetBase;
}

void CMTSessionBase::AddSessionChildren(CMTSessionSetBase* apSet)
{
	MT_LOCK_ACCESS()

	SessionList list;
	CollectChildren(mpHeader, mpSharedSession, list);

	SessionList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		SharedSession* sess = *it;
		ASSERT(sess);
		long id = sess->GetSessionID(mpHeader);
		long svcId = sess->GetServiceID();

		apSet->AddSession(id, svcId);
	}
}

void CMTSessionBase::AddSessionDescendants(CMTSessionSetBase* apSet)
{
	MT_LOCK_ACCESS()

	SessionList list;
	CollectDescendants(mpHeader, mpSharedSession, list);

	SessionList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		SharedSession * sess = *it;
		ASSERT(sess);
		long id = sess->GetSessionID(mpHeader);
		long svcId = sess->GetServiceID();

		apSet->AddSession(id, svcId);
	}
}

void CMTSessionBase::MarkCompoundAsFailed()
{
	MT_LOCK_ACCESS()
	mpSharedSession->MarkRootAsFailed(mpHeader);
}


// NOTE: use this method with caution - increasing the ref count will
// cause the object to stay in shared memory even after the COM object is deleted
long CMTSessionBase::IncreaseSharedRefCount()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->AddRef();
}

// NOTE: use this method with caution - decreasing the ref count
// could cause the shared session to be deleted prematurely
long  CMTSessionBase::DecreaseSharedRefCount()
{
	MT_LOCK_ACCESS()
	return mpSharedSession->Release(mpHeader);
}

void CMTSessionBase::put_InTransitTo(long id)
{
	MT_LOCK_ACCESS()
	mpSharedSession->SetCurrentState(SharedSession::IN_TRANSIT);
	mpSharedSession->SetCurrentOwnerStage(id);
}

void CMTSessionBase::put_InProcessBy(long id)
{
	MT_LOCK_ACCESS()
	mpSharedSession->SetCurrentState(SharedSession::PROCESSING);
	mpSharedSession->SetCurrentOwnerStage(id);
}

// NOTE: use this method with extreme caution
void CMTSessionBase::DeleteForcefully()
{
	MT_LOCK_ACCESS()
	mpSharedSession->DeleteForcefully(mpHeader);

	//----- Reference would be invalid otherwise.
	mpSharedSession = NULL;
}

long CMTSessionBase::AllocateWideString(const wchar_t * apStr)
{
	// don't need the actual pointer
	long ref;
	const wchar_t * str = mpHeader->AllocateWideString(apStr, ref);
	if (!str)
		return -1;
	else
		return ref;
}

long CMTSessionBase::AllocateString(const char * apStr)
{
	// don't need the actual pointer
	long ref;
	const char * str = mpHeader->AllocateString(apStr, ref);
	if (!str)
		return -1;
	else
		return ref;
}

void CMTSessionBase::FreeWideString(long aRef)
{
	mpHeader->FreeWideString(aRef);
}

void CMTSessionBase::FreeString(long aRef)
{
	mpHeader->FreeString(aRef);
}

const wchar_t* CMTSessionBase::GetWideString(long aRef)
{
	return mpHeader->GetWideString(aRef);
}

const char* CMTSessionBase::GetString(long aRef)
{
	return mpHeader->GetString(aRef);
}

//--------------------
// DTC support
//--------------------

// Transaction is stored in the object owner of the root most session
void CMTSessionBase::InternalSetTransaction(MTPipelineLib::IMTTransactionPtr apTxn)
{
	// work our way to the root
	SharedSession * session = mpSharedSession;
	while (session->GetParentID() != -1)
		session = mpHeader->GetSession(session->GetParentID());

	int objectOwnerID = session->GetObjectOwnerID();
	ASSERT(objectOwnerID != -1);
	if (objectOwnerID == -1)
		throw MTException("Unable to get object owner id");

	SharedObjectOwner * objectOwner = mpHeader->GetObjectOwner(objectOwnerID);
	ASSERT(objectOwner);
	if (!objectOwner)
		throw MTException("Unable to get shared object owner object");

	objectOwner->SetTransaction(apTxn);
}

MTPipelineLib::IMTTransaction* CMTSessionBase::GetTransaction(bool aCreate)
{
  MTPipelineLib::IMTTransactionPtr pXaction;

  //
	// Transaction is stored in the object owner of the root most session
	// 

	// work our way to the root
	SharedSession * session = mpSharedSession;
	while (session->GetParentID() != -1)
		session = mpHeader->GetSession(session->GetParentID());

  int objectOwnerID = session->GetObjectOwnerID();
	if (objectOwnerID == -1)
  	// NOTE: this can happen during an auto-test session that
    // attempts to get a pipeline rowset
		return NULL;

	SharedObjectOwner * objectOwner = mpHeader->GetObjectOwner(objectOwnerID);

	MTPipelineLib::IMTTransactionPtr tran;
	IUnknown * unknown = NULL;
	objectOwner->GetTransaction(&unknown);
	if (unknown)
	{
		HRESULT hr = unknown->QueryInterface(__uuidof(MTPipelineLib::IMTTransaction), (void **) &tran);
		unknown->Release();
		if (!FAILED(hr))
			pXaction = tran;
	}
	
	// If it already exists or we don't want to create a new one, return
	if (pXaction != NULL || aCreate == false)
		return (MTPipelineLib::IMTTransaction *) pXaction.Detach();

	// Doesn't exist - create it
	ASSERT(pXaction == NULL);

	//----- Always have to create it
	HRESULT hr = pXaction.CreateInstance(MTPROGID_MTTRANSACTION);
	if (FAILED(hr))
		throw MTException("Can not create MTTransaction object", hr);
	else
		InternalSetTransaction(pXaction);

	//
	// Join external transaction or begin internal transaction
	//

	// Get transaction ID/cookie
	BSTR bstrTransactionID = GetTransactionID();

	// if a transaction ID was found then join it
	if (bstrTransactionID)
		pXaction->Import(_bstr_t(bstrTransactionID, false));
	else
	{
		// no cookie found, begin the new transaction
		pXaction->Begin("SessionTxn", pXaction->GetDefaultTimeout());
	}	

	return (MTPipelineLib::IMTTransaction *) pXaction.Detach();
}

MTPipelineLibExt::IMTSessionContext* CMTSessionBase::get_SessionContext()
{
	//1. Get Object owner

	// work our way to the root
	SharedSession * session = mpSharedSession;
	while (session->GetParentID() != -1)
		session = mpHeader->GetSession(session->GetParentID());
	
	int objectOwnerID = session->GetObjectOwnerID();
	ASSERT(objectOwnerID != -1);
	if (objectOwnerID == -1)
		return NULL;
	
	SharedObjectOwner * objectOwner = mpHeader->GetObjectOwner(objectOwnerID);
	
	//2. Check if session context already exists
	//a. if it does, return it
	//objectOwner->GetSessionContext
	IUnknown * unknown = NULL;
	objectOwner->GetSessionContext(&unknown);
	if (unknown)
	{
		MTPipelineLibExt::IMTSessionContext* apCtx = NULL;
		HRESULT hr = unknown->QueryInterface(__uuidof(MTPipelineLibExt::IMTSessionContext), (void **) &apCtx);
		unknown->Release();
		if (FAILED(hr))
			throw MTException("Failed to query for session context", hr);

		return apCtx;
	}

	MTPipelineLibExt::IMTSessionContextPtr outPtr(MTPROGID_MTSESSIONCONTEXT);
	//3. Check if serialized context was set
	//a. If it was, deserialize it, set it on the object owner and return
	if (objectOwner->IsSerializedSessionContextSet())
	{
		wchar_t * rawSerialized = objectOwner->CopySerializedSessionContext(mpHeader);
		_bstr_t serialized = rawSerialized;
		delete [] rawSerialized;
		outPtr->FromXML(serialized);
	}
	else
	{
		//4. Check if all three user credentials were set
		//a. if yes, call login method, get session context, set it on the 
		//		object owner and return
		//5. If credentials were partially set, return error
		//6. If credentials were not set, login anonymous userget session context, set it on the 
		//   object owner and return

		const char* un = objectOwner->GetSessionContextUserName(mpHeader);
		const char* pw = objectOwner->GetSessionContextPassword(mpHeader);
		const char* ns = objectOwner->GetSessionContextNamespace(mpHeader);
		if(un && pw && ns)
		{
			MTPipelineLibExt::IMTLoginContextPtr loginCtx(MTPROGID_MTLOGINCONTEXT);
			outPtr = loginCtx->Login(un, ns, pw);
		}
		//TODO: Check for partially set credentials and return error?
		else
		{
			MTPipelineLibExt::IMTLoginContextPtr loginCtx(MTPROGID_MTLOGINCONTEXT);
			outPtr = loginCtx->LoginAnonymous();
		}
	}

	outPtr.QueryInterface(__uuidof(IUnknown), unknown);
	ASSERT(unknown != NULL);
	objectOwner->SetSessionContext(unknown);
	unknown->Release();

	return (MTPipelineLibExt::IMTSessionContext*)outPtr.Detach();
}

bool CMTSessionBase::get_HoldsSessionContext()
{
	//1. Get Object owner

	// work our way to the root
	SharedSession * session = mpSharedSession;
	while (session->GetParentID() != -1)
		session = mpHeader->GetSession(session->GetParentID());
	
	int objectOwnerID = session->GetObjectOwnerID();

	// if there is no object owner then there is no session context
	if (objectOwnerID == -1)
		return false;

	SharedObjectOwner * objectOwner = mpHeader->GetObjectOwner(objectOwnerID);
	
	//2. Check if session context already exists
	//a. if it does, return it
	//objectOwner->GetSessionContext
	IUnknown * unknown = NULL;
	objectOwner->GetSessionContext(&unknown);
	if (unknown)
	{
		unknown->Release();
		return true;
	}

	//2. Check if serialized context was set
		//a. If it was, deserialize it, set it on the object owner and return
	if (objectOwner->IsSerializedSessionContextSet())
		return true;
	
	//3. Check if all three user credentials were set
		//a. if yes, call login method, get session context, set it on the 
		//		object owner and return
	//4. If credentials were partially set, return error
	//5. If credentials were not set, login anonymous userget session context, set it on the 
	//   object owner and return

	const char* un = objectOwner->GetSessionContextUserName(mpHeader);
	const char* pw = objectOwner->GetSessionContextPassword(mpHeader);
	const char* ns = objectOwner->GetSessionContextNamespace(mpHeader);
	if(un && pw && ns)
		return true;

	return false;
}

ROWSETLib::IMTSQLRowset* CMTSessionBase::GetRowset(BSTR ConfigFile)
{
	_bstr_t bstrConfigFile = ConfigFile;
	MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

	HRESULT hr;
	ROWSETLib::IMTSQLRowsetPtr rowset;
	ROWSETLib::IMTSQLRowset* pSQLRowset = NULL;

	long lngID = nameid->GetNameID("_sessionrowset");
	bool rowsetExists = PropertyExists(lngID, MTPipelineLib::SESS_PROP_TYPE_OBJECT);

	//----- If we previously created a rowset, return immediately
	if (rowsetExists == true)
	{
		VARIANT var = GetObjectProperty(lngID);
    // The object comes back AddRef'd.  Don't do it again.
		_variant_t value(var, false);
		rowset = value;
		
		//----- Always update the config path
		hr = rowset->UpdateConfigPath(bstrConfigFile);
		if (FAILED(hr))
			throw MTException("Unable to change query config path.", hr);

		hr = rowset->QueryInterface(__uuidof(ROWSETLib::IMTSQLRowsetPtr), (void **)&pSQLRowset);
		if (FAILED(hr))
			throw MTException("Unable to query rowset interface", hr);

		return pSQLRowset;
	}

	//----- New rowset
	hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
	if (FAILED(hr))
		throw MTException("Can not create the MTSQLRowset object", PIPE_ERR_INTERNAL_ERROR);

	//----- For now initialize from accountcreation.  It must be a directory configured to use OLEDB.
	hr = rowset->Init("\\Queries\\AccountCreation");
	if (FAILED(hr)) 
		throw MTException("Rowset initialization failed.", hr);
	
	//----- Set the path used to find queries
	hr = rowset->UpdateConfigPath(bstrConfigFile);
	if (FAILED(hr))
		throw MTException("Unable to change query config path.", hr);

	//----- Attach the rowset to the session.  it needs to outlive the transaction
	lngID = nameid->GetNameID("_sessionrowset");
	try
	{
		SetObjectProperty(lngID, _variant_t(rowset.GetInterfacePtr()));
	}
	catch (MTException err)
	{
		//----- Map error to something more useful.
		throw MTException("Unable to add rowset object to session", err);
	}

	//----- Create a new transaction or return the one that exists
  // Be careful not to AddRef.  It is the job of the callee to AddRef return 
  // values.
	MTPipelineLib::IMTTransactionPtr xaction(GetTransaction(true),false);
	if (xaction == NULL)
    return NULL;

	//----- Join the rowset to the transaction
	rowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) xaction.GetInterfacePtr());
	hr = rowset->QueryInterface(__uuidof(ROWSETLib::IMTSQLRowsetPtr), (void **)&pSQLRowset);
	if (FAILED(hr)) 
		throw MTException("Unable query rowset interface", hr);

	return pSQLRowset;
}

// Clean up after transaction commit or rollback 
//
// WARNING: be sure to commit or roll back your transaction before
// calling this method -- this only frees up memory, it does not
// commit or rollback
//
void CMTSessionBase::FinalizeTransaction()
{
	//----- Clear the transaction
	InternalSetTransaction(NULL);

	//----- And the dependent rowset
	InternalClearRowset();
}

BSTR CMTSessionBase::DecryptEncryptedProp(long aPropID)
{
	// step 1: get the string property
	_bstr_t aTempStr(GetStringProperty(aPropID), false);

	// step 2: get an instance of the system context object
	MTPipelineLib::IMTSystemContextPtr aSysContext(MTPROGID_SYSCONTEXT);

	// step 3: decrypt the string
	aTempStr = aSysContext->Decrypt(aTempStr);
	return aTempStr.copy();
}

void CMTSessionBase::EncryptStringProp(long aPropID, const wchar_t* str)
{
	// Get an instance of the system context object
	MTPipelineLib::IMTSystemContextPtr aSysContext(MTPROGID_SYSCONTEXT);

	// Encrypt the string
  _bstr_t aTempStr(str);
	aTempStr = aSysContext->Encrypt(aTempStr);

  // The set the encrypted string property.
  SetStringProperty(aPropID, aTempStr);
}

void CMTSessionBase::CommitPendingTransaction()
{
	// step 1: get the transaction.  It is not an error if
	// the transaction does not exist
	MTPipelineLib::IMTTransaction* pTransaction = GetTransaction(false);
	if (pTransaction != NULL)
	{
		// step 2: call commit
		HRESULT hr = pTransaction->Commit();
		if (FAILED(hr))
			throw("Failed to commit transaction", hr);

		//----- Release the local copy
		pTransaction->Release();
	}

	//----- Clean up after treansaction
	FinalizeTransaction();
}

// marks a session as failed
// intended to be used by plugins to mark a session from a batch as failed
void CMTSessionBase::MarkAsFailed(BSTR aErrorMessage, long aErrorCode /* = E_FAIL */)
{
	SetStringProperty(PipelinePropIDs::ErrorStringCode(), aErrorMessage);
	SetLongProperty(PipelinePropIDs::ErrorCodeCode(), aErrorCode);

	MarkCompoundAsFailed();
}

// clear the rowset object if it exists
void CMTSessionBase::InternalClearRowset()
{
	MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

	long rowsetNameID = nameid->GetNameID("_sessionrowset");
	bool rowsetExists = PropertyExists(rowsetNameID, MTPipelineLib::SESS_PROP_TYPE_OBJECT);
	if (rowsetExists == true)
	{
		_variant_t nullPointer((IDispatch *) NULL, false);
		SetObjectProperty(rowsetNameID, nullPointer);
	}
}

// If session is part of an external transaction, returns transaction ID (aka cookie),
// otherwise returns empty string
// An external transaction ID can be metered in in two ways:
//  "TransactionId" in session set (preferred) or 
//  "_transactioncookie" in first session (for backward support)
BSTR CMTSessionBase::GetTransactionID()
{
	// first look for TransactionId of object owner

	// work our way to the root
	SharedSession * session = mpSharedSession;
	while (session->GetParentID() != -1)
		session = mpHeader->GetSession(session->GetParentID());
	
	int objectOwnerID = session->GetObjectOwnerID();
	ASSERT(objectOwnerID != -1);
	if (objectOwnerID == -1)
		throw MTException("Failed to get object owner id");

	SharedObjectOwner * objectOwner = mpHeader->GetObjectOwner(objectOwnerID);

	const char * txnID = objectOwner->GetTransactionID(mpHeader);
	if (txnID)
		return _bstr_t(txnID).copy();
	else 
	{
		// transaction ID was not found, so look for the transaction cookie

		// TODO: make this more efficient
		MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
		long lngID = nameid->GetNameID("_transactioncookie");
		
		bool cookieExists = PropertyExists(lngID, MTPipelineLib::SESS_PROP_TYPE_STRING);
		if (cookieExists == true)
			return _bstr_t(GetStringProperty(lngID), false).copy(); // doh! no other way to do this?
	}

	return NULL;
}

//-- EOF --
