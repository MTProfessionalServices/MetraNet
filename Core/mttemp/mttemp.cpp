/**************************************************************************
 * @doc MTTEMP
 *
 * Copyright 1999 by MetraTech Corporation
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
#include <mttemp.h>

#include <stdlib.h>

TemporaryFile::~TemporaryFile()
{
	if (NameGenerated())
	{
		(void) remove(mFileName.c_str());
		// (0 means success)
	}
}

const std::string & TemporaryFile::GenerateName()
{
	char * name = _tempnam(NULL, "mttemp");
	if (name == NULL)
	{
		mFileName = "";
		return mFileName;								// can't create a name?
	}

	// save the name so it can be deleted
	mFileName = name;

	free(name);

	return mFileName;
}

FILE * TemporaryFile::Open(const char * apOpenFlags)
{
	if (!NameGenerated())
		GenerateName();

	ASSERT(NameGenerated());

	return fopen(mFileName.c_str(), apOpenFlags);
}
