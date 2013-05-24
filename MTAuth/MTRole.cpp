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

#include "StdAfx.h"
#include "MTAuth.h"
#include "MTRole.h"


/////////////////////////////////////////////////////////////////////////////
// CMTRole

STDMETHODIMP CMTRole::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRole,
    &IID_IMTSecurityPrincipal
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTRole::get_Name(BSTR *pVal)
{
	(*pVal) = mName.copy();

	return S_OK;
}

STDMETHODIMP CMTRole::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTRole::get_Description(BSTR *pVal)
{
	(*pVal) = mDesc.copy();

	return S_OK;
}

STDMETHODIMP CMTRole::put_Description(BSTR newVal)
{
	mDesc = newVal;
	return S_OK;
}


STDMETHODIMP CMTRole::get_GUID(BSTR *pVal)
{
	(*pVal) = mGUID.copy();

	return S_OK;
}

STDMETHODIMP CMTRole::put_GUID(BSTR newVal)
{
	mGUID = newVal;

	return S_OK;
}

STDMETHODIMP CMTRole::get_CSRAssignable(VARIANT_BOOL *pVal)
{
	(*pVal) = mCSRAssignable;

	return S_OK;
}

STDMETHODIMP CMTRole::put_CSRAssignable(VARIANT_BOOL newVal)
{
	mCSRAssignable = newVal;

	return S_OK;
}

STDMETHODIMP CMTRole::get_SubscriberAssignable(VARIANT_BOOL *pVal)
{
	(*pVal) = mSubscriberAssignable;

	return S_OK;
}

STDMETHODIMP CMTRole::put_SubscriberAssignable(VARIANT_BOOL newVal)
{
	mSubscriberAssignable = newVal;

	return S_OK;
}

STDMETHODIMP CMTRole::Save()
{
	//save the role itself and
	//then call base save, which will save the security policy
	BOOL bNameCollision(FALSE);

	try
	{
		MTAUTHLib::IMTRolePtr thisPtr = this;
		MTAUTHEXECLib::IMTRoleWriterPtr writer(__uuidof(MTAUTHEXECLib::MTRoleWriter));
    return writer->CreateOrUpdate
      (reinterpret_cast<MTAUTHEXECLib::IMTRole*>(thisPtr.GetInterfacePtr()));

	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}
	
}

STDMETHODIMP CMTRole::SaveBase()
{
  try
  {
    return MTSecurityPrincipalImpl<IMTRole, &IID_IMTRole, &LIBID_MTAUTHLib>::Save(this);
  }
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

}

STDMETHODIMP CMTRole::HasMembers(IMTSessionContext *aCtx, VARIANT_BOOL *apRes)
{
	try
	{
		MTAUTHLib::IMTRolePtr thisPtr = this;
		MTAUTHEXECLib::IMTRoleReaderPtr reader(__uuidof(MTAUTHEXECLib::MTRoleReader));
		
		(*apRes) = reader->HasMembers(thisPtr->Name);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTRole::GetMembersAsRowset(IMTSessionContext *aCtx, MTPrincipalPolicyType aPolicyType, IMTSQLRowset **apRowset)
{
	if (!apRowset)
		return E_POINTER;
	*apRowset = NULL;
	// TODO: Do we check security here??
	try
	{
		MTAUTHLib::IMTRolePtr thisPtr = this;
		MTAUTHEXECLib::IMTRoleReaderPtr reader(__uuidof(MTAUTHEXECLib::MTRoleReader));
    (*apRowset) = (IMTSQLRowset*)reader->GetMembersAsRowset(thisPtr->ID, (MTAUTHEXECLib::MTPrincipalPolicyType)aPolicyType).Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;

}
STDMETHODIMP CMTRole::FromXML(IMTSessionContext* aCtx, BSTR aXmlString)
{
	try
	{
    MTAUTHLib::IMTRolePtr thisPtr = this;
    MTAUTHEXECLib::IMTRoleReaderPtr reader(__uuidof(MTAUTHEXECLib::MTRoleReader));
    MSXML2::IXMLDOMNodePtr roleNode = NULL;
    MSXML2::IXMLDOMNodePtr textNode = NULL;
    MSXML2::IXMLDOMNodePtr typeAttrib;
    MSXML2::IXMLDOMNamedNodeMapPtr attribs;
		MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");
    domdoc->loadXML(aXmlString);
		roleNode = domdoc->selectSingleNode(PRINCIPAL_TAG);
    attribs = roleNode->attributes;
    typeAttrib = attribs->getNamedItem(TYPE_ATTRIB);
    _variant_t vAttribValue = typeAttrib->nodeValue;
    if((_bstr_t)vAttribValue != _bstr_t("role"))
    {
      LogAuthError("Principal Type not a Role");
      MT_THROW_COM_ERROR(MTAUTH_ROLE_DESERIALIZATION_FAILED);
    }
    vAttribValue = attribs->getNamedItem(NAME_ATTRIB)->nodeValue;
    thisPtr->Name = (_bstr_t)vAttribValue;
    textNode = roleNode->selectSingleNode(DESCRIPTION_TAG);
    
    if(textNode == NULL)
    {
      LogAuthError("Description tag not found");
      MT_THROW_COM_ERROR(MTAUTH_ROLE_DESERIALIZATION_FAILED);
    }

    thisPtr->Description = textNode->text;
    textNode = roleNode->selectSingleNode(CSR_ASSIGNABLE_TAG);

    if(textNode == NULL || !ValidateBooleanTag(textNode->text))
    {
      LogAuthError("CSRAssignable tag not found or contains invalid value");
      MT_THROW_COM_ERROR(MTAUTH_ROLE_DESERIALIZATION_FAILED);
    }
    
    thisPtr->CSRAssignable = ConvertBooleanTag(textNode->text);

    textNode = roleNode->selectSingleNode(SUBSCRIBER_ASSIGNABLE_TAG);

    if(textNode == NULL || !ValidateBooleanTag(textNode->text))
    {
      LogAuthError("SubscriberAssignable tag not found or contains invalid value");
      MT_THROW_COM_ERROR(MTAUTH_ROLE_DESERIALIZATION_FAILED);
    }

    thisPtr->SubscriberAssignable = ConvertBooleanTag(textNode->text);

    if(thisPtr->SubscriberAssignable == VARIANT_FALSE && 
      thisPtr->CSRAssignable == VARIANT_FALSE)
      MT_THROW_COM_ERROR(MTAUTH_ORPHAN_ROLE, (char*)thisPtr->Name);

    //look up role with the same name. If found, then set the
    //id so that the role gets updated
    ROWSETLib::IMTSQLRowsetPtr rs = reader->FindRecordsByNameAsRowset(thisPtr->Name);
			
		if(rs->GetRowsetEOF().boolVal == FALSE)
		{
			 if(rs->GetRecordCount() > 1)
        MT_THROW_COM_ERROR(MTAUTH_ROLE_MULTIPLE_ENTRIES_FOUND, (char*)thisPtr->Name);
       thisPtr->ID = rs->GetValue("id_role");
		}
      
		return MTSecurityPrincipalImpl<IMTRole, &IID_IMTRole, &LIBID_MTAUTHLib>::FromXML(aCtx, aXmlString);
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTRole::ToXML(BSTR* apXmlString)
{
	try
	{
    return E_NOTIMPL;
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTRole::AddMember(IMTSessionContext* aCtx, long aMemberID)
{
	try
	{
   	/* TODO: Auth Check */
    MTAUTHLib::IMTRolePtr thisPtr = this;
    MTAUTHEXECLib::IMTRoleWriterPtr writer(__uuidof(MTAUTHEXECLib::MTRoleWriter));
		writer->AddMember
      (reinterpret_cast<MTAUTHEXECLib::IMTRole *>(thisPtr.GetInterfacePtr()), aMemberID);
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}
  
  return S_OK;
}

STDMETHODIMP CMTRole::RemoveMember(IMTSessionContext* aCtx, long aMemberID)
{
	try
	{
   	/* TODO: Auth Check */
    MTAUTHLib::IMTRolePtr thisPtr = this;
    MTAUTHEXECLib::IMTRoleWriterPtr writer(__uuidof(MTAUTHEXECLib::MTRoleWriter));
		writer->RemoveMember
      (reinterpret_cast<MTAUTHEXECLib::IMTRole  *>(thisPtr.GetInterfacePtr()), aMemberID);
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTRole::AddMemberBatch
      ( /*in*/IMTSessionContext* aCtx, 
        /*in*/IMTCollection* apMembers, 
        /*in*/IMTProgress* aProgress, 
        /*out, retval*/IMTRowSet** apResultRs)
{
	try
	{
   	MTAUTHEXECLib::IMTRoleWriterPtr writer(__uuidof(MTAUTHEXECLib::MTRoleWriter));
    MTAUTHLib::IMTRolePtr thisPtr = this;
		ROWSETLib::IMTRowSetPtr rs = writer->AddMemberBatch(
			reinterpret_cast<MTAUTHEXECLib::IMTCollection *>(apMembers),
			reinterpret_cast<MTAUTHEXECLib::IMTProgress *>(aProgress),
      reinterpret_cast<MTAUTHEXECLib::IMTRole  *>(thisPtr.GetInterfacePtr()));
		*apResultRs = reinterpret_cast<IMTRowSet*>(rs.Detach());
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}


