/**************************************************************************
 * @doc
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 **************************************************************************/
#ifndef __AUTOCRYPTO_H__
#define __AUTOCRYPTO_H__
#pragma once

#include <mtcryptoapi.h>
#include <MTSingleton.h>

class MTAutoCryptoAPI : public CMTCryptoAPI,
												public MTSingleton<MTAutoCryptoAPI>
{
public:
	MTAutoCryptoAPI() {}
	~MTAutoCryptoAPI() {}
	BOOL Init() { return TRUE; }
};

#endif //__AUTOCRYPTO_H__