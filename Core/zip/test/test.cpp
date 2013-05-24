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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <zipdir.h>
#include <iostream>

using std::cout;
using std::endl;


int main (int argc, char * argv[])
{
	if (argc < 4)
	{
		cout << "usage: ziptest dirname zipname outdir" << endl;
		return 0;
	}
	else if (argc != 5)
	{
		cout << "or usage: ziptest dirname zipname filename outdir" << endl;
		return 0;
	}

#if 0
	ZipUtils ziputils;
	if (!ziputils.ZipDirectory(argv[1], argv[2]))
		cout << "Could not zip" << endl;
	else
		cout << "zip successful" << endl;

	if (!ziputils.UnzipDirectory(argv[3], argv[2]))
		cout << "Could not unzip" << endl;
	else
		cout << "unzip successful" << endl;
#else

	ZipUtils ziputils;
	if (!ziputils.AddOneFileToZip(argv[1], argv[2], argv[3]))
		cout << "Could not zip" << endl;
	else
		cout << "zip successful" << endl;

	if (!ziputils.UnzipDirectory(argv[4], argv[2]))
		cout << "Could not unzip" << endl;
	else
		cout << "unzip successful" << endl;
#endif

  return 0;
}



