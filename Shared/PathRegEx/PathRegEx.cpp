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

#include "PathRegEx.h"

using namespace std;

CMTPathRegEx::CMTPathRegEx(char* aPattern) : msPath(string()), mbCs(false), Directory(false), Recursive(false)
{
	msPath = msCPath = aPattern;
	Init();
	
}

CMTPathRegEx::~CMTPathRegEx()
{
	//delete msPath;
}


bool operator==(const CMTPathRegEx a, const CMTPathRegEx b)
{
	const char* thisone = a.msPath.c_str();
	const char* thatone = b.msPath.c_str();
	return (a.mbCs | b.mbCs) ? !strcmp(thisone, thatone) : !stricmp(thisone, thatone);
}

/* 
Returns true if file path in that object is impilied by the file path in "this" object.
Logic in here is stolen from Java's FilePermission class implementation (java.io.FilePermission).

Recognized tokens indicating wild cards are: 

'*' - indicates all files in current directory. For example: "/metratech/*" will imply
			"/metratech/engineering", but will not imply "metratech/engineering/core"
'-' - indicates all files in current directory and, recursively, in all directories
			under this directory. For example: "metratech/-" will imply  both "metratech/engineering" and
			"metratech/engineering/core".
'<<ALL FILES>>' - indicates all files (currently not implemented)

*/
bool CMTPathRegEx::Implies(const CMTPathRegEx& that)
{
	//initialize comparison func pointer depending
	// on mbCs setting
	int (*compare)(const char*, const char*) = (mbCs) ? &strcmp : &stricmp;
	string thisone = this->msCPath;
	string thatone = that.msCPath;
	
	//1. test objects for equality; if positive - return true
	if(*this == that) return true;

	if (this->Directory)
	{
		//2. If "this" is recursive, check if
		//"that" starts with this. If it does - return true
		if (this->Recursive)
		{
			return thatone.find(thisone) == 0;
		}
		else
		{
			if(that.Directory)
			{
				//3. if "this" is not recursive, it can never imply recursive
				if (that.Recursive)
					return false;
				else
					return 0 == (*compare)(thisone.c_str(), thatone.c_str());
					
			}
			else
			{
				//"this" is a non-recursive directory (someting like /metratech/*)
				//cut off the token after last '/' occurence on "that" object
				// and compare pointers. This will tell us if that is located in
				//directory that "this" implies
				string::size_type pos = thatone.find_last_of(SEP_TOK);
				if (pos == string::npos)
					return false;
				else
				{
					string subs = thatone.substr(0, pos);
					return (*compare)(thisone.c_str(), subs.c_str()) == 0;
				}
			}

		}
	}
	else
	{
    //if "this" is not a directory, then it does not imply
    //any directories
    if(that.Directory)
      return false;
    else
		  return (*compare)(thisone.c_str(), thatone.c_str()) == 0;
	}
}

void CMTPathRegEx::Init()
{
	int len = msPath.length();
  int upbound = 0;
	char lastchar = msPath[len-1];
	int cut = 0;
	
	if (lastchar == WILD_TOK || lastchar == RECURSIVE_TOK)
	{
		Directory = true;
		if (lastchar == RECURSIVE_TOK){
			meWildCard = RECURSIVE_PATH;
			Recursive = true;
		}
		else
			meWildCard = CURRENT_DIRECTORY_PATH;
		cut++;
		lastchar = msPath[len-2];
		if (lastchar != SEP_TOK)
		{
			//error, encountered something like /foo- instead of /foo/-
			throw new exception("Failed to parse input path");
		}
		cut++;
    upbound = (len-cut==0) ? 1 : len-cut;
		msCPath = msPath.substr(0, upbound);
	}
	else
		meWildCard = SINGLE_FILE_PATH;

}





