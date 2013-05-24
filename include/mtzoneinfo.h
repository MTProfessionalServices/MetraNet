/**************************************************************************
 * @doc MTZONEINFO
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
 * @index | MTZONEINFO
 ***************************************************************************/

#ifndef _MTZONEINFO_H
#define _MTZONEINFO_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

extern struct tm * tzlocaltime(const char * tz, const time_t * timep);
extern void settzdir(const char * dirname);
extern const char * gettzdir();
extern time_t tzmktime(const char * tz, struct tm * const tmp);

#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _MTZONEINFO_H */
