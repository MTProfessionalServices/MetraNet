/**************************************************************************
 * @doc SKELETONLIB
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
 * @index | SKELETONLIB
 ***************************************************************************/

#ifndef _SKELETONLIB_H
#define _SKELETONLIB_H


HRESULT WINAPI RegisterPlugInClassHelper(HINSTANCE hinst, const CLSID& clsid,
																				 LPCTSTR lpszProgID,
																				 LPCTSTR lpszVerIndProgID, LPCTSTR lpszModel);



#endif /* _SKELETONLIB_H */
