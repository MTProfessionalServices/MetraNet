/**************************************************************************
 * @doc TEST
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 *
 * @index | TEST
 ***************************************************************************/

#ifndef _TEST_H
#define _TEST_H

#define _WIN32_WINNT 0x0400

#include <objbase.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
using namespace MTPipelineLib;


#include <iostream>
#include <conio.h>							// for _getch

class ComInitialize
{
public:
	ComInitialize()
	{ ::CoInitializeEx(NULL, COINIT_MULTITHREADED); }

	~ComInitialize()
	{ ::CoUninitialize(); }

};

#import "MTPhoneCrack.tlb"
//using namespace ACCTRESOLVELib;

#endif /* _TEST_H */
