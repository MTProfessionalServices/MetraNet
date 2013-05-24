/**************************************************************************
 * @doc MAKEUNIQUE
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
 ***************************************************************************/

#include <metra.h>
#include <makeunique.h>

#include <MTUtil.h>

static BOOL gIsInitialized = FALSE;

class Prefixes
{
public:
	Prefixes()
	{ }

	Prefixes(const Prefixes & arPrefixes)
	{
		mPrefix = arPrefixes.mPrefix;
		mPrefixWide = arPrefixes.mPrefixWide;
	}

	std::string mPrefix;
	std::wstring mPrefixWide;
};


static Prefixes * gpDefaultPrefixes = NULL;

void MTSL_DLL_EXPORT MakeUnique(std::wstring & arName)
{
	if (gpDefaultPrefixes)
		arName.insert(0, gpDefaultPrefixes->mPrefixWide);
}

void MTSL_DLL_EXPORT MakeUnique(std::string & arName)
{
	if (gpDefaultPrefixes)
		arName.insert(0, gpDefaultPrefixes->mPrefix);
}

void MTSL_DLL_EXPORT SetUniquePrefix(const char * apUniquePrefix)
{
	if (!gpDefaultPrefixes)
		gpDefaultPrefixes = new Prefixes;


	gpDefaultPrefixes->mPrefix = apUniquePrefix;
	ASCIIToWide(gpDefaultPrefixes->mPrefixWide, gpDefaultPrefixes->mPrefix.c_str(),
							gpDefaultPrefixes->mPrefix.length());
}
