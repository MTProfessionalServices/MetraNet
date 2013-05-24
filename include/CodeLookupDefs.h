
/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Raju Matta
 *
 * $Header$
 *
 *	CodeLookupDefs.h
 *	----------------
 *	This file holds constants, typedefs and forward class definitions
 *	specific to the UsageCycle Application
 *
 ***************************************************************************/

#ifndef _CodeLookupDefs_h
#define _CodeLookupDefs_h


// includes

#ifndef ASSERT
// use assert from assert.h unless it's already been defined.
// ASSERT is defined by MFC as well.
#include <assert.h>
#define ASSERT assert

#endif // ASSERT

// forward class declarations

// forward from other libraries

// global constant for ...

// const for database field names
const wchar_t CODE_NAME_STR[] = L"nm_cde";
const wchar_t CODE_ID_STR[] = L"id_cde";
const wchar_t UNIQUE_STR[] = L"uniq";
const wchar_t PIPELINE_ID_STR[] = L"_id_";

const wchar_t ENUM_DATA_ID_STR[] = L"id_enum_data";
const wchar_t ENUM_DATA_NAME_STR[] = L"nm_enum_data";
const char CODE_LOOKUP_CONFIG_PATH[] = "\\Queries\\CodeLookup";


// typedefs

#endif	// _CodeLookupDefs_h

