/****************************************************************************
**
**	FILENAME:		UAMiscUtil.ipp
**
**	MODULE:			UAMiscUtil
**
**	CREATED BY:		Steve Hudson (shudson)
**
**	MODIFIED BY:	Raju Matta
**
**	DATE CREATED:	16-Jul-1997
**
**	DESCRIPTION:
**
**	This file contains the inline functions of class UAMiscUtil.
**	For more information, look in the file UAMiscUtil.hpp
**
**	NOTES:
**	
**	None.
**
****************************************************************************/

#ifndef _MTMISCUTIL_IPP_
#define _MTMISCUTIL_IPP_


// ID - identifies the file/version (in the library/executable)

// Inline Methods


/****************************************************************************
**
**	FUNCTION:		template min
**
**	ARGUMENTS:
**					const class T &t1
**						the first value
**					const class T &t2
**						the second value
**
**	RETURN VALUE:	none
**
**	SCOPE:			public
**
**	VIRTUAL:		no
**
**	STATIC:			no
**
**	CONST:			yes
**
**	DESCRIPTION:
**	
**	This function returns the minimum of two values
**
****************************************************************************/

template<class T>
inline
T
min(const T &t1, const T &t2)
{
	return ((t1 > t2) ? t2 : t1);
}


/****************************************************************************
**
**	FUNCTION:		template max
**
**	ARGUMENTS:
**					const class T &t1
**						the first value
**					const class T &t2
**						the second value
**
**	RETURN VALUE:	none
**
**	SCOPE:			public
**
**	VIRTUAL:		no
**
**	STATIC:			no
**
**	CONST:			yes
**
**	DESCRIPTION:
**	
**	This function returns the minimum of two values
**
****************************************************************************/

template<class T>
inline
T
max(const T &t1, const T &t2)
{
	return ((t1 > t2) ? t1 : t2);
}



#endif	// _MTMISCUTIL_IPP_

