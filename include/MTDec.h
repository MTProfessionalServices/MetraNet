/**************************************************************************
 * @doc MTDEC
 *
 * @module |
 *
 *
 * Copyright 2000 by MetraTech Corporation
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
 *
 * @index | MTDEC
 ***************************************************************************/

#ifndef _MTDEC_H
#define _MTDEC_H

#include <string>

#include <comdef.h>
#include <SharedDefs.h>

class MTDecimalVal;
class MTDecimalValue;  // defined in mtsdk.h

class MTDecimal
{
public:
	MTDecimal();
	MTDecimal(DECIMAL aDec);
	MTDecimal(VARIANT aVar, BOOL aAllowConversion = FALSE);
	MTDecimal(const MTDecimal & arDec);
	MTDecimal(const MTDecimalVal & arDecValue);
	MTDecimal(const MTDecimalValue & arDecValue);  // defined in sdksupport.cpp
	MTDecimal(long long aUnits, long long aFrac);
	MTDecimal(long long aUnits);
	MTDecimal(long aUnits);
	MTDecimal(const std::string& arInputStr);
	MTDecimal(const char* apInputStr);



	MTDecimal operator / (const MTDecimal & arDec) const;
	MTDecimal operator + (const MTDecimal & arDec) const;
	MTDecimal operator * (const MTDecimal & arDec) const;
	MTDecimal operator - (const MTDecimal & arDec) const;

	MTDecimal operator - ();
	
	BOOL operator < (const MTDecimal & arDec) const;
	BOOL operator <= (const MTDecimal & arDec) const;
	BOOL operator > (const MTDecimal & arDec) const;
	BOOL operator >= (const MTDecimal & arDec) const;
	BOOL operator == (const MTDecimal & arDec) const;
	BOOL operator != (const MTDecimal & arDec) const;

	// Note that type double only supports 15 significant digits!
	BOOL operator < (double aDouble) const;
	BOOL operator <= (double aDouble) const;
	BOOL operator > (double aDouble) const;
	BOOL operator >= (double aDouble) const;
	BOOL operator == (double aDouble) const;
	BOOL operator != (double aDouble) const;

	MTDecimal & operator += (const MTDecimal & arDec);
	MTDecimal & operator -= (const MTDecimal & arDec);
	MTDecimal & operator *= (const MTDecimal & arDec);
	MTDecimal & operator /= (const MTDecimal & arDec);

	MTDecimal & operator = (const MTDecimal & arDec);
	MTDecimal & operator = (const DECIMAL & arDec);
	MTDecimal & operator = (const VARIANT & arVar);
	MTDecimal & operator = (long long aUnits);

    // aFrac must be in units of 10^-10.
	// A negative number is indicated by passing a negative value for aUnits.
	// Type long (4 bytes) can only represent 9 decimal digits fully,
	// so we need to use long long.
	void SetValue(long long aUnits, long long aFrac);
	
	void SetValue(long long aUnits);
	BOOL SetValue(const std::string& arInputStr);
	BOOL SetValue(const char * apInputStr) {
		return SetValue(std::string(apInputStr));
	}
	
	std::string MTDecimal::Format(int aNumFixed = METRANET_SCALE_MAX, 
	    int aUseCommas = FALSE, int aUseParens = FALSE, int aShowLeading = TRUE) const;

	operator DECIMAL &()
	{ return mValue; }

	DECIMAL * operator &()
	{ return &mValue; }

	const DECIMAL * operator &() const
	{ return &mValue; }


	operator const DECIMAL &() const
	{ return mValue; }

	operator _variant_t () const;

	int Compare(const MTDecimal & arDec) const;
	
	// Note that type double only supports 15 significant digits!
	int Compare(double aDouble) const;

	MTDecimal Abs() const;
	MTDecimal FractionalValue();
	MTDecimal IntegerValue();
  MTDecimal FixValue();
	MTDecimal Round(int aPlaces);
	MTDecimal Floor();
  // For the definition of the following see Knowledge Base Article KB196652
  // HOWTO: Implement Custom Rounding Procedures
  // Note that unlike the Round function above, these all accept
  // negative aPlaces arguments.
	MTDecimal SymmetricArithmeticRound(int aPlaces);
	MTDecimal AsymmetricArithmeticRound(int aPlaces);
	MTDecimal BankersRound(int aPlaces);

	static MTDecimal Min(MTDecimal & arDec1, MTDecimal & arDec2);
	static MTDecimal Max(MTDecimal & arDec1, MTDecimal & arDec2);

	static const MTDecimal ZERO;
	
private:

    // A decimal value is represented as a 96-bit unsigned integer
	// that is scaled by a power of 10.
	DECIMAL mValue;
	
};


#endif /* _MTDEC_H */
