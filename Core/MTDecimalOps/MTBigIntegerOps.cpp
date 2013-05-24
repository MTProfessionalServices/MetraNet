/**************************************************************************
 * MTDecOps
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
 * Created by: Roman Krichevsky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


// MTDecOps.cpp : Implementation of CMTBigIntegerOps
#include "StdAfx.h"
#include "MTDecimalOps.h"
#include "MTBigIntegerOps.h"

#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTBigIntegerOps

STDMETHODIMP CMTBigIntegerOps::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTBigIntegerOps
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Description: return the sum of the the arguments
// Arguments:   numbers to add.
// Return Value: result of addition
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::Add(VARIANT aVal1, VARIANT aVal2, VARIANT *pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);
		_variant_t val3 = val1 + val2;

    ::VariantInit(pResult);
    ::VariantCopy(pResult, &val3);
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: return the difference of the arguments
// Arguments:   numbers to subtract
// Return Value: result of subtraction
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::Subtract(VARIANT aVal1, VARIANT aVal2, VARIANT *pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);
		_variant_t val3 = val1 - val2;

    ::VariantInit(pResult);
    ::VariantCopy(pResult, &val3);
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: return the product of the arguments
// Arguments:   numbers to multiply
// Return Value: result of multiplication
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::Multiply(VARIANT aVal1, VARIANT aVal2, VARIANT * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);
		_variant_t val3 = val1 * val2;

    ::VariantInit(pResult);
    ::VariantCopy(pResult, &val3);
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: return the first argument divided by the second
// Arguments:   numbers to divide
// Return Value: result of division
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::Divide(VARIANT aVal1, VARIANT aVal2, VARIANT * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);
		_variant_t val3 = val1 / val2;

    ::VariantInit(pResult);
    ::VariantCopy(pResult, &val3);
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: return a comparison of the two arguments
// Arguments:   numbers to compare
// Return Value: 0 if first argument is less than second
//               1 if first argument is equal than second
//               2 if first argument is greater than second
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::Compare(VARIANT aVal1, VARIANT aVal2, long * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);

		*pResult = val1 < val2 ? -1 : val1==val2 ? 0 : 1;

		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: return true if first argument is equal to second
// Arguments:   numbers to compare
// Return Value: true if values are equal
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::EQ(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);

		*pResult = (val1 == val2) ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: return true if first argument is not equal to second
// Arguments:   numbers to compare
// Return Value: true if values are not equal
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::NE(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);

		*pResult = (val1 != val2) ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: return true if first argument is less than the second
// Arguments:   numbers to compare
// Return Value: true if first argument is less than the second
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::LT(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);
		*pResult = (val1 < val2) ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: return true if first argument is less than or equal to the second
// Arguments:   numbers to compare
// Return Value: true if first argument is less than or equal to the second
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::LE(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);

		*pResult = (val1 <= val2) ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: return true if first argument is greater than the second
// Arguments:   numbers to compare
// Return Value: true if first argument is greater than the second
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::GT(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);

		*pResult = (val1 > val2) ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: return true if first argument is greater than or equal to the second
// Arguments:   numbers to compare
// Return Value: true if first argument is greater than or equal to the second
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::GE(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
    __int64 val1 = _variant_t(aVal1);
    __int64 val2 = _variant_t(aVal2);

		*pResult = (val1 >= val2) ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: Create a decimal value out of the argument
// Arguments:   Value - string or number to create a decimal out of
// Return Value: decimal value as a variant
// ----------------------------------------------------------------
STDMETHODIMP CMTBigIntegerOps::Create(VARIANT Value, VARIANT * pResult)
{
	try
	{
    _variant_t val = _variant_t(__int64(_variant_t(Value)));

    ::VariantInit(pResult);
    ::VariantCopy(pResult, &val);

		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}
