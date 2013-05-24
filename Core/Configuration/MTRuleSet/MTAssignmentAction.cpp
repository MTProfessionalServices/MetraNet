// MTAssignmentAction.cpp : Implementation of CMTAssignmentAction
#include "StdAfx.h"
#include "MTRuleSet.h"
#include "MTAssignmentAction.h"

#include <comutil.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAssignmentAction

STDMETHODIMP CMTAssignmentAction::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAssignmentAction,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAssignmentAction::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTAssignmentAction::FinalRelease()
{
}

// ----------------------------------------------------------------
// Description: The name of the property to set.
// Return Value: name of the property
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::get_PropertyName(BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mPropName.copy();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: The name of the property to set.
// Argument: name - name of the property
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::put_PropertyName(BSTR newVal)
{
	mPropName = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The value to assign to the named property
// Return Value: The value to assign to the named property
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::get_PropertyValue(VARIANT * pVal)
{
	if (!pVal)
		return E_POINTER;

	::VariantInit(pVal);
	::VariantCopy(pVal, &mValue);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: The value to assign to the named property
// Argument: value - The value to assign to the named property
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::put_PropertyValue(VARIANT newVal)
{
	mValue = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Description: The type of the value to assign to the property
// Return Value: type enumeration
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::get_PropertyType(/*[out, retval]*/ ::PropValType *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mType;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: The type of the value to assign to the property
// Argument: type - type enumeration
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::put_PropertyType(::PropValType val)
{
	mType = val;

	return S_OK;
}

// ----------------------------------------------------------------
// Description: If the property value is an enumerated type, this property
//              holds the enum type's enum space.
// Return Value: enum space
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::get_EnumSpace(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	*pVal = mEnumSpace.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description: If the property value is an enumerated type, this property
//              holds the enum type's enum space.
// Argument: enumspace - enum space
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::put_EnumSpace(BSTR newVal)
{
	mEnumSpace = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: If the property value is an enumerated type, this property
//              holds the enum type's enum type name
// Return Value: enum type
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::get_EnumType(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	*pVal = mEnumType.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description: If the property value is an enumerated type, this property
//              holds the enum type's enum type name
// Return Value: type - enum type name
// ----------------------------------------------------------------
STDMETHODIMP CMTAssignmentAction::put_EnumType(BSTR newVal)
{
	mEnumType = newVal;
	return S_OK;
}

