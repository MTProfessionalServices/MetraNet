/**************************************************************************
 * @doc MULTIINSTANCE
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
 * @index | MULTIINSTANCE
 ***************************************************************************/

#ifndef _MULTIINSTANCE_H
#define _MULTIINSTANCE_H

#include <map>
#include <string>
using std::map;
using std::string;

typedef map<int, string> PortMappings;

// return TRUE if this machine is configured to run multiple instance
// simultaneously
BOOL IsMultiInstance();

// return the mappings between web server port numbers and login names
BOOL ReadPortMappings(PortMappings & arMappings);

// write mappings to the registry
BOOL WritePortMappings(PortMappings & arMappings);

#endif /* _MULTIINSTANCE_H */
