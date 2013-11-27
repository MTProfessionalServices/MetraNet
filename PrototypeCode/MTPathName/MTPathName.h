/**************************************************************************
 * @doc MTPATHNAME
 *
 * @module |
 *
 * Portable pathname handler
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
 *
 * @index | MTPATHNAME
 ***************************************************************************/

#ifndef _MTPATHNAME_H
#define _MTPATHNAME_H


//
// This class does not open or stat files.  It works only with the
// string representation of pathnames.
//

#include <string>
#include <errobj.h>

class MTPathName : public virtual ObjectWithError
{
public:
  MTPathName();
  MTPathName(const MTPathName &pathName);
  MTPathName(const std::wstring &pathName);
  MTPathName(const char *pathName);
  MTPathName(const unsigned char *pathName);

  virtual ~MTPathName();

  ////
  //// Assignment
  ////

  MTPathName &operator =(const MTPathName &pathName);   // Replace string
  MTPathName &operator =(const std::wstring &pathName);    // Replace string
  MTPathName &operator =(const char *pathName);         // Replace string

  ////
  //// Path Manipulation 
  ////

  // Normalize the case of a pathname.  On Unix, this returns the path
  // unchanged; on case-insensitive filesystems, it converts the path
  // to lowercase.  On Windows, it also converts forward slashes to
  // backwards slashes.  Rumor has it that Paul Allen was the guy who
  // decided to use backslashes in DOS so it would not look so much
  // like CP/M.  For this we should all hate his guts forever.
  void normalizeCase();

  // Normalize a pathanme.  This collapses redundant separators and
  // up-level references, e.g. A//B, A/./B and a/foo/../B all become
  // A/B.  It does not normalize the case (use normalizeCase() for
  // that.  On Windows, it converts forward slashes to backwards
  // slashes.
  void normalize();

  // Joins segment to the path intelligently.  If pathName is an
  // absolute path, or has a different drive letter than this, this
  // instance's previous components are thrown away.
  // 
  // This instance becomes the concatination of its value and
  // pathName, with exactly one slash inserted between the components.
  void append(const char *pathName) { append(MTPathName(pathName)); }
  void append(const std::wstring &pathName) { append(MTPathName(pathName)); }
  void append(const MTPathName &pathName);

  void setDriveLetter(char drive);

  ////
  //// Accessors
  //// 

  // Returns TRUE if path is an absolute pathname.  It is absolute if
  // it begins with a slash or a drive letter followed by a slash.
  bool isAbs() const;

  // Returns pointer to path as a null-terminated wide string.
  operator const wchar_t *() const { return (const wchar_t *) mPathName.c_str(); }

  // Returns reference to path as a std::wstring
  const std::wstring &getString() const { return mPathName; }

  // Fills in drive with drive letter followed by a colon, if any. If
  // there is no drive letter, drive remains unchanged
  bool getDrive(MTPathName &drive) const;

  // Returns drive letter as a char.  No colon (obviously).
  // Returns 0 if no letter
  char getDriveLetter() const;

  // Fills in noDrive with path name minus drive letter and colon, if
  // any.  Otherwise noDrive remains unchanged.
  bool getNoDrive(MTPathName &noDrive) const;

  int getLength() const { return mPathName.length(); }

  // Sets head to a MTPathName containing this path minus the trailing
  // component.  Trailing slashes are stripped unless it is the root
  // (one or more slashes only).
  void getHead(MTPathName &head) const;

  // Sets head to a new MTPathName containing this path's trailing
  // component.  The new path will never contain a slash.  If this
  // path ends in a slash, the returned tail will be empty.
  void getTail(MTPathName &tail) const;

  std::string toAscii() const;
  

  // Sets argument to ASCII value
  friend ostream &operator<<(ostream &s, const MTPathName &path);

private:

	std::wstring mPathName;

  // Converts forward slashes to backwards slashes, or vice-versa 
  void frontToBack();
  void backToFront();

  // Converts slashes to proper local form, if necessary
  void normalizeSlashes();
};

#endif /* _MTPATHNAME_H */
