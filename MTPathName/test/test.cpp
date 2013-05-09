/**************************************************************************
 * @doc TEST
 *
 * Copyright 1999 by MetraTech Corporation
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

#include <metra.h>
#include <mtcom.h>
#include <iostream>
#include <MTPathName.h>

using namespace std;

void testGetTail(const char *path)
{
  MTPathName mp(path), tail;
  mp.getTail(tail);
  cout << "tail of " << mp.toAscii() << " is " << tail.toAscii() << endl;
}

void testGetHead(const char *path)
{
  MTPathName mp(path), head;
  mp.getHead(head);
  cout << "head of " << mp.toAscii() << " is " << head.toAscii() << endl;
}

void testDriveLetter(const char *path, char letter)
{
  MTPathName mp(path);
  cout << "setting path " << mp.toAscii() << " letter " << letter << endl;
  mp.setDriveLetter(letter);
  cout << mp.toAscii() << endl << endl;
}

void testNorm(const char *path)
{
  MTPathName mp(path);
  cout << "normalize " << mp.toAscii() << endl;
  mp.normalize();
  cout << mp.toAscii() << endl << endl;
}

void testNormTime(const char *path)
{
  for (int i = 0; i < 10000; i++)
  {
	MTPathName mp(path);
	mp.normalize();
  }
}

void testAppend(const char *path0, const char *path1)
{
  MTPathName mp0(path0), mp1(path1);
  cout << "appending " << path0 << " " << path1 << endl;
  mp0.append(mp1);
  cout << mp0.toAscii() << endl << endl;
}


bool testPath()
{
  RWCString path0("f:/foo");
  RWCString path1("f:/Foo/bar");

  MTPathName *mp0 = new MTPathName(path0);
  cout << "path0: f:/foo" << endl;
  cout << mp0->toAscii() << endl << endl;

  MTPathName *mp1 = new MTPathName(path1);
  cout << "normcase: f:/Foo/bar" << endl;
  mp1->normalizeCase();
  cout << mp1->toAscii() << endl << endl;

  MTPathName drive;
  mp1->getDrive(drive);
  cout << "getdrive f:/Foo/bar" << endl;
  cout << drive.toAscii() << endl << endl;

  cout << "getNoDrive f:/Foo/bar" << endl;
  MTPathName noDrive;
  mp1->getNoDrive(noDrive);
  cout << noDrive.toAscii() << endl << endl;

  testNorm("\\");
  testNorm("c:");
  testNorm("c:/hey/im/a/file/../teapot/so/there");
  testNorm("c:/hey/im/a/file/../../teapot/so/there");
  testNorm("c:../../hey/im/a/file/../../teapot/so/there");
  testNorm("c:/../../hey/im/a/file/../../teapot/so/there");

  cout << "no drive letter" << endl;
  testNorm("/../../hey/im/a/file/../../teapot/so/there");
  testNorm("../../hey/im/a/file/../../teapot/so/there");

  cout << "dual sep" << endl;
  testNorm("//../../hey/im/a/file/../../teapot/so/there");
  testNorm("../../hey//im/a/file/../../teapot/so/there");

  cout << "embedded dot" << endl;
  testNorm("c:/../../hey/./im/a/file/../../teapot/so/there/..");

  cout << "trailing slash" << endl;
  testNorm("c:/../../hey/im/a/teapot/so/there///");

  cout << "setDriveLetter" << endl;
  testDriveLetter("c:\\foo", 'd');
  testDriveLetter("\\foo", 'd');
  testDriveLetter("foo", 'd');


  cout << "testing append" << endl;
  testAppend("foo", "bar");
  testAppend("c:\\foo", "bar");
  testAppend("c:\\foo", "\\bar");
  testAppend("c:\\foo", "d:\\bar");
  testAppend("\\foo", "d:bar");
  testAppend("foo", "d:bar");
  testAppend("foo", "d:\\bar");

  cout << "testing head" << endl;
  testGetHead("");
  testGetHead("foo");
  testGetHead("\\foo");
  testGetHead("c:");
  testGetHead("c:foo");
  testGetHead("c:\\foo");
  testGetHead("foo\\bar");
  testGetHead("foo\\bar\\baz");

  cout << endl << "testing tail" << endl;
  testGetTail("\\");
  testGetTail("c:");
  testGetTail("c:\\");
  testGetTail("foo");
  testGetTail("\\foo");
  testGetTail("c:foo");
  testGetTail("c:\\foo");
  testGetTail("foo\\bar");
  testGetTail("foo\\bar\\baz");
  testGetTail("foo\\bar\\baz\\");

  return TRUE;
}

int main(int argc, char * argv[])
{
  ComInitialize ci(COINIT_MULTITHREADED);
  testPath();
  return 0;
}
