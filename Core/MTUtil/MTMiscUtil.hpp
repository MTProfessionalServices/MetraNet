/****************************************************************************
**
**	Copyright 1997, Cambridge Technology Partners, Inc. & JPMorgan
**	
**	FILENAME:		UAMiscUtil.hpp
**
**	MODULE:			uacommon
**
**	CREATED BY:		Dimitri J. Panagiotou (dpana)
**
**	DATE CREATED:	24-Apr-1997
**
****************************************************************************/

/****************************************************************************
**
**	DESCRIPTION:
**
**	This class only has STATIC functions.  Do NOT instantiate, it 
**	will not work.
**
**	Misc Utility functions
**  - utilities to get and set environment variables
** 	- utilities to convert RWCStrings <--> ints/longs/doubles
**	- static wrappers around hash functions, needed by Rogue Dictionaries etc.
**
**	NOTES:
**	
**	The putEnv method should be used with care.  Most of the time, you 
**  don't want to change env. variables.
**	Some functions throw exceptions.  Look at the individual function specs.
**
**	Some of these functions and ideas were "stolen" and modified from 
**	the CTP AT&T project (dimitri).
**
****************************************************************************/

/****************************************************************************
**
**	LOG (automatically updated by CVS):
**
**	$Log: UAMiscUtil.hpp,v $
**	Revision 1.5  1997/07/16 18:37:51  shudson
**	added templatized min and max functions
**
**	Revision 1.4  1997/07/14 21:41:38  dpana
**	Fixed makeUniqueFilename() so that it uses tempnam().
**	Not perfect, but it will work.
**
**	Revision 1.3  1997/06/03 21:57:06  dpana
**	Added getBaseName() and getDirName().
**
**	Revision 1.2  1997/05/01 19:55:24  dpana
**	Cleaned up, fixed exceptions, eliminated some temporary variables.
**	Changed the return type of putEnv()
**
**	Revision 1.1  1997/04/24 13:40:49  dpana
**	Added UAMiscUtil.
**	Still needs work:
**		- The correct exceptions need to be thrown
**		- The unique filename doesn't work (no UUID)
**		- Formatting is not completely correct.
**
****************************************************************************/


#ifndef UAMISCUTIL_HPP
#define UAMISCUTIL_HPP

// ID for the preprocessor
#if defined __SUNPRO_CC
#pragma ident \
"@(#) $Id: UAMiscUtil.hpp,v 1.5 1997/07/16 18:37:51 shudson Exp $  (c) Cambridge Technology Partners, Inc. & JPMorgan"
#endif



// includes

#include <stdio.h>
#include <rw/cstring.h>

// class declaration


class UAMiscUtil
{
	public:

		//
		// Deal with environment variables
		//
		// The variable name should never be null.
		//

		// Note: If the variable exists but its value is null, 
		// getEnv() will return "", NOT the default value.
		// This is designed in order to accomodate variables whose 
		// mere setting is enough.
		static const RWCString 
		getEnv(const RWCString& envVariableName, 
			   const RWCString& defaultValue = "");

		// Throw UAExRunTime if putenv fails.
		static const RWCString
		putEnv(const RWCString& envVariableName,
			   const RWCString& value);

		//
		// Conversion routines
		//

		// Throw UAExInvalidArgument if could not convert to specified type
		// Throw UAExRange if resulting number is out of range
		static const int stringToInt(const char* from);
		static const long stringToLong(const char* from);
		static const unsigned int stringToUInt(const char* from);
		static const unsigned long stringToULong(const char* from);
		static const double stringToDouble(const char* from);
		

		// Throw UAExInvalidArgument if conversion cannot be performed
		static const RWCString intToString(const int from);
		static const RWCString uintToString(const unsigned int from);
		static const RWCString longToString(const long from);
		static const RWCString ulongToString(const unsigned long from);
		static const RWCString doubleToString(const double from);


		//
		// Hash functions (required by Rogue classes)
		//
		static unsigned hashFunction(const RWCString& s);


		//
		// Unique filenames
		//

		// This throws exceptions thrown by Uuid
		// The prefix should never be null
		static const RWCString 
		makeUniqueFilename(const RWCString& path = "/tmp",
						   const RWCString& prefix = "tmp.",
						   const RWCString& suffix = "");

		// DirName, BaseName
		static const RWCString getDirName(const RWCString& filename);
		static const RWCString getBaseName(const RWCString& filename);


	protected:


	private:

		//
		// WARNING: The following member functions are not defined
		//

		// Constructor
		UAMiscUtil();

		// Destructor
		virtual ~UAMiscUtil();

		// Copy constructor
		UAMiscUtil(const UAMiscUtil& d);

		// Assignment operator
		const UAMiscUtil& operator=(const UAMiscUtil& d);

};


#include "UAMiscUtil.ipp"

#endif

