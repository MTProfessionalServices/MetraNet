/**************************************************************************
 * @doc MTSESSION
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

#include "SessServer.h"
#include "MTSessionDef.h"
#include "MTSessionSetDef.h"
#include "MTSessionPropDef.h"

#include <MSIX.h>
#include <metra.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <rwcom.h>
#include <mtcomerr.h>
#include <errobj.h>

#include <propids.h>
#include <accessgrant.h>
#include <float.h>

#include <transactionconfig.h>
#include <autocrypto.h>
#include <stdutils.h>
#include <string>
using namespace std;

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")

#include "MTSessionServerBaseDef.h"
#include "MTExceptionMacros.h"

// the end of the world - Mon Jan 18 22:14:07 2038
#define MAX_TIMET_AS_OLE 50424.134803241

/******************************************* error interface ***/
STDMETHODIMP CMTSession::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSession,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/********************************** construction/destruction ***/
CMTSession::CMTSession()
	: mpSessionBase(NULL)
{
}

// method used when querying for IID_NULL
//If iid matches the IID of the interface queried for, 
//then the function specified by func is called. The declaration for the function should be:
//HRESULT WINAPI func(void* pv, REFIID riid, LPVOID* ppv, DWORD dw);
HRESULT WINAPI _ThisSession(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}


HRESULT CMTSession::FinalConstruct()
{
	return S_OK;
}

void CMTSession::FinalRelease()
{
	ASSERT(mpSessionBase);
	if (mpSessionBase)
	{
		delete mpSessionBase;
		mpSessionBase = NULL;
	}
}

STDMETHODIMP CMTSession::MarkComplete(VARIANT_BOOL * apParentReady)
{
	if (!apParentReady)
		return E_POINTER;

	*apParentReady = mpSessionBase->MarkComplete() ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

//----- Properties.
HRESULT Initialize(CComObject<CMTSessionProp> * apObj,
				   const SharedPropVal * apPropVal)
{
	long nameID = apPropVal->GetNameID();
	SharedPropVal::Type type = apPropVal->GetType();
	BOOL error = FALSE;
	MTPipelineLib::MTSessionPropType sessionPropType;
	if (!ConvertPropertyType(type, &sessionPropType))
		return PIPE_ERR_INTERNAL_ERROR;

	// NOTE: have to do a reverse lookup on the ID to get the name
	MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
	_bstr_t name = nameid->GetName(nameID);

	apObj->SetPropInfo((MTSessionPropType)sessionPropType, name, nameID);
	return S_OK;
}

//----- Array type used for iteration
typedef vector<const SharedPropVal *> PropValList;
STDMETHODIMP CMTSession::get__NewEnum(/*[out, retval]*/ LPUNKNOWN *pVal)
{
	MT_LOCK_ACCESS()

	const SharedPropVal * propVal = NULL;
	int hashBucket;
	int propCount = 0;

	// the collection has to stay around as long as the enumerator does
	CComObject<CComContainerCopy<PropValList> > * copy = NULL;
	HRESULT hr = CComObject<CComContainerCopy<PropValList> >::CreateInstance(&copy);
	if (FAILED(hr))
		return hr;

	// The enum object created in GetNewEnumOnSTL holds a pointer to the object
	// pointed to by copy. Therefore, no need to increment the reference
	// count here.  The iterator will release this when it's released itself.
	// copy->AddRef();

	PropValList & propVals = copy->GetContainer();

	// TODO: we have to iterate the properties twice here..
	mpSessionBase->GetProps(&propVal, &hashBucket);

	while (propVal)
	{
		propCount++;

		propVals.push_back(propVal);

		mpSessionBase->GetNextProp(&propVal, &hashBucket);
	}

	return GetNewEnumOnSTL<CMTSessionProp, const SharedPropVal>(copy->GetUnknown(), propVals, pVal);
}

// ----------------------------------------------------------------
// Description: Return the Pipeline's internal session ID for this session object.
//              The session ID is the index of this session within shared memory,
//              and is unrelated to the session's UID.
// Return Value: session ID.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_SessionID(long * pVal)
{
	if (!pVal)
		E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionBase->get_SessionID();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::get_StartStage(long * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTSession::put_StartStage(long lVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTSession::get_ObjectOwnerID(/*[out, retval]*/ int * pVal)
{
	if (!pVal)
		E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionBase->get_ObjectOwnerID();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::put_ObjectOwnerID(/*[in]*/ long id)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->put_ObjectOwnerID(id);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Return a session's service ID.
// Return Value: session's service ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_ServiceID(long * pVal)
{
	if (!pVal)
		E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionBase->get_ServiceID();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Return a session's parent ID.  This is equivalent of the
//              SessionID property of the parent session.
// Return Value: session's parent's session ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_ParentID(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionBase->get_ParentID();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::get_DatabaseID(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionBase->get_DatabaseID();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::put_DatabaseID(long aVal)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->put_DatabaseID(aVal);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Return the session's Unique ID (UID), unencoded.
//              The UID is generated by the SDK and is unique across systems.
// Return Value: session's UID
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_UID(/*[out, retval, size_is(16)]*/ unsigned char * apUid)
{
	if (!apUid)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	const unsigned char* uid = mpSessionBase->get_UID();
	ASSERT(uid);
	memcpy(apUid, uid, SharedSession::UID_LENGTH);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Return the session's Unique ID (UID) base64 encoded into a string.
// Return Value: session's UID
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_UIDAsString(/*[out, retval]*/ BSTR * apUid)
{
	if (!apUid)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	string strUid = mpSessionBase->get_UIDAsString();
	
	_bstr_t bstr(strUid.c_str());
	*apUid = bstr.copy();

	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Return the parent session's Unique ID (UID) base64 encoded into a string.
// Return Value: parent session's UID
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_ParentUIDAsString(/*[out, retval]*/ BSTR * apUid)
{
	if (!apUid)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

  if (mpSessionBase->get_ParentID() != -1)
  {
	   string strUid = mpSessionBase->get_ParentUIDAsString();
	
	  _bstr_t bstr(strUid.c_str());
	  *apUid = bstr.copy();
  }

	MT_END_TRY_BLOCK(IID_IMTSession);
}
// ----------------------------------------------------------------
// Description: Return TRUE if the session is part of a compound session and has
//              children.
// Return Value: true if the session is a parent, false otherwise.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::get_IsParent(VARIANT_BOOL * isparent)
{
	if (!isparent)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*isparent = mpSessionBase->get_IsParent() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::get_CompoundMarkedAsFailed(VARIANT_BOOL * failed)
{
	if (!failed)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*failed = mpSessionBase->get_CompoundMarkedAsFailed() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::get_OutstandingChildren(long * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTSession::AddEvents(/*[in]*/ int events)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->AddEvents(events);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::get_Events(/*[out, retval]*/ int * events)
{
	if (!events)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*events =  mpSessionBase->get_Events();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the boolean value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetBoolProperty(long aPropId, VARIANT_BOOL * apValue)
{
	if (!apValue)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apValue = mpSessionBase->GetBoolProperty(aPropId) ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a bool.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetBoolProperty(long aPropId, VARIANT_BOOL aValue)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetBoolProperty(aPropId, aValue == VARIANT_TRUE);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the double value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetDoubleProperty(long aPropId, double * apValue)
{
	if (!apValue)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apValue = mpSessionBase->GetDoubleProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a double.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetDoubleProperty(long aPropId, double aValue)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetDoubleProperty(aPropId, aValue);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the long value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetLongProperty(long aPropId, long * apValue)
{
	if (!apValue)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apValue = mpSessionBase->GetLongProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a long.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetLongProperty(long aPropId, long aLong)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetLongProperty(aPropId, aLong);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the OLE automation DATE value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetOLEDateProperty(long aPropId, DATE * propval)
{
	if (!propval)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*propval = mpSessionBase->GetOLEDateProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as an OLE automation date.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetOLEDateProperty(long aPropId, DATE aDate)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetOLEDateProperty(aPropId, aDate);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the date/time value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value - date/time expressed in Unix time/GMT.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetDateTimeProperty(long aPropId, long * propval)
{
	if (!propval)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
    // COM 32BIT TIME_T
    *propval = (long) mpSessionBase->GetDateTimeProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a date/time.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value - date/time expressed in Unix time/GMT.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetDateTimeProperty(long aPropId, long aDateTime)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetDateTimeProperty(aPropId, aDateTime);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the time of day value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Time of day value (seconds after midnight)
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetTimeProperty(long aPropId, long * aLong)
{
	if (!aLong)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*aLong = mpSessionBase->GetTimeProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a time of day.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Time of day (seconds after midnight)
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetTimeProperty(long aPropId, long aLong)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetTimeProperty(aPropId, aLong);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the string value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetStringProperty(long aPropId, BSTR * apValue)
{
	if (!apValue)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apValue = mpSessionBase->GetStringProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the string value of a property.
//              Don't use this method - use GetStringProperty
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetBSTRProperty(long aPropId, BSTR * apValue)
{
	return GetStringProperty(aPropId, apValue);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a string.
//              Don't use this method - use SetStringProperty
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetBSTRProperty(long aPropId, BSTR aValue)
{
	return SetStringProperty(aPropId, aValue);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a string.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetStringProperty(long aPropId, BSTR aValue)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetStringProperty(aPropId, aValue);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the enum value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetEnumProperty(long aPropId, long * propval)
{
	if (!propval)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*propval = mpSessionBase->GetEnumProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as an enum.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetEnumProperty(long aPropId, long aEnum)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetEnumProperty(aPropId, aEnum);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the DECIMAL value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetDecimalProperty(long aPropId, VARIANT * propval)
{
	if (!propval)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	DECIMAL dec = mpSessionBase->GetDecimalProperty(aPropId);
	*propval = _variant_t(dec);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a DECIMAL.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetDecimalProperty(long aPropId, VARIANT propval)
{
	MT_BEGIN_TRY_BLOCK()
	_variant_t var(propval);
	DECIMAL dec = var;
	ASSERT(sizeof(dec) == SharedPropVal::DECIMAL_SIZE);
	mpSessionBase->SetDecimalProperty(aPropId, dec);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the object value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value - a variant holding an IDispatch interface pointer.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetObjectProperty(long propid,
										 /*[out, retval]*/ VARIANT * propval)
{
	if (!propval)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*propval = mpSessionBase->GetObjectProperty(propid);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the object value of a property.
// Arguments:   propid - Property ID of the property to get.
//              propval - Property value - a variant holding an IDispatch interface pointer.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetObjectProperty(long aPropId, VARIANT propval)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetObjectProperty(aPropId, propval);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the __int64 value of a property.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetLongLongProperty(long aPropId, __int64 * apValue)
{
	if (!apValue)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apValue = mpSessionBase->GetLongLongProperty(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Get the long long property as string.
// Arguments:   propid - Property ID of the property to get.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::GetLongLongPropertyAsString(long aPropId, BSTR * apValue)
{
	if (!apValue)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apValue = mpSessionBase->GetLongLongPropertyAsString(aPropId);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Set the value of a property as a __int64.
// Arguments:   propid - Property ID of the property to set.
// Return Value: Property value.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SetLongLongProperty(long aPropId, __int64 aLongLong)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->SetLongLongProperty(aPropId, aLongLong);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// ----------------------------------------------------------------
// Description: Return TRUE if the given property exists
// Arguments:   propid - Property ID of the property to test
// Return Value: true if property exists.
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::PropertyExists(long aPropId, MTSessionPropType aType, VARIANT_BOOL * apExists)
{
	if (!apExists)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
		*apExists = mpSessionBase->PropertyExists(aPropId, (MTPipelineLib::MTSessionPropType)aType) ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTSession);
}

/**************************************** database interface ***/
STDMETHODIMP CMTSession::Rollback()
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Description: Return a set containing all the children of this session.
// Return Value: a set of all the session's children
// ----------------------------------------------------------------
STDMETHODIMP CMTSession::SessionChildren(IMTSessionSet** apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(mpSessionBase->SessionChildren());
	if (!pSessionSetBase.get())
		return E_FAIL;

	//----- Create the new set COM object
	CComObject<CMTSessionSet>* setObj;
	HRESULT hr = CComObject<CMTSessionSet>::CreateInstance(&setObj);
	if (hr != S_OK || setObj == NULL)
	{
		//----- Must release the shared object
		*apSet = NULL;
		return (setObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Increase reference count for the pointer returned
	//----- Set the session set into the COM wrapper.
	setObj->AddRef();
	setObj->SetSessionSet(pSessionSetBase.release());
	*apSet = setObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSession, *apSet);
}

STDMETHODIMP CMTSession::AddSessionChildren(IMTSessionSet* apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	long lSetID;
	HRESULT hr = apSet->get_ID(&lSetID);
	if (hr != S_OK)
		return hr;

	CMTSessionServerBase* pServer = CMTSessionServerBase::CreateInstance();
	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(pServer->GetSessionSet(lSetID));
	pServer->Release();
	if (!pSessionSetBase.get())
		return PIPE_ERR_SHARED_OBJECT_FAILURE;

	mpSessionBase->AddSessionChildren(pSessionSetBase.get());

	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::AddSessionDescendants(IMTSessionSet* apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	long lSetID;
	HRESULT hr = apSet->get_ID(&lSetID);
	if (hr != S_OK)
		return hr;

	CMTSessionServerBase* pServer = CMTSessionServerBase::CreateInstance();
	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(pServer->GetSessionSet(lSetID));
	pServer->Release();
	if (!pSessionSetBase.get())
		return PIPE_ERR_SHARED_OBJECT_FAILURE;

	mpSessionBase->AddSessionDescendants(pSessionSetBase.get());

	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::MarkCompoundAsFailed()
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->MarkCompoundAsFailed();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::IncreaseSharedRefCount(long* apNewCount)
{
	if (!apNewCount)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apNewCount = mpSessionBase->IncreaseSharedRefCount();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::DecreaseSharedRefCount(long* apNewCount)
{
	if (!apNewCount)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apNewCount = mpSessionBase->DecreaseSharedRefCount();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::put_InTransitTo(long id)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->put_InTransitTo(id);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::put_InProcessBy(long id)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->put_InProcessBy(id);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::DeleteForcefully()
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->DeleteForcefully();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

//--------------------
// DTC support
//--------------------
STDMETHODIMP CMTSession::GetTransaction(VARIANT_BOOL aCreate, IMTTransaction **xaction)
{
	if (!xaction)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*xaction = reinterpret_cast<IMTTransaction *>(mpSessionBase->GetTransaction(aCreate == VARIANT_TRUE ? true : false));
	MT_END_TRY_BLOCK_RETVAL(IID_IMTSession, *xaction);
}

STDMETHODIMP CMTSession::get_SessionContext(IMTSessionContext **apCtx)
{
	if (!apCtx)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apCtx = reinterpret_cast<IMTSessionContext *>(mpSessionBase->get_SessionContext());
	MT_END_TRY_BLOCK_RETVAL(IID_IMTSession, *apCtx);
}

STDMETHODIMP CMTSession::get_HoldsSessionContext(/*[out, retval]*/ VARIANT_BOOL* apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apVal = mpSessionBase->get_HoldsSessionContext() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::GetRowset(BSTR ConfigFile, IMTSQLRowset **pSQLRowset)
{
	if (pSQLRowset == NULL)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pSQLRowset = reinterpret_cast<IMTSQLRowset *>(mpSessionBase->GetRowset(ConfigFile));
	MT_END_TRY_BLOCK_RETVAL(IID_IMTSession, *pSQLRowset);
}

// Clean up after transaction commit or rollback 
//
// WARNING: be sure to commit or roll back your transaction before
// calling this method -- this only frees up memory, it does not
// commit or rollback
//
STDMETHODIMP CMTSession::FinalizeTransaction()
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->FinalizeTransaction();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::DecryptEncryptedProp(long aPropID,BSTR* aStringProp)
{
	if (aStringProp == NULL)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*aStringProp = mpSessionBase->DecryptEncryptedProp(aPropID);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::EncryptStringProp(long aPropID, BSTR aStringProp)
{
	if (aStringProp == NULL)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->EncryptStringProp(aPropID, aStringProp);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

STDMETHODIMP CMTSession::CommitPendingTransaction()
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->CommitPendingTransaction();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// marks a session as failed
// intended to be used by plugins to mark a session from a batch as failed
STDMETHODIMP CMTSession::MarkAsFailed(BSTR aErrorMessage, long aErrorCode)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->MarkAsFailed(aErrorMessage, aErrorCode);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// marks a session as failed
// intended to be used by plugins to mark a session from a batch as failed
STDMETHODIMP CMTSession::MarkAsFailed(BSTR aErrorMessage)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionBase->MarkAsFailed(aErrorMessage);
	MT_END_TRY_BLOCK(IID_IMTSession);
}

// If session is part of an external transaction, returns transaction ID (aka cookie),
// otherwise returns empty string
// An external transaction ID can be metered in in two ways:
//  "TransactionId" in session set (preferred) or 
//  "_transactioncookie" in first session (for backward support)
STDMETHODIMP CMTSession::GetTransactionID(BSTR* apTransactionID)
{
	if (!apTransactionID)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apTransactionID = mpSessionBase->GetTransactionID();
	MT_END_TRY_BLOCK(IID_IMTSession);
}

//-- EOF --
