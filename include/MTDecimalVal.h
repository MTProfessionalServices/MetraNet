#ifndef _MTDECIMALVAL_H
#define _MTDECIMALVAL_H

#include <string>

/////////////////////////////////////////////////////////////////////////////////////////
// CLASS		: MTDecimalVal
// DESCRIPTION	: Implementation of MTDecimalValue. Used to store decimal values with fixed precision
//				: (10 fractional points), longer then long. 
// COMMENTS		: This class is used in both Win32 and Unix, so it does not depend on COM.
//				: For decimal values manipulations use MTDecimal
// CREATED		: 
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
class MTDecimalVal
{
public:
	MTDecimalVal() {};
	MTDecimalVal(const MTDecimalVal & arDecimalVal);
	
	MTDecimalVal & operator = (const MTDecimalVal & arDecimalVal);
	
	virtual BOOL SetValue(double doubleVal);
	virtual BOOL SetValue(long longVal);
	virtual BOOL SetValue(const wchar_t * apStr);
	virtual BOOL SetValue(const char * apStr);
	
    // fractionalValPart must be in units of 10^-10.
	// lowFixedValPart contains the 9 least significant digits
	// of the integral part.
	// For a negative number, all the arguments must be negative.
	virtual BOOL SetValue(long hiFixedValPart, long lowFixedValPart, long long fractionalValPart);

	// get value
	virtual BOOL Format(char * buffer, int & bufferSize) const;
	virtual BOOL Format(wchar_t * buffer, int & bufferSize) const;

private:
	std::wstring mValue;
};

#endif /* _MTDECIMALVAL_H */
