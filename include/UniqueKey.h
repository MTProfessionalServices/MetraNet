/**************************************************************************
 * @doc MSIXProperties
 * 
 * @module  Encapsulation for UniqueKey
 * 
 * This class encapsulates the insertion or removal of Service Properties
 * from the database. All access to Service Properties should be done 
 * through this class.
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
 * $Header$
 *
 * @index | UniqueKey
 ***************************************************************************/

#ifndef _UNIQUEKEY_H_
#define _UNIQUEKEY_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include "MTUtil.h"
#include "NTLogger.h"
#include "SharedDefs.h"
#include "MSIXProperties.h"
#include <XMLParser.h>
#include <string>

class UniqueKey
{
	public:

		// @cmember Constructor
		UniqueKey();

		// @cmember Destructor
		virtual ~UniqueKey();

		//	Accessors
		const std::wstring& GetName() const { return mName; } 
      void SetName(const wchar_t* name);
      const std::vector<CMSIXProperties *> GetColumnProperties() const 
      { 
         return columnProperties; 
      }
      void AddColumnProperty(CMSIXProperties *property);

	private:

		std::wstring mName;
      std::vector<CMSIXProperties *> columnProperties;

};

#endif // _MSIXPROPERTIES_H_
