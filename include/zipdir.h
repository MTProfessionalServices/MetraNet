/**************************************************************************
 * @doc ZIPDIR
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
 * @index | ZIPDIR
 ***************************************************************************/

#ifndef _ZIPDIR_H
#define _ZIPDIR_H

#include <errobj.h>

class ZipUtils : public ObjectWithError
{
public:
	BOOL ZipDirectory(const char * apDirName, const char * apZipFile);
	BOOL UnzipDirectory(const char * apDirName, const char * apZipFile);

	BOOL AddOneFileToZip(const char * apDirName, 
											const char * apZipFile, const char * apFileName);
};

#endif /* _ZIPDIR_H */
