/**************************************************************************
 * FORMATDBVALUE
 *
 * Copyright 1997-2001 by MetraTech Corp.
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

#include <metra.h>

#include <formatdbvalue.h>

#include <DBMiscUtils.h>
#include <MTUtil.h>
#include <MTDec.h>
#include <tchar.h>

#include <string>

//
// TODO: times are not supported here!
//
BOOL FormatValueForDB(const _variant_t & aData, BOOL aIsOracle,	std::wstring & arBuffer)
{
	const _variant_t & Data = aData;
	std::wstring wstrTemp;
  _TCHAR tstr[255];

	switch (Data.vt)
  {
	  //handles non-required properties without default values
    case VT_NULL:
	  case VT_EMPTY:
		  arBuffer = L"NULL" ;
		  break;
	  case VT_I2:
		  _stprintf(tstr, _T("%hd"),(short)Data);
		  arBuffer = tstr;
		  break;
	  case VT_I4:
		  _stprintf(tstr, _T("%d"),(long)Data);
		  arBuffer = tstr;
		  break;
	  case VT_I8:
		  _stprintf(tstr, _T("%d"),(__int64)Data);
		  arBuffer = tstr;
		  break;
	  case VT_R4:
		  _stprintf(tstr, _T("%.16e"),(double)Data);
		  arBuffer = tstr;
		  break;
	  case VT_R8:
		  _stprintf(tstr, _T("%.16e"), (double)Data);
		  arBuffer = tstr ;
		  break;
	  case VT_DECIMAL:
	  {
		  MTDecimal decVal((DECIMAL)(Data));
		  //_stprintf(tstr, _T("%.16e"),V_R8(&Data));
		  std::string ascVal = decVal.Format();
		  ASCIIToWide(arBuffer, ascVal.c_str(), ascVal.length());
		  break;
	  }
	  case VT_LPSTR:
		  arBuffer = L"'" ;
		  wstrTemp = V_BSTR (&Data) ;
		  if (aIsOracle && wstrTemp.length() == 0)
		  {
			  wstrTemp = L" " ;
		  }
		  arBuffer += ValidateString (wstrTemp) ;
		  arBuffer += L"'" ;
		  break;
	  case VT_BSTR:
		  if (aIsOracle)
			  arBuffer = L"'";
		  else
			  arBuffer = L"N'";
		  wstrTemp = V_BSTR (&Data);
		  if (aIsOracle && wstrTemp.length() == 0)
		  {
			  wstrTemp = L" ";
		  }
		  arBuffer += ValidateString (wstrTemp);
		  arBuffer += L"'";
		  break ;
	  case VT_DATE:
		  if (Data.vt == VT_DATE)
		  {
        DATE tdate = Data.date;
			  if (tdate == 0)
			  {
				  arBuffer = L"NULL";
			  }
			  else
			  {
				  SYSTEMTIME sysTime;
				  if (FALSE == ::VariantTimeToSystemTime(tdate, &sysTime))
					  return FALSE;

				  // NOTE: use the ODBC escape sequence to work with Oracle and SQL Server
				  // {ts 'yyyy-mm-dd hh:mm:ss'}
				  swprintf(tstr, L"{ts \'%.4d-%.2d-%.2d %.2d:%.2d:%.2d\'}", sysTime.wYear, sysTime.wMonth, sysTime.wDay, sysTime.wHour, sysTime.wMinute, sysTime.wSecond);
				  arBuffer = tstr;
			  }
		  }
		  else
		  {
			  // if we are writing to an Oracle database ... 
			  if (aIsOracle)
			  {
				  arBuffer = L"TO_DATE('" ;
				  wstrTemp = V_BSTR (&Data) ;
				  arBuffer += ValidateString (wstrTemp) ;
				  arBuffer += L"', 'YYYY-MM-DD HH24:MI:SS')" ;
			  }
			  else
			  {
				  arBuffer = L"'" ;
				  wstrTemp = V_BSTR (&Data) ;
				  arBuffer += ValidateString (wstrTemp) ;
				  arBuffer += L"'" ;
			  }
		  }
		  break ;
	  case VT_BOOL:
		  arBuffer = (Data.boolVal == VARIANT_TRUE) ? DB_BOOLEAN_TRUE : DB_BOOLEAN_FALSE;
		  break ;
	  default:
		  ASSERT(0);
		  return FALSE;
	}
	return TRUE;
}


static char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6', '7',
													 '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

std::string ConvertBinaryUIDToHexLiteral(const unsigned char * uid, BOOL aIsOracle)
{
    char chars[(16 * 2) +1];
    for (int i =0; i < 16; i++)
    {
      int b = uid[i];
      chars[i * 2] = hexDigits[b >> 4];
      chars[i*2+1] =  hexDigits[b & 0xF];
    }
    chars[32] = '\0';
    if (! aIsOracle)
	{
		std::string hex = "0x";
		return hex + chars;
	}
	else
	{
		std::string apostrophe = "'";
		return apostrophe + chars + apostrophe;
	}
}    

std::string UseHexToRawSuffix(BOOL aIsOracle)
{
	std::string hexToRawString = ")";

	if(aIsOracle)
	{
		return hexToRawString;
	}

	return "";
}
std::string UseHexToRawPrefix(BOOL aIsOracle)
{
	std::string hexToRawString = "hextoraw(";

	if(aIsOracle)
	{
		return hexToRawString;
	}

	return "";
} 
