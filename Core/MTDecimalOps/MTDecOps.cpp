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


// MTDecOps.cpp : Implementation of CMTDecOps
#include "StdAfx.h"
#include "MTDecimalOps.h"
#include "MTDecOps.h"

#include <MTDec.h>
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTDecOps

STDMETHODIMP CMTDecOps::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTDecimalOps
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
STDMETHODIMP CMTDecOps::Add(VARIANT aVal1, VARIANT aVal2, VARIANT *pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE);
		MTDecimal val2(aVal2, TRUE);

		MTDecimal val3 = val1 + val2;

		*pResult = val3;
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
STDMETHODIMP CMTDecOps::Subtract(VARIANT aVal1, VARIANT aVal2, VARIANT *pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE);
		MTDecimal val2(aVal2, TRUE);

		MTDecimal val3 = val1 - val2;

		*pResult = val3;
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
STDMETHODIMP CMTDecOps::Multiply(VARIANT aVal1, VARIANT aVal2, VARIANT * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE);
		MTDecimal val2(aVal2, TRUE);

		MTDecimal val3 = val1 * val2;

		*pResult = val3;
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
STDMETHODIMP CMTDecOps::Divide(VARIANT aVal1, VARIANT aVal2, VARIANT * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE);
		MTDecimal val2(aVal2, TRUE);

		MTDecimal val3 = val1 / val2;

		*pResult = val3;
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: return the absolute value of the argument
// Arguments:   Value - number of apply absolute value
// Return Value: result of absolute value
// Note: NOT IMPLEMENTED
// ----------------------------------------------------------------
STDMETHODIMP CMTDecOps::Abs(VARIANT aValue, VARIANT * pResult)
{
	// TODO: for now
	return E_NOTIMPL;
#if 0
	try
	{
		MTDecimal val1(aValue, TRUE);

		MTDecimal val3 = val1 + val2;

		*pResult = val3;
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	::VariantInit(pResult);
	pResult->vt = VT_DECIMAL;

	if(((aValue.vt & ~VT_BYREF) == VT_DECIMAL))
		return ::VarDecAbs(&aValue.decVal, &(pResult->decVal));
	else
		return E_INVALIDARG;
#endif
}

// ----------------------------------------------------------------
// Description: returns the integer portion of the argument.
//    If the value of the variant is negative, then the first negative integer
//    greater than or equal to the variant is returned.
// Arguments:   Value - number to take integer portion
// Return Value: result of fix computation
// ----------------------------------------------------------------
STDMETHODIMP CMTDecOps::Fix(VARIANT aValue, VARIANT * pResult)
{
	::VariantInit(pResult);
	pResult->vt = VT_DECIMAL;

	if(((aValue.vt & ~VT_BYREF) == VT_DECIMAL))
		return ::VarDecFix(&aValue.decVal, &(pResult->decVal));
	else
		return E_INVALIDARG;
}

// ----------------------------------------------------------------
// Description: returns the integer portion of the argument.
//    If argument is negative, then the first negative integer less than or
//    equal to the argument is returned.
// Arguments:   Value - number to take integer portion
// Return Value: result of int computation
// ----------------------------------------------------------------
STDMETHODIMP CMTDecOps::Int(VARIANT aValue, VARIANT * pResult)
{
	::VariantInit(pResult);
	pResult->vt = VT_DECIMAL;

	if(((aValue.vt & ~VT_BYREF) == VT_DECIMAL))
		return ::VarDecInt(&aValue.decVal, &(pResult->decVal));
	else
		return E_INVALIDARG;

}

// ----------------------------------------------------------------
// Description: returns the logical negative of the argument.
// Arguments:   Value - number to negate
// Return Value: result of negation
// ----------------------------------------------------------------
STDMETHODIMP CMTDecOps::Negate(VARIANT aValue, VARIANT * pResult)
{
	try
	{
		MTDecimal val1(aValue, TRUE);

		MTDecimal val2 = - val1;

		*pResult = val2;
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Description: rounds the argument to the given number of decimal places
// Arguments:   Value - number to round.
//              iDecimals - number of places to round to
// Return Value: result of rounding
// ----------------------------------------------------------------
STDMETHODIMP CMTDecOps::Round(VARIANT aValue, int iDecimals, VARIANT * pResult)
{
	try
	{
		MTDecimal val1(aValue, TRUE);

		MTDecimal val2 = val1.Round(iDecimals);

		*pResult = val2;
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
STDMETHODIMP CMTDecOps::Compare(VARIANT aVal1, VARIANT aVal2, long * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE);
		MTDecimal val2(aVal2, TRUE);

		*pResult = val1.Compare(val2);

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
STDMETHODIMP CMTDecOps::EQ(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE), val2(aVal2, TRUE);

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
STDMETHODIMP CMTDecOps::NE(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE), val2(aVal2, TRUE);

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
STDMETHODIMP CMTDecOps::LT(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE), val2(aVal2, TRUE);

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
STDMETHODIMP CMTDecOps::LE(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE), val2(aVal2, TRUE);

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
STDMETHODIMP CMTDecOps::GT(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE), val2(aVal2, TRUE);

		*pResult = (val1 >= val2) ? VARIANT_TRUE : VARIANT_FALSE;

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
STDMETHODIMP CMTDecOps::GE(VARIANT aVal1, VARIANT aVal2, VARIANT_BOOL * pResult)
{
	try
	{
		MTDecimal val1(aVal1, TRUE), val2(aVal2, TRUE);

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
STDMETHODIMP CMTDecOps::Create(VARIANT Value, VARIANT * pResult)
{
	try
	{
		MTDecimal val1(Value, TRUE);

		*pResult = val1;

		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}
