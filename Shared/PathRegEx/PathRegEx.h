/**************************************************************************
 * CMTPathRegEx
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTPATHREGEX_H_
#define __MTPATHREGEX_H_

#include <string>


static const char WILD_TOK = '*';
static const char RECURSIVE_TOK = '-';
static const char SEP_TOK = '/';
static const char*  ALL_FILES_TOK = "<<ALL FILES>>";

typedef enum{
	SINGLE_FILE_PATH,
	CURRENT_DIRECTORY_PATH,
	RECURSIVE_PATH
} PathWildCard;



class CMTPathRegEx
{
	public:
		CMTPathRegEx(char* aPattern);
		virtual ~CMTPathRegEx();
		inline void SetCaseSensitive(bool aCs){mbCs = aCs;}
		inline bool GetCaseSensitive() const {return mbCs;}
		inline PathWildCard GetPathWildCard() const {return meWildCard;}
		inline bool IsDirectory() const {return Directory;}
		inline const char* GetCPath() const {return msCPath.c_str();}
		friend bool operator==(const CMTPathRegEx a, const CMTPathRegEx b);
		inline friend bool operator!=(const CMTPathRegEx& a, const CMTPathRegEx& b){return !(a==b);}
		bool Implies(const CMTPathRegEx&);


	private:
		std::string msPath;
		//"clean" path, remove WILD, SEP, RECURSIVE at the end if applies
		std::string msCPath;
		void Init();
		//case sensitive?
		bool mbCs;
		//is it a directory?
		bool Directory;
		//is it a recursive directory?
		bool Recursive;
		//type of a path
		PathWildCard meWildCard;
};



#endif
