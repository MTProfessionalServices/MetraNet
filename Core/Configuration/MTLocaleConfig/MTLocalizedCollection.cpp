/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* $Header$
* 
***************************************************************************/

// MTLocalizedCollection.cpp : Implementation of CMTLocalizedCollection
#include "StdAfx.h"
#include "MTLocaleConfig.h"
#include "MTLocalizedCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTLocalizedCollection

// ----------------------------------------------------------------
// Name:     			get__NewEnum
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   NOT USED DIRECTLY
// ----------------------------------------------------------------
/*
STDMETHODIMP CMTLocalizedCollection::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);
	int size = mLocalizedMap.size();

	// Note: end pointer has to be one past the end of the list
	if (size == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
		LocalizedMapIt it = mLocalizedMap.begin();
		AdvanceIterator(&it, (size-1) );
		
		hr = pEnumVar->Init(&(*mLocalizedMap.begin()).second, 
							&((*it).second) + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}
*/
// ----------------------------------------------------------------
// Name:     			get_Size
// Arguments:     
// Return Value:  long*			-		collection size
// Errors Raised: 
// Description:   Returns number of loclaized entries
// ----------------------------------------------------------------
STDMETHODIMP CMTLocalizedCollection::get_Size(long * pSize)
{
	if (!pSize)
		return E_POINTER;
	*pSize = (long)mLocalizedMap.size();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Count
// Arguments:     
// Return Value:  long*			-		collection size
// Errors Raised: 
// Description:   Returns number of loclaized entries
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (long)mLocalizedMap.size();

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Item
// Arguments:     long				-		index
// Return Value:  VARIANT*			-		MTLocalizedEntry object
// Errors Raised: 
// Description:   Returns MTLocalizedEntry object at a specified index
//								in collection
// ----------------------------------------------------------------

/*
STDMETHODIMP CMTLocalizedCollection::get_Item(long aIndex, VARIANT * pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	//VariantInit(pVal);
	pVal->vt = VT_DISPATCH;
	pVal->pdispVal = NULL;

	if (aIndex < 0)
		return E_INVALIDARG;

	if ((aIndex < 1) || ((unsigned long)aIndex > mLocalizedMap.size()))
		return E_INVALIDARG;
	
	
	//initialized iterator to collection begin
	LocalizedMapIt it = mLocalizedMap.begin();

	::VariantClear(pVal);
	AdvanceIterator(&it, (aIndex-1) );
	::VariantCopy(pVal, &((*it).second) );

	return S_OK;
}
*/
// ----------------------------------------------------------------
// Name:     			Add
// Arguments:     IMTLocalizedEntry*				-		object to add to collection
// Return Value:  VARIANT*			-		MTLocalizedEntry object
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::Add(BSTR aExtension, BSTR aNamespace, BSTR aLangCode, BSTR aFQN, BSTR aValue)
{
	HRESULT hr = S_OK;

	CMTLocalizedEntry*	pEntry = new CMTLocalizedEntry(aExtension, aNamespace, aLangCode, aFQN, aValue);
	ASSERT(pEntry);
	InsertEntryIntoCollection(aFQN, aLangCode, pEntry);
	return hr;

}

// ----------------------------------------------------------------
// Name:     			get_languageCode
// Arguments:     
// Return Value:  BSTR*			-		language code
// Errors Raised: 
// Description:   CURRENTLY NOT USED
// ----------------------------------------------------------------

/*
STDMETHODIMP CMTLocalizedCollection::get_LanguageCode(BSTR *pVal)
{
	*pVal = mLanguageCode.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_languageCode
// Arguments:     
// Return Value:  BSTR*			-		language code
// Errors Raised: 
// Description:   CURRENTLY NOT USED
// ----------------------------------------------------------------


STDMETHODIMP CMTLocalizedCollection::put_LanguageCode(BSTR newVal)
{
	mLanguageCode = newVal;
	return S_OK;
}
*/
// ----------------------------------------------------------------
// Name:     			Clear
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Clear internal collection
// ----------------------------------------------------------------


STDMETHODIMP CMTLocalizedCollection::Clear()
{
	LocalizedMapIt it;
	for(it = mLocalizedMap.begin(); it != mLocalizedMap.end(); it++)
	{
		delete (*it).second;
		(*it).second = NULL;
	}
	mLocalizedMap.clear();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			InsertEntryIntoCollection
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

BOOL CMTLocalizedCollection::InsertEntryIntoCollection(BSTR fqn, BSTR lang, CMTLocalizedEntry* pEntry)
{
	//attach language code to FQN and convert to lower case
	_bstr_t lwrFQN = _wcslwr(_bstr_t (lang) + "/" +_bstr_t(fqn)	);
	LocalizedMapIt it;
	
	
	it = mLocalizedMap.find(lwrFQN);

	if(it != mLocalizedMap.end()) //about to add duplicate entry
			mLogger->LogVarArgs(LOG_DEBUG, "Pair with key <%s> already exists in collection, replacing it", (const char*)lwrFQN);
	mLocalizedMap[lwrFQN] = pEntry;

	return TRUE;
}

// ----------------------------------------------------------------
// Name:     			AdvanceIterator
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

void CMTLocalizedCollection::AdvanceIterator(LocalizedMapIt* it, const int offset)
{
	//looks pretty ugly, but it's the only way to make getItem(idx)
	//and new_enum work without having a random access iterator or
	//doing too much work

	for (int i = 0; i < offset; i++)
		(*it)++;
}

// ----------------------------------------------------------------
// Name:     			Find
// Arguments:     BSTR fqn			-		fully qualified name
//								BSTR lang			-		language code
// Return Value:  VARIANT* pVal	-		IMTLocalizedEntry object
// Errors Raised: 
// Description:   Returnes IMTLocalizedEntry object by specified fqn
//								and language code
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::Find(BSTR fqn, BSTR lang, BSTR*	pVal)
{
	
	if (pVal == NULL)
		return E_POINTER;

	_bstr_t map_key  = _wcslwr(_bstr_t(lang) + "/" + _bstr_t(fqn));

	//initialized iterator to collection begin
	LocalizedMapIt it = mLocalizedMap.find(map_key);
	if (it != mLocalizedMap.end())
	{
		(*pVal) = (*it).second->GetLocalizedString().copy();
		return S_OK;
	}
	else
	{
		mLogger->LogVarArgs(LOG_DEBUG, "Can not find entry <%s>", (const char*)map_key);
		(*pVal) = ::SysAllocString(L"");
		return S_OK;
	}
}

// ----------------------------------------------------------------
// Name:     			Begin
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   sets internal iterator to collection's begin
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::Begin()
{
	mIterator = mLocalizedMap.begin();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			Next
// Arguments:     
// Return Value:  VARIANT*		-		next IMTLocalizedEntry object in collection
// Errors Raised: 
// Description:   next IMTLocalizedEntry object in collection
//								USE:	coll->Begin();
//											while(!coll->End())
//												item = coll->Next();
//											...
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::Next()
{
	mIterator++;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			End
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   returns 1 if internal iterator points beyond collection's
//								last element or 0 otherwise
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::End(int *pVal)
{
	(*pVal) = (mIterator == mLocalizedMap.end());
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetFQN
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   returns FQN of an element at current iterator position
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::GetFQN(BSTR* pVal)
{
	(*pVal) = (*mIterator).second->GetFQN().copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetExtension
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   returns Extension of an element at current iterator position
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::GetExtension(BSTR* pVal)
{
	(*pVal) = (*mIterator).second->GetExtension().copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetNamespace
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   returns Namespace of an element at current iterator position
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::GetNamespace(BSTR* pVal)
{
	(*pVal) = (*mIterator).second->GetNamespace().copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetLanguageCode
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   returns LanguageCode of an element at current iterator position
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::GetLanguageCode(BSTR* pVal)
{
	(*pVal) = (*mIterator).second->GetLanguageCode().copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetLocalizedString
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   returns LanguageCode of an element at current iterator position
// ----------------------------------------------------------------

STDMETHODIMP CMTLocalizedCollection::GetLocalizedString(BSTR* pVal)
{
	(*pVal) = (*mIterator).second->GetLocalizedString().copy();
	return S_OK;
}



// ----------------------------------------------------------------
// Name:     			End
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description: Internal use only: get the this pointer through IID_NULL interface
// ----------------------------------------------------------------

HRESULT WINAPI _This(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}

