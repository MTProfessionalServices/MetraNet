/**************************************************************************
 * MTDEC
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metralite.h>
#include <MTDec.h>
#include <MTDecimalVal.h>
#include <MTUtil.h>
#include <mtcomerr.h>

const MTDecimal MTDecimal::ZERO;

// A decimal value is represented as a 96-bit unsigned integer
// that is scaled by a variable power of 10.  
// The DECIMAL struct has these fields:
//   WORD wReserved;  
//   BYTE scale;      
//   BYTE sign;       
//   ULONG Hi32;      
//   ULONGLONG Lo64;  

//
// assignment/constructors
//

MTDecimal::MTDecimal()
{
	mValue.Lo64 = 0;
	mValue.signscale = 0;
	mValue.Hi32 = 0;
}

MTDecimal::MTDecimal(DECIMAL aDec)
{
	mValue = aDec;
}

BOOL IsDecimal(VARIANT & aVar)
{
 if (aVar.vt == (VT_DECIMAL | VT_BYREF)
		 || aVar.vt == VT_DECIMAL)
	 return TRUE;

 if (aVar.vt == (VT_VARIANT | VT_BYREF))
 {
	 VARIANT * var = aVar.pvarVal;
	 return IsDecimal(*var);
 }

 return FALSE;
}

MTDecimal::MTDecimal(VARIANT aVar, BOOL aAllowConversion /* = FALSE */)
{
#if 0
	if (!aAllowConversion)
		ASSERT(IsDecimal(aVar));
#endif

	// NOTE: could throw

	//WARNING: this could potentially convert doubles
	//to decimals, so the type must be checked before this
	_variant_t varDec = aVar;

	mValue = (DECIMAL) varDec;
}

MTDecimal::MTDecimal(const MTDecimal & arDec)
{
	*this = arDec;
}

MTDecimal::MTDecimal(const MTDecimalVal & arDecValue)
{
	char buffer[100];
	int len = sizeof(buffer);
	if (!arDecValue.Format(buffer, len))
		MT_THROW_COM_ERROR(L"Unable to parse decimal");

	SetValue(std::string(buffer));
}

MTDecimal::MTDecimal(const std::string& arInputStr)
{
	BOOL result = SetValue(arInputStr);
	
	//TODO: better error handling here
	ASSERT(result);
}

MTDecimal::MTDecimal(const char* apInputStr)
{
	BOOL result = SetValue(std::string(apInputStr));
	
	//TODO: better error handling here
	ASSERT(result);
}



MTDecimal::MTDecimal(long long aUnits, long long aFrac)
{
	SetValue(aUnits, aFrac);
}

MTDecimal::MTDecimal(long long aUnits)
{
	SetValue(aUnits);
}

MTDecimal::MTDecimal(long aUnits)
{
	SetValue((long long)aUnits);
}

MTDecimal & MTDecimal::operator = (const MTDecimal & arDec)
{
	mValue = arDec;
	return *this;
}

MTDecimal & MTDecimal::operator = (const DECIMAL & arDec)
{
	mValue = arDec;
	return *this;
}

MTDecimal & MTDecimal::operator = (const VARIANT & arVar) {
#if 0
	ASSERT(arVar.vt == VT_DECIMAL);
#endif

	// NOTE: this could throw

	//WARNING: this could potentially convert doubles
	//to decimals, so the type must be checked before this
	_variant_t varDec = arVar;

	mValue = (DECIMAL) varDec;

	return *this;
}

MTDecimal & MTDecimal::operator = (long long aUnits)
{
	SetValue(aUnits);
	return *this;
}

// Set the MTDecimal's value to a long long.
void MTDecimal::SetValue(long long aUnits)
{
    ULONGLONG unsignedUnits;
	if (aUnits >= 0)
	{
	    unsignedUnits = aUnits;
		mValue.sign = 0;
	}
	else
	{
	    unsignedUnits = -aUnits;
		mValue.sign = 0x80;
	}
	
	mValue.wReserved = VT_DECIMAL;
	mValue.Lo64 = unsignedUnits;
	mValue.Hi32 = 0;
	mValue.scale = 0;
}

// aFrac must be in units of 10^-10.
// A negative number is indicated by passing a negative value for aUnits.
// Type long (4 bytes) can only represent 9 decimal digits fully,
// so we need to use long long.
void MTDecimal::SetValue(long long aUnits, long long aFrac)
{
	ASSERT((aFrac >= 0) && (aFrac <= 9999999999));
	
	// Convert aUnits to a DECIMAL.
	MTDecimal unitsMtDec(aUnits);
	
	// Convert aFrac to a DECIMAL and divide by 10^10 to get a fraction.
	long long signedFrac;
	if (aUnits >= 0)
	{
	    signedFrac = aFrac;
	}
	else
	{
	    signedFrac = -aFrac;
	}
	MTDecimal fracMtDec(signedFrac);
	fracMtDec = fracMtDec/10000000000;
	
	// Add the units and fraction together.
	// The math functions are not const correct.
	HRESULT hr = ::VarDecAdd(const_cast<DECIMAL *>(&unitsMtDec),
							 const_cast<DECIMAL *>(&fracMtDec),
							 &mValue);
							 
	if (FAILED(hr))
	{
		MT_THROW_COM_ERROR(hr);
	}
}

std::string MTDecimal::Format(int aNumFixed, BOOL aUseCommas, BOOL aUseParens, BOOL aShowLeading) const
{
	_variant_t var(mValue);
	BSTR bstrVal;

	//maps simple MTDecimal boolean logic to 3 value VarFormatNumber logic
	if (aUseCommas)
		aUseCommas = -1;
	if (aUseParens)
		aUseParens = -1;
	if (aShowLeading)
		aShowLeading = -1;

	HRESULT hr = ::VarFormatNumber(&var, aNumFixed, aShowLeading, aUseParens, aUseCommas, 0, &bstrVal);
	if (FAILED(hr)) {
		MT_THROW_COM_ERROR(hr);
	}

	// attach to the BSTR so it's deleted when out of scope
	_bstr_t number(bstrVal, false);
	return std::string((const char *) number);
}


//
// binary arithmetic operators
//

MTDecimal MTDecimal::operator / (const MTDecimal & arDec) const
{
	DECIMAL result;

	// the math functions are not const correct
	HRESULT hr = ::VarDecDiv(const_cast<DECIMAL *>(&mValue), const_cast<DECIMAL *>(&arDec), &result);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return MTDecimal(result);
}

MTDecimal MTDecimal::operator + (const MTDecimal & arDec) const
{
	DECIMAL result;

	// the math functions are not const correct
	HRESULT hr = ::VarDecAdd(const_cast<DECIMAL *>(&mValue), const_cast<DECIMAL *>(&arDec), &result);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return MTDecimal(result);
}

MTDecimal& MTDecimal::operator +=(const MTDecimal & arDec)
{
	*this = operator+(arDec);
	return *this;
}


MTDecimal MTDecimal::operator * (const MTDecimal & arDec) const
{
	DECIMAL result;

	// the math functions are not const correct
	HRESULT hr = ::VarDecMul(const_cast<DECIMAL *>(&mValue), const_cast<DECIMAL *>(&arDec), &result);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return MTDecimal(result);
}

MTDecimal& MTDecimal::operator *=(const MTDecimal & arDec)
{
	*this = operator*(arDec);
	return *this;
}

MTDecimal MTDecimal::operator - (const MTDecimal & arDec) const
{
	DECIMAL result;

	// the math functions are not const correct
	HRESULT hr = ::VarDecSub(const_cast<DECIMAL *>(&mValue), const_cast<DECIMAL *>(&arDec), &result);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return MTDecimal(result);
}

MTDecimal& MTDecimal::operator -=(const MTDecimal & arDec)
{
	*this = operator-(arDec);
	return *this;
}
	

//
// unary operators
//

MTDecimal MTDecimal::operator - ()
{
	DECIMAL result;

	// the math functions are not const correct
	HRESULT hr = ::VarDecNeg(&mValue, &result);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return MTDecimal(result);

}


MTDecimal MTDecimal::Abs() const
{
	DECIMAL result;

	// the math functions are not const correct
	HRESULT hr = ::VarDecAbs(const_cast<LPDECIMAL>(&mValue), &result);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return MTDecimal(result);

}


//
// decimal comparisons
//

BOOL MTDecimal::operator < (const MTDecimal & arDec) const
{
	int comp = Compare(arDec);
	return comp == VARCMP_LT;
}

BOOL MTDecimal::operator <= (const MTDecimal & arDec) const
{
	int comp = Compare(arDec);
	return comp == VARCMP_LT || comp == VARCMP_EQ;
}

BOOL MTDecimal::operator > (const MTDecimal & arDec) const
{
	int comp = Compare(arDec);
	return comp == VARCMP_GT;
}

BOOL MTDecimal::operator >= (const MTDecimal & arDec) const
{
	int comp = Compare(arDec);
	return comp == VARCMP_GT || comp == VARCMP_EQ;
}

BOOL MTDecimal::operator == (const MTDecimal & arDec) const
{
	int comp = Compare(arDec);
	return comp == VARCMP_EQ;
}

BOOL MTDecimal::operator != (const MTDecimal & arDec) const
{
	int comp = Compare(arDec);
	return comp != VARCMP_EQ;
}

int MTDecimal::Compare(const MTDecimal & arDec) const
{
	HRESULT hr = ::VarDecCmp(const_cast<DECIMAL *>(&mValue), const_cast<DECIMAL *>(&arDec));
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	ASSERT(hr == VARCMP_LT
				 || hr == VARCMP_EQ
				 || hr == VARCMP_GT);

	return hr;
}

//
// double comparisons
//
BOOL MTDecimal::operator < (double aDouble) const
{
	int comp = Compare(aDouble);
	return comp == VARCMP_LT;
}

BOOL MTDecimal::operator <= (double aDouble) const
{
	int comp = Compare(aDouble);
	return comp == VARCMP_LT || comp == VARCMP_EQ;
}

BOOL MTDecimal::operator > (double aDouble) const
{
	int comp = Compare(aDouble);
	return comp == VARCMP_GT;
}

BOOL MTDecimal::operator >= (double aDouble) const
{
	int comp = Compare(aDouble);
	return comp == VARCMP_GT || comp == VARCMP_EQ;
}

BOOL MTDecimal::operator == (double aDouble) const
{
	int comp = Compare(aDouble);
	return comp == VARCMP_EQ;
}

BOOL MTDecimal::operator != (double aDouble) const
{
	int comp = Compare(aDouble);
	return comp != VARCMP_EQ;
}

int MTDecimal::Compare(double aDouble) const
{

	HRESULT hr = ::VarDecCmpR8(const_cast<DECIMAL *>(&mValue), aDouble);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	ASSERT(hr == VARCMP_LT
				 || hr == VARCMP_EQ
				 || hr == VARCMP_GT);

	return hr;
}

// routine to convert from string to decimal
BOOL MTDecimal::SetValue(const std::string& arInputStr)
{
	// step 1: basic length checking
	if(arInputStr.length() == 0) {
		return FALSE;
	}

	// step 2: get the locale
	LCID aLocaleID = ::GetThreadLocale();
	

	// step 3: convert the string to a decimal
	HRESULT nRetVal;
	nRetVal = VarDecFromStr((wchar_t*) _bstr_t(arInputStr.c_str()), // input string value
													aLocaleID,
													LOCALE_NOUSEROVERRIDE, // Uses the system default locale settings, rather than custom locale settings.
													&mValue);
	
	if (FAILED(nRetVal))
		return FALSE;
	
	return TRUE;
} 

MTDecimal MTDecimal::FractionalValue()
{
	return operator-(IntegerValue());
}

MTDecimal MTDecimal::IntegerValue()
{
	MTDecimal aTemp;
	HRESULT hr = ::VarDecInt(&mValue,&aTemp);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return aTemp;
}

MTDecimal MTDecimal::FixValue()
{
	MTDecimal aTemp;
	HRESULT hr = ::VarDecFix(&mValue,&aTemp);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return aTemp;
}

MTDecimal MTDecimal::Min(MTDecimal & arDec1, MTDecimal & arDec2) {
	if (arDec1 <= arDec2)
		return arDec1;
	else
		return arDec2;
}

MTDecimal MTDecimal::Max(MTDecimal & arDec1, MTDecimal & arDec2) {
	if (arDec1 >= arDec2)
		return arDec1;
	else
		return arDec2;
}

MTDecimal MTDecimal::Floor() {
	*this = IntegerValue();
	return *this;
}

MTDecimal MTDecimal::Round(int aPlaces) 
{
	MTDecimal aTemp;
	HRESULT hr = ::VarDecRound(&mValue, aPlaces, &aTemp);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);
	*this = aTemp;

	return *this;
}


MTDecimal::operator _variant_t () const
{
	_variant_t temp(mValue);
	return temp;
}

class RoundFunctionBase 
{
protected:
  // This is the procedure for rounding when scale = 0
  virtual MTDecimal internalRound(MTDecimal& arg) =0;

public:
  MTDecimal round(MTDecimal& arg, int scale)
  {
    int absScale = scale < 0 ? -scale : scale;
    DECIMAL tenOrTenth;
    tenOrTenth.Hi32 = 0;
    tenOrTenth.sign = 0;
    if(scale < 0)
    {
      // Multiply by 0.1
      tenOrTenth.Lo64 = 1;
      tenOrTenth.scale = 1;
    }
    else
    {
      // Multiply by 10
      tenOrTenth.Lo64 = 10;
      tenOrTenth.scale = 0;
    }
    for(int i=0; i<absScale; i++)
    {
      arg *= MTDecimal(tenOrTenth);
    }

    arg = internalRound(arg);

    if(scale >= 0)
    {
      // Multiply by 0.1
      tenOrTenth.Lo64 = 1;
      tenOrTenth.scale = 1;
    }
    else
    {
      // Multiply by 10
      tenOrTenth.Lo64 = 10;
      tenOrTenth.scale = 0;
    }
    for(int i=0; i<absScale; i++)
    {
      arg *= MTDecimal(tenOrTenth);
    }

    return arg;
  }
};

class SymmetricArithmeticRoundFunction : public RoundFunctionBase
{
protected:
  MTDecimal internalRound(MTDecimal& arg)
  {
    DECIMAL oneHalfOrMinusOneHalf;
    oneHalfOrMinusOneHalf.Lo64 = 5;
    oneHalfOrMinusOneHalf.Hi32 = 0;
    oneHalfOrMinusOneHalf.sign = (&arg)->sign;
    oneHalfOrMinusOneHalf.scale = 1;

    arg += MTDecimal(oneHalfOrMinusOneHalf);
    return arg.FixValue();
  }
};

class AsymmetricArithmeticRoundFunction : public RoundFunctionBase
{
protected:
  MTDecimal internalRound(MTDecimal& arg)
  {
    DECIMAL oneHalfOrMinusOneHalf;
    oneHalfOrMinusOneHalf.Lo64 = 5;
    oneHalfOrMinusOneHalf.Hi32 = 0;
    oneHalfOrMinusOneHalf.sign = 0;
    oneHalfOrMinusOneHalf.scale = 1;

    arg += MTDecimal(oneHalfOrMinusOneHalf);
    return arg.IntegerValue();
  }
};

class BankersRoundFunction : public RoundFunctionBase
{
protected:
  MTDecimal internalRound(MTDecimal& arg)
  {
    DECIMAL oneHalfOrMinusOneHalf;
    oneHalfOrMinusOneHalf.Lo64 = 5;
    oneHalfOrMinusOneHalf.Hi32 = 0;
    BYTE sign = oneHalfOrMinusOneHalf.sign = (&arg)->sign;
    oneHalfOrMinusOneHalf.scale = 1;

    MTDecimal fixTemp = (arg + MTDecimal(oneHalfOrMinusOneHalf)).FixValue();

    // We have a symmetric arithmetic round; now correct for
    // the case where fractional value is 0.5 (in this case round to nearest
    // even number).
      
    // Take the absolute value of 1/2
    oneHalfOrMinusOneHalf.sign = 0;
    if(MTDecimal(oneHalfOrMinusOneHalf) == arg.FractionalValue())
    {
      if ((fixTemp/MTDecimal(2L)) != (fixTemp/MTDecimal(2L)).IntegerValue())
      {
        fixTemp -= MTDecimal(sign == 0 ? 1L : -1L);
      }
    }
    return fixTemp;
  }
};

MTDecimal MTDecimal::SymmetricArithmeticRound(int aPlaces) 
{
  SymmetricArithmeticRoundFunction rnd;
  *this = rnd.round(*this, aPlaces);
  return *this;
}
MTDecimal MTDecimal::AsymmetricArithmeticRound(int aPlaces) 
{
  AsymmetricArithmeticRoundFunction rnd;
  *this = rnd.round(*this, aPlaces);
  return *this;
}
MTDecimal MTDecimal::BankersRound(int aPlaces) 
{
  BankersRoundFunction rnd;
  *this = rnd.round(*this, aPlaces);
  return *this;
}
