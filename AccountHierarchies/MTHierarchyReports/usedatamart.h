/**************************************************************************
 * @doc USEDATAMART
 *
 * @module |
 *
 *
 * Copyright 2003 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | USEDATAMART
 ***************************************************************************/

#ifndef _USEDATAMART_H
#define _USEDATAMART_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

// global function used by the slice objects to decide whether or not
// to use the data mart
bool UseDataMart();

#endif /* _USEDATAMART_H */
