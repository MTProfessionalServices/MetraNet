/**************************************************************************
 * @doc MTVARIANTSESSIONENUMBASE
 *
 * Copyright 1998-2004 by MetraTech Corporation
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
 * Created by:	Boris Boruchovich
 *				Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTVARIANTSESSIONENUMBASE_H_
#define __MTVARIANTSESSIONENUMBASE_H_

//----- Mandatory includes
#include <sharedsess.h>

#if defined(SESSION_SERVER_BASE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

//----- Forward declaration
class CMTSessionBase;
class CMTSessionServerBase;

//----- CMTVariantSessionEnumBase declaration.
class CMTVariantSessionEnumBase
{
	public:
		DllExport CMTVariantSessionEnumBase();
		DllExport ~CMTVariantSessionEnumBase();

	// IMTVariantSessionEnum
	public:
		//----- Methods used for iteration.
		DllExport bool First(long& lPos, CMTSessionBase** pSessionBase = NULL);
		DllExport bool Next(long& lPos, CMTSessionBase** pSessionBase = NULL);
		DllExport CMTSessionBase* GetAt(long lPos);

		//----- Set shared memory stuff.
		DllExport void SetSharedInfo(MappedViewHandle * apHandle,
                                 SharedSessionHeader * apHeader, SharedSet * apSet);

		DllExport void SetServer(CMTSessionServerBase * apServer);

	private:

		//----- Do not allow Copy constructor
		CMTVariantSessionEnumBase(const CMTVariantSessionEnumBase& other)
        { /* Do nothing here */ }

		//----- Do not allow Assignment operator.
		void operator=(const CMTSessionBase& rSrc)
		{ /* Do nothing here */ }

	private: // DATA

		// session/set server
		CMTSessionServerBase* mServer;

		SharedSet * mpSet;
		MappedViewHandle * mpMappedView;
		SharedSessionHeader * mpHeader;
};

#endif //__MTVARIANTSESSIONENUMBASE_H_

//-- EOF --
