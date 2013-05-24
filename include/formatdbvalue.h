/**************************************************************************
 * @doc FORMATDBVALUE
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * @index | FORMATDBVALUE
 ***************************************************************************/

#ifndef _FORMATDBVALUE_H
#define _FORMATDBVALUE_H

#include <comdef.h>
#include <string>
#include <DBConstants.h>

// format a variant into a string that can be used in a database query string
BOOL FormatValueForDB(const _variant_t & aData, BOOL aIsOracle,	std::wstring & arBuffer);

// converts a binary UID to a hex literal
std::string ConvertBinaryUIDToHexLiteral(const unsigned char * uid, BOOL aIsOracle);
std::string UseHexToRawPrefix(BOOL aIsOracle);
std::string UseHexToRawSuffix(BOOL aIsOracle);
#endif /* _FORMATDBVALUE_H */
