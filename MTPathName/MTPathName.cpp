/**************************************************************************
 * @doc MTPATHNAME
 *
 * Copyright 2000 by MetraTech Corporation
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
 * Created by: Alan Blount
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <MTPathName.h>
#include <string>
#include <MTUtil.h>
#include <stdutils.h>

// All wide, all the time
const wchar_t *posixPathsep = L"/";
const wchar_t *shitePathsep = L"\\";
const wchar_t *bothPathsep = L"/\\";
const wchar_t *dot = L".";
const wchar_t *dotdot = L"..";
const wchar_t *colon = L":";


#ifdef WIN32
#define PATHSEP shitePathsep
#else
#define PATHSEP posixPathsep
#endif

MTPathName::MTPathName() : mPathName()
{
}

MTPathName::MTPathName(const MTPathName &pathName) : mPathName(pathName.mPathName)
{
}

MTPathName::MTPathName(const std::wstring &pathName) : mPathName(pathName)
{
}

//MTPathName::MTPathName(const char *pathName) : mPathName(std::wstring(pathName, ascii))
//{
//}

MTPathName::MTPathName(const unsigned char *pathName) :
  mPathName(std::wstring((const char *)pathName, ascii))
{
}

MTPathName::~MTPathName()
{

}

////
//// Assignment
////

MTPathName &MTPathName::operator =(const MTPathName &pathName)
{
  mPathName=pathName.mPathName;
  return *this;
}

MTPathName &MTPathName::operator =(const std::wstring &pathName)
{
  mPathName=pathName;
  return *this;
}

MTPathName &MTPathName::operator =(const char *pathName)
{
	std::string tmpstr(pathName);
	std::wstring pn;
	ASCIIToWide(pn, tmpstr);
    mPathName=pn;
    return *this;
}

void MTPathName::normalizeCase()
{
  // No effect under POSIX

#ifdef WIN32
	_wcslwr((unsigned short *)mPathName.c_str());
  frontToBack();
#endif
}

//
// This may look slow, but a P300 will process 10,000 iterations over
// "c:/../../hey/./im/a/file/../../teapot/so/there/.." in < 4
// seconds.  So don't sweat it too much.
//
void MTPathName::normalize()
{
  MTPathName prefix, path;

  normalizeSlashes();
  getDrive(prefix);
  getNoDrive(path);

  mPathName = prefix.getString();
  if (path.getLength() == 0) return;

	vector<string> splitPath;
	Tokenize(splitPath, path.GetString);

	vector<string>::iterator it;

	it = splitPath.begin();

  // Removes foo/..
  // Removes /./

  bool absolutePath = path.isAbs();

	for (int count = 0; it != splitPath.end(); count++)
  {
		const string & component = *it;

		if (iter.key() == dotdot)
		{
			if (count > 0)
			{
				// check previous element
				--iter;
				if (iter.key() == dotdot)
				{
					++iter;
				} else {
					iter.remove();
					++iter;
					iter.remove();
				}
			} else {
				if (absolutePath) iter.remove();
			}
		} else if (iter.key() == dot) {
			iter.remove();
		}
  }

				 // Rebuild path string
				 iter.reset();

			 for (count = 0; iter() == TRUE; count++) {
				 if ((count > 0) || absolutePath)
				 {
					 mPathName.append(PATHSEP);
				 }
				 mPathName.append(iter.key());
			 }

}

void MTPathName::append(const MTPathName &pathName)
{
  MTPathName path;

  // Replace if absolute or drive letter different
  char d0, d1;
  d0 = getDriveLetter();
  d1 = pathName.getDriveLetter();

  if (pathName.isAbs())
  {
	mPathName = pathName.mPathName;
	if (d0 && !d1)
	{
	  setDriveLetter(d0); 
	} else if (d1) {
	  setDriveLetter(d1);
	}
  } else {
	pathName.getNoDrive(path);
	mPathName.append(PATHSEP);
	mPathName.append(path.mPathName);
	if (d1) setDriveLetter(d1);
  }
}

void MTPathName::setDriveLetter(char drive)
{
#ifdef WIN32

  if (mPathName.length() < 2 || mPathName[(size_t)1] != *colon)
  {
	mPathName.prepend(colon);
	mPathName.prepend(std::wstring(drive));
  } else {
	mPathName[(size_t)0] = drive;
  }

#endif

  // No effect on POSIX
  return;
}


////
//// Accessors
//// 

bool MTPathName::isAbs() const
{
  MTPathName path;
  getNoDrive(path);
  
  if (path.getString()[(size_t)0] == RWWString(PATHSEP))
  {
	return true;
  }
  return false;
}

bool MTPathName::getDrive(MTPathName &drive) const
{
#ifdef WIN32

  if (mPathName.length() < 2)
	return TRUE;

  if (mPathName[(size_t)1] != *colon)
	return TRUE;

  drive = mPathName(0, 2);

  return TRUE;
#else
  return TRUE;
#endif
}

char MTPathName::getDriveLetter() const
{
#ifdef WIN32

  if (mPathName.length() < 2)
	return (char) 0;

  if (mPathName[(size_t)1] != *colon)
	return 0;

  return (char) mPathName(0, 2)[0];
#else
  return (char) 0;
#endif
}

bool MTPathName::getNoDrive(MTPathName &noDrive) const
{
#ifdef WIN32
  if (mPathName.length() < 2)
  {
	if (mPathName.length() == 1)
	{
	  // One-character filename
	  noDrive = mPathName(0, 1);
	  return TRUE;
	}
	return TRUE;
  }

  if (mPathName[(size_t)1] != *colon)
  {
	noDrive = mPathName;
	return TRUE;
  }

  noDrive = mPathName(2, mPathName.length() - 2);
  return TRUE;

#else
  MTPathName = m_PathName;
  return TRUE;
#endif
}

void MTPathName::getHead(MTPathName &head) const
{
  // Nasty pointer kung-fu.  But fast.
  const wchar_t *p0 = (const wchar_t *)mPathName, *p1;
  p1 = p0 + mPathName.length();
  if (p0 == p1) return;
  
  for ( ; p1 >= p0; p1--) {
	if (*p1 == *PATHSEP) {
	  if (p1 == p0)
	  {
		  head = mPathName(0, 1);
		  return;
	  } else if ((p1 == p0 + 2) && (*(p1 - 1) == *colon)) {
		head = mPathName(0, 3);
		return;
	  }
	  head = mPathName(0, (size_t) (p1 - p0));
	  return;
	}
  }
  // no delimeter found
  head = mPathName;
}

void MTPathName::getTail(MTPathName &tail) const
{
  MTPathName normPath = mPathName;
  normPath.normalize();

  const wchar_t *p0 = (const wchar_t *)normPath.mPathName, *p1;
  p1 = p0 + normPath.mPathName.length();
  if (p0 == p1) return;
  
  for ( ; p1 >= p0; p1--) {
	if ((*p1 == *PATHSEP) || (*p1 == *colon)) {
	  tail = p1 + 1;
	  return;
	}
  }
  tail = (p1 + 1);
}

std::string MTPathName::toAscii() const
{
  return mPathName.toAscii();
}


////
//// Private
////

void MTPathName::frontToBack()
{
	for (int i = mPathName.index(posixPathsep); i != string::npos; i = mPathName.index(posixPathsep, i)) {
	mPathName.replace(i, 1, shitePathsep);
  }

}

void MTPathName::backToFront()
{
	for (int i = mPathName.index(shitePathsep); i != string::npos; i = mPathName.index(shitePathsep, i)) {
	mPathName.replace(i, 1, posixPathsep);
  }
}

void MTPathName::normalizeSlashes()
{
#ifdef WIN32
  frontToBack();
#else
  backToFront();
#endif
}


// Global operators
ostream &operator<<(ostream &s, const MTPathName &path)
{
  s << path.getString();
  return s;
}
