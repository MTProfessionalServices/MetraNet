/**************************************************************************
 * @doc MTTEMP
 *
 * @module |
 *
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
 *
 * @index | MTTEMP
 ***************************************************************************/

#ifndef _MTTEMP_H
#define _MTTEMP_H

#include <stdio.h>
#include <string>

class TemporaryFile
{
public:
	// deletes the file from disk on destruction
	virtual ~TemporaryFile();

	// open the file and return a handle to it.
	FILE * Open(const char * apOpenFlags);

	const std::string & GetFileName() const
	{ return mFileName; }

	const std::string & GenerateName();

private:
	BOOL NameGenerated() const
	{ return mFileName.length() > 0; }
private:
	std::string mFileName;
};

#endif /* _MTTEMP_H */
