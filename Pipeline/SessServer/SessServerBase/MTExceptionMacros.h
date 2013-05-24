/**************************************************************************
 * @doc MTEXCEPTION
 *
 * Copyright 2004 by MetraTech Corporation
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
 * Created by: Boris Boruchovich 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTEXCEPTIONMACROS_H_
#define __MTEXCEPTIONMACROS_H_

//---------------------------------------------------------
// NOTE: This class could be made generic for the product.
//---------------------------------------------------------

//----- Necessary includes.
#include <string>
#include <exception>
#include <comutil.h>
#include <mtcomerr.h>

//------ try-catch helper macros.
#define MT_BEGIN_TRY_BLOCK() try {

#define MT_END_TRY_BLOCK(iid) }catch(MTException& Err)\
{ return Error(Err.what(), iid, Err); } \
return S_OK;

#define MT_END_TRY_BLOCK_RETVAL(iid, retVal) }catch(MTException& Err)\
{ return Error(Err.what(), iid, Err); }\
catch(_com_error& err){ retVal = NULL; \
return ReturnComError(err); } \
return S_OK;

#endif //__MTEXCEPTIONMACROS_H_

//-- EOF --
