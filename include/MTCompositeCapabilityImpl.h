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

#ifndef __MTCompositeCapabilityImpl_H__
#define __MTCompositeCapabilityImpl_H__
#pragma once

#include <comdef.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include "MTAuth.h"
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#define CAPIMPL template<class T,const IID* piid, const GUID* plibid> \
                STDMETHODIMP MTCompositeCapabilityImpl<T,piid,plibid>



template<class T,const IID* piid, const GUID* plibid>
class MTCompositeCapabilityImpl : public IDispatchImpl<T,piid,plibid>
{
public:
  MTCompositeCapabilityImpl() 
  {
    //TODO
    mCC.CreateInstance(__uuidof(MTAUTHLib::MTCompositeCapabilityBase));
  }
  virtual ~MTCompositeCapabilityImpl() {}

  STDMETHOD(Save)(IMTPrincipalPolicy* aPolicy);
  STDMETHOD(FromXML)(IDispatch* aDomNode);
  STDMETHOD(ToXML)(BSTR* apXmlString);
  STDMETHOD(Remove)(IMTPrincipalPolicy* aPolicy);
  STDMETHOD(AddAtomicCapability)(IMTAtomicCapability* aAtomicCap);
  STDMETHOD(get_ID)( long *pVal);
  STDMETHOD(put_ID)(long newVal);
  STDMETHOD(get_AtomicCapabilities)(IMTCollection** aCaps);
  STDMETHOD(GetAtomicCapabilityByName)(BSTR aName, IMTAtomicCapability** apCap);
  STDMETHOD(get_CapabilityType)(IMTCompositeCapabilityType** apType);
  STDMETHOD(put_CapabilityType)(IMTCompositeCapabilityType* apType);
  STDMETHOD(GetAtomicEnumCapability)(IMTEnumTypeCapability** apCap);	
  STDMETHOD(GetAtomicPathCapability)(IMTPathCapability** apCap);
  STDMETHOD(GetAtomicDecimalCapability)(IMTDecimalCapability** apCap);
  STDMETHOD(Implies)(IMTCompositeCapability* aDemandedCap, VARIANT_BOOL aCheckparameters, VARIANT_BOOL* aResult);
  STDMETHOD(ToString)(BSTR* apString);
  STDMETHOD(get_ActorAccountID)( long *pVal);
  STDMETHOD(put_ActorAccountID)(long newVal);
  STDMETHOD(GetAtomicCollectionCapability)(IMTStringCollectionCapability** apCap);
private:
  MTAUTHLib::IMTCompositeCapabilityBasePtr mCC;
};


CAPIMPL::Save(IMTPrincipalPolicy* aPolicy)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;
    mCC->Save(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy); return S_OK;
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
}

CAPIMPL::Remove(IMTPrincipalPolicy* aPolicy)  
{	
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    mCC->Remove(thisPtr, (MTAUTHLib::IMTPrincipalPolicy*)aPolicy); 
    return S_OK;	
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
}	

CAPIMPL::AddAtomicCapability(IMTAtomicCapability* aAtomicCap)	
{	
  try
  {
    mCC->AddAtomicCapability((MTAUTHLib::IMTAtomicCapability*)aAtomicCap); 
    return S_OK;
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
}	

CAPIMPL::get_ID( long *pVal)	
{	
  (*pVal) = mCC->ID; 
  return S_OK; 
}	

CAPIMPL::put_ID(long newVal)	
{	
  mCC->ID = newVal; 
  return S_OK; 
}	

CAPIMPL::get_ActorAccountID( long *pVal)	
{	
  (*pVal) = mCC->ActorAccountID; 
  return S_OK; 
}	

CAPIMPL::put_ActorAccountID(long newVal)	
{	
  mCC->ID = newVal; 
  return S_OK; 
}	

CAPIMPL::get_AtomicCapabilities(IMTCollection** aCaps)	
{
  try
  {
    MTAUTHLib::IMTCollectionPtr outPtr = mCC->AtomicCapabilities;	
    (*aCaps) = (IMTCollection*)outPtr.Detach(); 
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}

  return S_OK; 
}	

CAPIMPL::GetAtomicCapabilityByName(BSTR aName, IMTAtomicCapability** apCap)	
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    MTAUTHLib::IMTAtomicCapabilityPtr outPtr = mCC->GetAtomicCapabilityByName(thisPtr, aName);	
    (*apCap) = (IMTAtomicCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
  return S_OK;
}	

CAPIMPL::get_CapabilityType(IMTCompositeCapabilityType** apType)	
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    MTAUTHLib::IMTCompositeCapabilityTypePtr outPtr = mCC->GetCapabilityType(thisPtr);
    (*apType) = (IMTCompositeCapabilityType*)outPtr.Detach(); return S_OK;
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
}

CAPIMPL::put_CapabilityType(IMTCompositeCapabilityType* apType)	
{ 
  try
  {
    mCC->SetCapabilityType((MTAUTHLib::IMTCompositeCapabilityType*)apType); 
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
  return S_OK; 
} 

CAPIMPL::GetAtomicEnumCapability(IMTEnumTypeCapability** apCap)	
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    MTAUTHLib::IMTEnumTypeCapabilityPtr outPtr = mCC->GetAtomicEnumCapability(thisPtr);	
    (*apCap) = (IMTEnumTypeCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  return S_OK;
}	

CAPIMPL::GetAtomicPathCapability(IMTPathCapability** apCap)	
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    MTAUTHLib::IMTPathCapabilityPtr outPtr = mCC->GetAtomicPathCapability(thisPtr);	
    (*apCap) = (IMTPathCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  return S_OK;
}	

CAPIMPL::GetAtomicDecimalCapability(IMTDecimalCapability** apCap)	
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    MTAUTHLib::IMTDecimalCapabilityPtr outPtr = mCC->GetAtomicDecimalCapability(thisPtr);	
    (*apCap) = (IMTDecimalCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  return S_OK;
}	

CAPIMPL::Implies(IMTCompositeCapability* aDemandedCap, VARIANT_BOOL aCheckparameters, VARIANT_BOOL* aResult)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;
	  MTAUTHLib::IMTCompositeCapabilityPtr demandedCap = aDemandedCap;
	  (*aResult) = mCC->Implies(thisPtr, demandedCap, aCheckparameters); 
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
  return S_OK;

}
	
CAPIMPL::FromXML(IDispatch* aDomNode)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    mCC->FromXML(thisPtr, aDomNode); 
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
  return S_OK;

}

CAPIMPL::ToXML(BSTR* apXmlString)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    (*apXmlString) = mCC->ToXML(thisPtr).copy(); 
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
  return S_OK;

}

CAPIMPL::ToString(BSTR* apString)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    (*apString) = mCC->ToString(thisPtr).copy(); 
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  
  return S_OK;

}

CAPIMPL::GetAtomicCollectionCapability(IMTStringCollectionCapability** apCap)	
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr thisPtr = this;	
    MTAUTHLib::IMTStringCollectionCapabilityPtr outPtr = mCC->GetAtomicCollectionCapability(thisPtr);	
    (*apCap) = (IMTStringCollectionCapability*)outPtr.Detach();
  }
  catch(_com_error& e)
	{
		//LOGTODO: 
		return ReturnComError(e);
	}
  return S_OK;
}	
#endif //__MTCompositeCapabilityImpl_H__