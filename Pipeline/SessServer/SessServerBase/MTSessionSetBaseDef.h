/**************************************************************************
 * @doc MTSESSIONSETBASE
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by:  Boris Boruchovich
 *				Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTSESSIONSETBASE_H_
#define __MTSESSIONSETBASE_H_

#include "resource.h"       // main symbols
#include <string>
#include <sharedsess.h>

#if defined(SESSION_SERVER_BASE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

//----- Forward declarations
class CMTSessionServerBase;
class CMTVariantSessionEnumBase;

//----- CMTSessionSetBase class declaration.
class CMTSessionSetBase
{
	public:
		DllExport CMTSessionSetBase();
		DllExport CMTSessionSetBase(long lSetHandle);
		DllExport ~CMTSessionSetBase();

		//----- 
		DllExport void SetServer(CMTSessionServerBase* apServer);
		DllExport void SetSharedInfo(MappedViewHandle* apHandle,
                                 SharedSessionHeader * apHeader,
                                 SharedSet * apSet);

	public:

		DllExport CMTVariantSessionEnumBase* get__NewEnum();
		DllExport long get_Count();

		DllExport void AddSession(long aSessionId, long aServiceId);
		DllExport long get_ID();

		// NOTE: use this method with caution
		DllExport long IncreaseSharedRefCount();

		// NOTE: use this method with caution
		DllExport long DecreaseSharedRefCount();

		DllExport const unsigned char* get_UID(/*[out]*/ unsigned char uid[]);
		DllExport void SetUID(unsigned char uid[]);

		DllExport std::string get_UIDAsString();

	private:

		//----- Do not Alloaw Copy constructor
		CMTSessionSetBase(const CMTSessionSetBase& other)
        { /* Do nothing here */	}

		//----- Do not Allow Assignment operator.
		void operator=(const CMTSessionSetBase& rSrc)
        { /* Do nothing here */	}

	private: // DATA
		SharedSet * mpSet;

		MappedViewHandle * mpMappedView;
		SharedSessionHeader * mpHeader;

		//----- Session server
		CMTSessionServerBase* mServer;
};

#endif //__MTSESSIONSET_H_

//-- EOF --
