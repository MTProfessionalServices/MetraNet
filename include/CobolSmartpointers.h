#ifndef __COBOLSMARTPOINTERS_H__
#define __COBOLSMARTPOINTERS_H__

//////////////////////////////////////////////////////////////////////////
//
// The file contains class definitions for template classes that abstract
// Cobol data types.  Cobol datatypes are defined as a "Picture clause"
// and are all byte oriented.  The most common data types are Decimal, fixed point
// fractional, and character.  Both decimal and fixed point fractional can
// be signed or unsigned.
//
// It is important to understand that Decimal fields in COBOL are stored
// as characters.  For instance, PIC 9(2) is a 2 field wide number.  Possible
// values are 0 - 99.  However, the storage allocated for this field is
// 2 bytes (just like a character string without the NULL terminator).  When 
// communicating with a COBOL program, all information must be passed as the
// ASCII equivilent.  For character strings, this is quite easy.  For numbers, this
// is a bit more challenging.  The smart COBOL classes below simplify this problem.
//
// A couple of examples:
//
// COBOL type:      Type meaning                        SmartCobol type   
//
// PIC 9(2)         2 charwide decimal number           SmartCobolInt<2>
// PIC X(4)         4 char wide string (no termination) SmartCobolChar<4>
// PIC S9(6)V9(5)   Signed fractional number with
//                  6 fields of precision to the left
//                  of the decimal point and 5 to the
//                  right                               SmartCobolDouble<6,5>
// PIC S9(5)        Signed 5 charwide decimal           SmartCobolInt<5>
// PIC S9(8)V99     Signed fractional number with
//                  8 digits of precision to the left
//                  of the decimal point and 2 to the
//                  right                               SmartCobolDouble<8,2>
//
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
//class SmartCobol
//
// This is the abstract base class for all SmartCobol classes.
//
// T is the C++ type
// V is the derived class
//////////////////////////////////////////////////////////////////////////

#ifndef MAX
#define MAX __max
#endif

#define FILLER_CHAR '0'
#include <MTDec.h>
#include <MTUtil.h>

#pragma warning(disable: 4800)


template <class T, class V> class SmartCobol {
  public:

    SmartCobol() {}
    SmartCobol(T apItem) : mItem(apItem) {}
    virtual void writeout(char* pbuff) = 0;
    virtual V& operator=(T p) = 0;
    virtual V& operator=(char* p) = 0;
    virtual bool operator==(V& compare) = 0;
    virtual bool operator!=(V& compare)
    {
      return !operator==(compare);
    }
    virtual bool operator==(const char* compare) = 0;
    virtual bool operator!=(const char* compare)
    {
      return !operator==(compare);
    }

    virtual operator T() = 0;

    T& GetValue() 
		{ 
			return mItem;
		}

  protected:
    T mItem;
};


//////////////////////////////////////////////////////////////////////////
//SmartCobolChar
//////////////////////////////////////////////////////////////////////////

template <int length>
class SmartCobolChar : public SmartCobol<const char*,SmartCobolChar> {
public:
  SmartCobolChar() : SmartCobol<const char*,SmartCobolChar>(NULL) {}
  SmartCobolChar(const char* p) { operator=(p); }

  SmartCobolChar<length>& operator=(const char* p) 
  {
    mItem = p;
    return *this;
  }
  
  operator const char*() {
    memset(pBuff,0,length+1);
    strncpy(pBuff,mItem,length);
    char* pTemp = pBuff;
    unsigned int templen =0;
    while(*pTemp != FILLER_CHAR && *pTemp != ' ' && *pTemp != '\0' && templen++ <= length)
      pTemp++;

    pBuff[templen] = '\0';
    return pBuff;
  }
  
  SmartCobolChar<length>& operator=(char* p)
  {
    mItem = p;
    return *this;
  }

  bool operator==(SmartCobolChar<length>& compare)
  {
    return strncmp(mItem,compare.mItem,length) == 0;
  }

  bool operator==(const char* compare)
  {
    ASSERT(compare);
    return strncmp(mItem,compare,length) == 0;
  }


  virtual void writeout(char* pInBuffer) 
  {
    ASSERT(pInBuffer);
    if(mItem != NULL) {
      const char* pPtr = mItem;
      unsigned int Item_len = strlen(pPtr);
      for(unsigned int i=0;i<length && i<Item_len;i++) {
        *pInBuffer++ = *const_cast<char*>(pPtr);
        pPtr++;
      }
    }
  }

  void ToUpperCase() {
    char* pPtr = const_cast<char*>(mItem);
    for(unsigned int i=0;i<length;i++) {
      *pPtr = toupper(*pPtr);
      pPtr++;
    }
  }

protected:
  // data
  char pBuff[length+1];

};

//////////////////////////////////////////////////////////////////////////
//class SmartCobolInt 
//////////////////////////////////////////////////////////////////////////

template <int length>
class SmartCobolInt : public SmartCobol<int,SmartCobolInt> {

public:
  SmartCobolInt() : SmartCobol<int,SmartCobolInt>(0) {}
  SmartCobolInt(char* p) { operator=(p); }


  SmartCobolInt<length>& operator=(int p) 
  {
    mItem = p;
    ASSERT(mItem >=0 && mItem <= 0xffffffff);
    return *this;
  }

  operator int() { return mItem; }

  SmartCobolInt<length>& operator=(char* pbuff)
  {
    ASSERT(pbuff);
    char ShortBuff[length+1];
    strncpy(ShortBuff,pbuff,length);
		ShortBuff[length] = '\0';
    mItem = atoi(ShortBuff);
    return *this;
  }

  bool operator==(SmartCobolInt<length>& compare)
  {
    return mItem == compare.mItem;
  }

  bool operator==(const char* compare)
  {
    ASSERT(compare);
    return atoi(compare) == mItem;
  }

  virtual void writeout(char* pbuff) 
  {
    ASSERT(pbuff);

    char buff[length + 1];
    // step 1: get the string
    itoa(mItem,buff,10);

    unsigned int  buff_len = strlen(buff);
    // diff could be negative
    int diff = length - buff_len;
    diff = MAX(diff,0);

    // step 2: pad the buffer with 0's
    for(int i=0;i<diff;i++)
      *pbuff++ = FILLER_CHAR;

    // copy the buffer
    for(unsigned int j=0;i<length;i++,j++) {
      *pbuff++ = buff[j];
    }
  }
};

//////////////////////////////////////////////////////////////////////////
// template routine for converting cobol strings
//////////////////////////////////////////////////////////////////////////
const int diffbetween_p_and_0 = 0x40;

template<int unused>
void ConvertString(int wholedigits,int fractionaldigits,const char* pSrc,char* pWholeStr,char* pFractionStr,bool* bNegative)
{
	// negative numbers in COBOL have a 'p' in the least significant digit to represent
	// a 0, q a 1, r a 2, etc
	*bNegative = pSrc[wholedigits + fractionaldigits -1] >= 'p' && 
		pSrc[wholedigits + fractionaldigits -1] <= 'y';

	int aTempWhole = wholedigits;

  if(wholedigits > 0) {
    strncpy(pWholeStr,pSrc,wholedigits);
    pWholeStr[wholedigits] = '\0';
   }

  strncpy(pFractionStr,pSrc+wholedigits,fractionaldigits);
  pFractionStr[fractionaldigits] = '\0';

	if(*bNegative) {
		// p is the starting point of the negative
		// 40 is the difference between 'p' and '0'

		pFractionStr[fractionaldigits -1] -= diffbetween_p_and_0;
	}

}

template<int unused>
void WriteComponentNumberToBuff(int wholedigits,int fractionaldigits,char* pDestBuff,const char* pWholeStr,const char* pFractionStr,bool bNegative)
{
    ASSERT(pDestBuff && pWholeStr && pFractionStr);

    unsigned int WholeBufLen = strlen(pWholeStr);
		
		// write out padding
    int padlen = wholedigits - WholeBufLen;
    padlen = MAX(0,padlen);
    for(int i=0;i<padlen;i++)
      *pDestBuff++ = '0';

    for(unsigned int j=0;j<WholeBufLen;j++)
       *pDestBuff++ = *pWholeStr++;

	
    for(int k=0;k<fractionaldigits;k++)
      *pDestBuff++ = *pFractionStr++;

		if(bNegative) {
			// similar top the operator= method, if the number is negative,
			// make the least significant number a lower case letter where p=0,q=1,
			// r =2, etc.
			*--pDestBuff += diffbetween_p_and_0;
		}
}


//////////////////////////////////////////////////////////////////////////
//class SmartCobolDouble
//////////////////////////////////////////////////////////////////////////


template <int wholedigits,int fractionaldigits>
class SmartCobolDouble : public SmartCobol<double,SmartCobolDouble> {
public:

  SmartCobolDouble() : SmartCobol<double,SmartCobolDouble>(0), mWhole(0), mFraction(0) {}

  SmartCobolDouble<wholedigits,fractionaldigits>& operator=(double aItem) 
  {
		if(aItem < 0) {
			mWhole = ceil(aItem);
		}
		else {
			mWhole = floor(aItem);
		}
			mFraction = aItem - mWhole;
    
    ASSERT(mWhole <= (pow(10,wholedigits)-1));
    return *this;
  }

  operator double() { return mItem; }

  SmartCobolDouble<wholedigits,fractionaldigits>& operator=(char* pText)
  {
    ASSERT(pText);

		char WholeBuf[wholedigits+1];
		char FractionBuf[fractionaldigits+1];
		bool bNegative;

		memset(WholeBuf,0,wholedigits+1);
		memset(FractionBuf,0,fractionaldigits+1);

		// step 1: convert the string to whole and fractional parts
		ConvertString<0>(wholedigits,fractionaldigits,pText,WholeBuf,FractionBuf,&bNegative);

		// step 2: convert the whole part to mItem
		if(wholedigits > 0) {
			mItem = atof(WholeBuf);
		}
		else {
			mItem = 0;
		}
		
		// step 3: add in fractional component
    mItem += (atof(FractionBuf) /  pow(10,fractionaldigits));

		// step 4: if negative set the amount to its inverse
		if(bNegative) {
		mItem = -mItem;
		}
    return *this;
  }

  bool operator==(SmartCobolDouble<wholedigits,fractionaldigits>& compare)
  {
    return mItem == compare.mItem;
  }

  bool operator==(const char* compare)
  {
    ASSERT(compare);
    return atof(compare) == mItem;
  }


	// negative ammounts are represented in COBOL by having
	// a 'p' at the end of the buffer.  This means that the least
	// significant digit of the fractional data portion is DROPPED
	// if it is a negative number

  virtual void writeout(char* pbuff) 
  {
    ASSERT(pbuff);
    int dec,sign;
		bool bNegative=false;


		if(mWhole < 0 || mFraction < 0) {
			bNegative = true;
		}

		// must use strings because _fcvt uses a static buffer
		string WholeBuffer = _fcvt(mWhole,0,&dec,&sign);
		string FractionBuffer = _fcvt(mFraction,fractionaldigits + 1,&dec,&sign);

		WriteComponentNumberToBuff<0>(wholedigits,fractionaldigits,pbuff,
			WholeBuffer.c_str(),
			FractionBuffer.c_str(),
			bNegative);

  }
protected:
  double mWhole;
  double mFraction;
};

//////////////////////////////////////////////////////////////////////////
// SmartCobolDecimal
//////////////////////////////////////////////////////////////////////////

template <int wholedigits,int fractionaldigits>
class SmartCobolDecimal : public SmartCobol<MTDecimal,SmartCobolDecimal> 
{
public:

	void writeout(char* pbuff)
	{	
		// step 1: decompose into whole and fractional parts
		MTDecimal aWholeValue = mItem.IntegerValue();
		MTDecimal aFractionValue = mItem.FractionalValue();

		string szWholeValue = aWholeValue.Format();
		string szFractionValue = aFractionValue.Format();

		// strip off the decimal .0000 from the whole value
		string::iterator aWholeiter = szWholeValue.begin();
		while(aWholeiter != szWholeValue.end() && *aWholeiter != '.') {
			aWholeiter++;
		}
		szWholeValue.erase(aWholeiter,szWholeValue.end());
		szFractionValue.erase(0,2);

		bool bNegative = mItem < 0 ? true : false;

		// step 2: write to buffer
		WriteComponentNumberToBuff<0>(wholedigits,fractionaldigits,pbuff,
			szWholeValue.c_str(),
			szFractionValue.c_str(),
			bNegative);

	}

	SmartCobolDecimal<wholedigits, fractionaldigits>& operator=(MTDecimal aInValue)
	{
		mItem = aInValue;
		return *this;
	}

	SmartCobolDecimal<wholedigits, fractionaldigits>& operator=(char* aString)
	{
		 ASSERT(aString);

		char WholeBuf[wholedigits+1];
		char FractionBuf[fractionaldigits+1];
		bool bNegative;

		memset(WholeBuf,0,wholedigits+1);
		memset(FractionBuf,0,fractionaldigits+1);

		// step 1: convert the string to whole and fractional parts
		ConvertString<0>(wholedigits,fractionaldigits,aString,WholeBuf,FractionBuf,&bNegative);

		// step 2: convert to value to normalized string
		string aFullNumber = WholeBuf;
		aFullNumber += ".";
		aFullNumber += FractionBuf;

		// step 3: convert to wide string
		wstring aTempWideStr;
		ASCIIToWide(aTempWideStr,aFullNumber);

		// step 4: run conversion routine.  If this fails, we throw the HRESULT (for lack of something better to do)
		HRESULT hr = MTDecimal::ValueFromString(aTempWideStr,mItem);
		if(FAILED(hr)) {
			throw hr;
		}

		return *this;
	}

	bool operator==(SmartCobolDecimal<wholedigits,fractionaldigits>& compare)
	{
		return compare.mItem == mItem;

	}

	bool operator==(const char* compare)
	{
		ASSERT(compare);
		wstring aTempWideStr;
		MTDecimal aTemp;

		// convert to wide string
		ASCIIToWide(aTempWideStr,compare);
		if(FAILED(MTDecimal::ValueFromString(aTempWideStr,aTemp))) {
			return false;
		}
		else {
			return aTemp == mItem;
		}
	}

	operator MTDecimal()
	{
		return mItem;
	}
};


#pragma warning(default: 4800)

//////////////////////////////////////////////////////////////////////////
// typedefs for backwards compatibility

#endif //__COBOLSMARTPOINTERS_H__
