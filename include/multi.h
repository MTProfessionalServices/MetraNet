/**************************************************************************
 * @doc MULTI
 *
 * @module |
 *
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
 *
 * @index | MULTI
 ***************************************************************************/

#ifndef _MULTI_H
#define _MULTI_H

#include <errobj.h>

class MultiInstanceSetup : public ObjectWithError
{
public:
	// if login is not null, force multi instance setup with that name.
	// otherwise, if the registry says we're multi-instance, use the
	// current user name.
	BOOL SetupMultiInstance(const char * apLogin, const char * apPassword,
													const char * apDomain);
};


#endif /* _MULTI_H */
