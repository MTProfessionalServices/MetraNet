/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* Created by: Boris Partensky
* 
***************************************************************************/


// MTCompositeCapability.cpp : Implementation of CMTCompositeCapability
#include "StdAfx.h"
#include "MTAuth.h"
#include "MTCompositeCapabilityBase.h"
#include <GenericCollection.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapability

STDMETHODIMP CMTCompositeCapabilityBase::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCompositeCapability
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCompositeCapabilityBase::Implies(IMTCompositeCapability *aThisPtr, IMTCompositeCapability *aDemandedCapability, VARIANT_BOOL abCheckParameters, VARIANT_BOOL *apResult)
{
	HRESULT hr(S_OK);
	
	(*apResult) = VARIANT_FALSE;
	
	try
	{
		MTAUTHLib::IMTCompositeCapabilityPtr thisCap = aThisPtr;
		MTAUTHLib::IMTCompositeCapabilityPtr thatCap = aDemandedCapability;
		if(thisCap->CapabilityType->Equals(thatCap->CapabilityType) == VARIANT_TRUE)
		{
			//check all the atomic capabilities, hence parameters
			if(abCheckParameters)
			{
				//save every atomic instance
				long numAtomics = thatCap->AtomicCapabilities->Count;
				for (int i=1; i <= numAtomics; ++i)
				{
					MTAUTHLib::IMTAtomicCapabilityPtr thatAtomicCap = thatCap->AtomicCapabilities->GetItem(i);
					_bstr_t thatName = thatAtomicCap->CapabilityType->Name;
					MTAUTHLib::IMTAtomicCapabilityPtr thisAtomicCap = thisCap->GetAtomicCapabilityByName(thatName);
					if(thisAtomicCap == NULL)
					{
						//LOGTODO: this is really bad -
						//somehow two same composites don't have same atomics
						//this shouldn't happen
						MT_THROW_COM_ERROR(IID_IMTCompositeCapabilityBase, "two same composites don't have same atomics!");
					}
					if(thisAtomicCap->Implies(thatAtomicCap) == VARIANT_FALSE)
					{
						//at least one atomic on current one failed, 
						//immediately return false
						(*apResult) = VARIANT_FALSE;
						return S_OK;
					}
				}
				//all atomics implied demanded ones
				//or there are no atomic on this composite
				(*apResult) = VARIANT_TRUE;
			}
			else 
				(*apResult) = VARIANT_TRUE;
		}
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::get_ID(long *pVal)
{
	(*pVal) = mID;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::put_ID(long newVal)
{
	mID = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::get_ActorAccountID(long *pVal)
{
	(*pVal) = mActorAccount;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::put_ActorAccountID(long newVal)
{
	mActorAccount = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::AddAtomicCapability(IMTAtomicCapability *aAtomicCap)
{
	mAtomicCaps.Add(aAtomicCap);
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::get_AtomicCapabilities(IMTCollection** apCaps)
{
	//TODO: initialize atomic instances on-demand
	mAtomicCaps.CopyTo(apCaps);
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::Save(IMTCompositeCapability *aThisPtr, IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	bool bUpdate(FALSE);
	ROWSETLib::IMTSQLRowsetPtr rowset;
	try
	{
		MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyWriter));
		if (thisPtr->ID > -1)
			//destructively updates parameters on all atomics -
			//needs to be transactional
			writer->UpdateCompositeInstance((MTAUTHEXECLib::IMTCompositeCapability*)aThisPtr, (MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
		else
			thisPtr->ID = writer->CreateCompositeInstance((MTAUTHEXECLib::IMTCompositeCapability*)aThisPtr, (MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::GetCapabilityType(IMTCompositeCapability* aThisPtr, IMTCompositeCapabilityType** pVal)
{
  HRESULT hr(S_OK);
  try
  {
    if (mType == NULL)
    {
      MTAUTHEXECLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
      MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr reader(__uuidof(MTAUTHEXECLib::MTCompositeCapabilityTypeReader));
      mType = reader->GetByInstanceID(thisPtr->ID);
      ASSERT(mType != NULL);
    }
    
    MTAUTHLib::IMTCompositeCapabilityTypePtr outPtr = mType;
    (*pVal) = (IMTCompositeCapabilityType*)outPtr.Detach();
  }
  catch (_com_error & err)
  {
    return LogAndReturnAuthError(err);
  }

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::SetCapabilityType(IMTCompositeCapabilityType* newVal)
{
	mType = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::Remove(IMTCompositeCapability *aThisPtr, IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTAUTHEXECLib::IMTCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTCapabilityWriter));
		//it also removes all the atomic instances attached to this composite
		writer->RemoveCompositeInstance
      ((MTAUTHEXECLib::IMTCompositeCapability*)aThisPtr, (MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::GetAtomicCapabilityByName(IMTCompositeCapability* aThisPtr, BSTR aAtomicName, IMTAtomicCapability **apCap)
{
  if(apCap == NULL)
    return E_POINTER;
  (*apCap) = NULL;
  
  try
  {
    
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
    _bstr_t name = aAtomicName;
    long numAtomics = thisPtr->AtomicCapabilities->Count;
    
    for (int i=1; i <= numAtomics; ++i)
    {
      MTAUTHLib::IMTAtomicCapabilityPtr atomicCap = thisPtr->AtomicCapabilities->GetItem(i);
      if(_wcsicmp((wchar_t*)name, (wchar_t*)atomicCap->CapabilityType->Name) == 0)
      {
        (*apCap) = (IMTAtomicCapability*)atomicCap.Detach();
        return S_OK;
      }
    }
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::GetAtomicEnumCapability(IMTCompositeCapability* aThisPtr, IMTEnumTypeCapability **apCap)
{
	if(apCap == NULL)
		return E_POINTER;
	(*apCap) = NULL;

  MTAUTHLib::IMTEnumTypeCapabilityPtr outPtr = NULL;
	
  try
  {
    MTAUTHLib::IMTAtomicCapabilityPtr atomicPtr;
    
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
    MTAUTHLib::IMTCollectionPtr coll = thisPtr->AtomicCapabilities;
    long count = coll->Count;
    for (int i=1; i<=count; ++i)
    {
      atomicPtr = coll->GetItem(i);
      IUnknown* temp;
      HRESULT hr = atomicPtr.QueryInterface(IID_IMTEnumTypeCapability, (void**)&temp);
      if(SUCCEEDED(hr))
      {
				temp->Release();
        outPtr = atomicPtr;
        break;
      }
    }
    if(outPtr != NULL)
      (*apCap) = (IMTEnumTypeCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;

}

STDMETHODIMP CMTCompositeCapabilityBase::GetAtomicPathCapability(IMTCompositeCapability* aThisPtr, IMTPathCapability **apCap)
{
	if(apCap == NULL)
		return E_POINTER;
	(*apCap) = NULL;

  MTAUTHLib::IMTPathCapabilityPtr outPtr = NULL;
	
  try
  {
    MTAUTHLib::IMTAtomicCapabilityPtr atomicPtr;
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
    MTAUTHLib::IMTCollectionPtr coll = thisPtr->AtomicCapabilities;
    long count = coll->Count;
    for (int i=1; i<=count; ++i)
    {
			atomicPtr = coll->GetItem(i);
			outPtr = MTAUTHLib::IMTPathCapabilityPtr(atomicPtr); // QI
			if(outPtr != NULL) {
				break;
			}
    }
    if(outPtr != NULL)
      (*apCap) = (IMTPathCapability*)outPtr.Detach();

  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;

}

STDMETHODIMP CMTCompositeCapabilityBase::GetAtomicCollectionCapability(
	IMTCompositeCapability* aThisPtr, 
	IMTStringCollectionCapability** apCap)
{
	if(apCap == NULL)
		return E_POINTER;
	(*apCap) = NULL;

	MTAUTHLib::IMTStringCollectionCapabilityPtr outPtr = NULL;

	try
	{
		MTAUTHLib::IMTAtomicCapabilityPtr atomicPtr;
		MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
		MTAUTHLib::IMTCollectionPtr coll = thisPtr->AtomicCapabilities;
		long count = coll->Count;
		for(int i=1; i<= count; ++i)
		{
			atomicPtr = coll->GetItem(i);
			outPtr = MTAUTHLib::IMTStringCollectionCapabilityPtr(atomicPtr); //QI
			if(outPtr != NULL)
				break;
		}

		if(outPtr != NULL)
			(*apCap) = (IMTStringCollectionCapability*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::GetAtomicDecimalCapability(IMTCompositeCapability* aThisPtr, IMTDecimalCapability **apCap)
{
  if(apCap == NULL)
    return E_POINTER;
  (*apCap) = NULL;
  
  MTAUTHLib::IMTDecimalCapabilityPtr outPtr = NULL;
  
  try
  {
    MTAUTHLib::IMTAtomicCapabilityPtr atomicPtr;
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
    MTAUTHLib::IMTCollectionPtr coll = thisPtr->AtomicCapabilities;
    long count = coll->Count;
    for (int i=1; i<=count; ++i)
    {
      atomicPtr = coll->GetItem(i);
      IUnknown* temp;
      HRESULT hr = atomicPtr.QueryInterface(IID_IMTDecimalCapability, (void**)&temp);
      if(SUCCEEDED(hr))
      {
				temp->Release();
        outPtr = atomicPtr;
        break;
      }
    }
    if(outPtr != NULL)
      (*apCap) = (IMTDecimalCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }

  return S_OK;

}

STDMETHODIMP CMTCompositeCapabilityBase::FromXML(IMTCompositeCapability* aThisPtr, IDispatch* aDomNode)
{
	try
	{
		MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
		MSXML2::IXMLDOMNodePtr nodePtr = aDomNode;
		MSXML2::IXMLDOMNodePtr enumNode = NULL;
		MSXML2::IXMLDOMNodePtr pathNode = NULL;
		MSXML2::IXMLDOMNodePtr decNode = NULL;
		MSXML2::IXMLDOMNodePtr colNode = NULL;
		MSXML2::IXMLDOMNodePtr atomicCapsNode = NULL;
		MSXML2::IXMLDOMNodeListPtr atomicCapNodes = NULL;
		MSXML2::IXMLDOMNodePtr atomicCapNode = NULL;
		MSXML2::IXMLDOMNodePtr textNode;
		MSXML2::IXMLDOMNodePtr wcNode;
		MSXML2::IXMLDOMNodePtr opNode;
		MSXML2::IXMLDOMNodePtr paramNode;

		MTAUTHLib::IMTAtomicCapabilityPtr enumPtr = thisPtr->GetAtomicEnumCapability();
		MTAUTHLib::IMTAtomicCapabilityPtr pathPtr = thisPtr->GetAtomicPathCapability();
		MTAUTHLib::IMTAtomicCapabilityPtr decPtr = thisPtr->GetAtomicDecimalCapability();
		MTAUTHLib::IMTAtomicCapabilityPtr strColPtr = thisPtr->GetAtomicCollectionCapability();

		atomicCapsNode = nodePtr->selectSingleNode(ATOMIC_CAPS_TAG);

		if(atomicCapsNode == NULL)
		{
			if(thisPtr->CapabilityType->NumAtomic > 0)
			{
				LogAuthError("'atomiccapabilities' set is missing!");
				MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_DESERIALIZATION_FAILED);
			}
		}
		else
		{
			if( atomicCapsNode->hasChildNodes() == VARIANT_FALSE &&
				thisPtr->CapabilityType->NumAtomic > 0)
			{
				LogAuthError("'atomiccapabilities' set is empty");
				MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_DESERIALIZATION_FAILED);
			}

			if(enumPtr != NULL)
			{
				enumNode = ValidateAtomicCap(thisPtr, atomicCapsNode, ENUMTYPE_CAP_TAG);
				textNode = ValidateTag(enumPtr, enumNode, VALUE_TAG);
				MTAUTHLib::IMTEnumTypeCapabilityPtr concrete = enumPtr;
				ASSERT(concrete != NULL);
				concrete->SetParameter((_variant_t)textNode->text);
			}
			if(pathPtr != NULL)
			{
				pathNode = ValidateAtomicCap(thisPtr, atomicCapsNode, PATH_CAP_TAG);
				textNode = ValidateTag(pathPtr, pathNode, VALUE_TAG);
				wcNode = ValidateTag(pathPtr, pathNode, WILDCARD_TAG);
				MTAUTHLib::IMTPathCapabilityPtr concrete = pathPtr;
				ASSERT(concrete != NULL);
				concrete->SetParameter(textNode->text, 
					(MTAUTHLib::MTHierarchyPathWildCard)atol(wcNode->text));
			}

			if(decPtr != NULL)
			{
				decNode = ValidateAtomicCap(thisPtr, atomicCapsNode, DECIMAL_CAP_TAG);
				textNode = ValidateTag(decPtr, decNode, VALUE_TAG);
				opNode = ValidateTag(decPtr, decNode, OP_TAG);
				MTAUTHLib::IMTDecimalCapabilityPtr concrete = decPtr;
				ASSERT(concrete != NULL);
				concrete->SetParameter((_variant_t)textNode->text, 
					(MTAUTHLib::MTOperatorType)StringToOp(opNode->text));
			}
			if(strColPtr != NULL)
			{
				colNode = ValidateAtomicCap(thisPtr, atomicCapsNode, STR_COL_CAP_TAG);
				MTAUTHLib::IMTCollectionPtr colPtr = colPtr.CreateInstance(__uuidof(MTCollection));
				for(int i=1; i<colNode->childNodes->length; i++)
				{
					colNode->childNodes->get_item(i,&paramNode);
					colPtr->Add(paramNode->text);
				}
				MTAUTHLib::IMTStringCollectionCapabilityPtr concrete = strColPtr;
				ASSERT(concrete != NULL);
				concrete->SetParameter(colPtr);
			}
		}
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityBase::ToXML(IMTCompositeCapability* aThisPtr, BSTR* apXmlString)
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

MSXML2::IXMLDOMNodePtr CMTCompositeCapabilityBase::ValidateAtomicCap(MTAUTHLib::IMTCompositeCapabilityPtr& aThisPtr, MSXML2::IXMLDOMNodePtr& aNodePtr, char* aTag)
{
  MSXML2::IXMLDOMNodePtr atomicNode = NULL;
  atomicNode = aNodePtr->selectSingleNode(aTag);
  if(atomicNode == NULL)
  {
    char buf[1024];
    sprintf(buf, "<%s> has to be specified on <%s> type", aTag, (char*)aThisPtr->CapabilityType->Name);
    LogAuthError(buf);
    MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_DESERIALIZATION_FAILED);
  }
  return atomicNode;
}

MSXML2::IXMLDOMNodePtr CMTCompositeCapabilityBase::ValidateTag(MTAUTHLib::IMTAtomicCapabilityPtr& aAtomicPtr, MSXML2::IXMLDOMNodePtr& aNodePtr, char* aTag)
{
  MSXML2::IXMLDOMNodePtr node = NULL;
  node = aNodePtr->selectSingleNode(aTag);
  if(node == NULL)
  {
    char buf[1024];
    sprintf(buf, "<%s> tag has to be specified on <%s> type", aTag, (char*)aAtomicPtr->CapabilityType->Name);
    LogAuthError(buf);
    MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_DESERIALIZATION_FAILED);
  }
  return node;
}

STDMETHODIMP CMTCompositeCapabilityBase::ToString(IMTCompositeCapability* aThisPtr, BSTR* apXmlString)
{
	try
	{
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = aThisPtr;
    MTAUTHLib::IMTAtomicCapabilityPtr atomicPtr;
    wchar_t buf[1024];
    std::wstring strAtomics;
    MTAUTHLib::IMTCollectionPtr coll = thisPtr->AtomicCapabilities;
    long count = coll->Count;
    for (int i=1; i<=count; ++i)
    {
      atomicPtr = coll->GetItem(i);
      ASSERT (atomicPtr != NULL);
      strAtomics += (wchar_t*)atomicPtr->ToString();
      if(i < count)
        strAtomics += L", ";
    }
    wsprintf(buf, L"'%s': (%s)", (wchar_t*)thisPtr->CapabilityType->Name, strAtomics.c_str());
    _bstr_t bstrOut = buf;
    (*apXmlString) = bstrOut.copy();

	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}
