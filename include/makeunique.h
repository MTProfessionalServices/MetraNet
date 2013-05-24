/**************************************************************************
 * @doc MAKEUNIQUE
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
 * @index | MAKEUNIQUE
 ***************************************************************************/

#ifndef _MAKEUNIQUE_H
#define _MAKEUNIQUE_H

#include "MTSL_DLL.h"

#include <string>


void MTSL_DLL_EXPORT MakeUnique(std::wstring & arName);
void MTSL_DLL_EXPORT MakeUnique(std::string & arName);
void MTSL_DLL_EXPORT SetUniquePrefix(const char * apUniquePrefix);

#endif /* _MAKEUNIQUE_H */
