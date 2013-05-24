/**************************************************************************
 * @doc ConnectionPooling
 * 
 * @module  utility object to turn connection pooling on
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Jim Culbert
 * $Header$
 *
 * @index | ConnectionPooling
 ***************************************************************************/


#ifndef __MT_CPOOL_H__
#define __MT_CPOOL_H__

#ifndef DllExport
#define DllExport __declspec( dllexport ) 
#endif

bool DllExport EnableConnectionPooling(bool bEnable);

#endif