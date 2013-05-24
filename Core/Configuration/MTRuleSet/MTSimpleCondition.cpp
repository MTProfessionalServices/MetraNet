// MTSimpleCondition.cpp : Implementation of CMTSimpleCondition
#include "StdAfx.h"
#include "MTRuleSet.h"

#include <comutil.h>

#include "MTSimpleCondition.h"

#include <metra.h>
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSimpleCondition

STDMETHODIMP CMTSimpleCondition::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSimpleCondition,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTSimpleCondition::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTSimpleCondition::FinalRelease()
{
}

// ----------------------------------------------------------------
// Description:  name of the property to test
// Return Value: property name
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::get_PropertyName(BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mPropName.copy();

	return S_OK;
}

// ----------------------------------------------------------------
// Description:  name of the property to test
// Argument: name - property name
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::put_PropertyName(BSTR newVal)
{
	mPropName = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  operator used to test the property value
// Return Value: Possible values are:
//                equal  equals  =  ==
//                less_than  <
//                greater_than  >
//                less_equal  <=
//                greater_equal  >=
//                not_equal  not_equals !=
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::get_Test(BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mCondition.copy();

	return S_OK;
}

// ----------------------------------------------------------------
// Description:  operator used to test the property value
// Return Value: operator - Possible values are
//                equal  equals  =  ==
//                less_than  <
//                greater_than  >
//                less_equal  <=
//                greater_equal  >=
//                not_equal  not_equals !=
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::put_Test(BSTR newVal)
{
	mCondition = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  value to compare property value to
// Return Value: value used in comparison
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::get_Value(VARIANT * pVal)
{
	if (!pVal)
		return E_POINTER;

	::VariantInit(pVal);
	::VariantCopy(pVal, &mValue);
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  value to compare property value to
// Argument: value used in comparison
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::put_Value(VARIANT newVal)
{
	mValue = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Description:  type of the property value
// Return Value: enumerated type holding property's type
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::get_ValueType(/*[out, retval]*/ ::PropValType *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mType;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  type of the property value
// Return Value: type - enumerated type holding property's type
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::put_ValueType(/*[in]*/ ::PropValType newVal)
{
	mType = newVal;

	return S_OK;
}

// ----------------------------------------------------------------
// Description:  if the property is an enumerated type, this property
//               holds the enum space to use
// Return Value: enum space to use
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::get_EnumSpace(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	*pVal = mEnumSpace.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  if the property is an enumerated type, this property
//               holds the enum space to use
// Argument: enumspace - enum space to use
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::put_EnumSpace(BSTR newVal)
{
	mEnumSpace = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  if the property is an enumerated type, this property
//               holds the enum space to use within the enum space
// Return Value: enum type within the enum space to use
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::get_EnumType(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	*pVal = mEnumType.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  if the property is an enumerated type, this property
//               holds the enum space to use within the enum space
// Return Value: enumtype - enum type within the enum space to use
// ----------------------------------------------------------------
STDMETHODIMP CMTSimpleCondition::put_EnumType(BSTR newVal)
{
	mEnumType = newVal;
	return S_OK;
}
