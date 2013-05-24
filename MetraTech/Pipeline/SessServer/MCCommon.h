/**************************************************************************
 * @doc MCSESSIONSET
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

#ifndef _MCCOMMON_H
#define _MCCOMMON_H

//----- 
#pragma unmanaged
#include <errobj.h>
#pragma managed

using namespace System;

//----- Define application exceptions that may be thrown by session server framework.
namespace MetraTech
{
	namespace Pipeline
	{
    ref class MTException : public ApplicationException
    {
      public:
        MTException(::MTException& ex)
		{
			std::string s = ex.what();
			ApplicationException(gcnew System::String(s.c_str()));
		}

        ~MTException() {}
    };
  }
};

//----- Macro used to catch unbmanaged exception and re-throw as managed.
#define BEGIN_TRY_UNMANAGED_BLOCK() try{
#define END_TRY_UNMANAGED_BLOCK() } catch(::MTException& ex){throw gcnew MetraTech::Pipeline::MTException(ex); }
                                                             // Rethrow managed exception

#endif //_MCCOMMON_H

//-- EOF --