/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#include <metralite.h>
#include <base64.h>
#include <iostream>
#include <time.h>

using std::cout;
using std::endl;

int main (int argc, char * argv[])
{
  int failure = ERROR_NONE;	/* Assume success */

	if (argc == 1)
	{
		cout << "invalid usage" << endl;
		return 0;
	}

  if (argc == 3 && strcmp(argv[1],"-d") == 0)
  {
		const char * src = argv[2];
		int len = strlen(src);

		std::vector<unsigned char> dest;
    failure = rfc1421decode(src, len, dest);

		std::string outstring;
		for (unsigned int i = 0; i < dest.size(); i++)
			outstring += dest[i];

		cout << "original: '" << src << '\'' << endl;
		cout << "decoded: '" << outstring.c_str() << '\'' << endl;
  }
  else if (argc == 3 && strcmp(argv[1],"-msix") == 0)
  {
		const char * src = argv[2];
		int len = strlen(src);

		std::vector<unsigned char> dest;
		failure = rfc1421decode(src, len, dest);

		cout << "original: '" << src << '\'' << endl;
		
		cout << "raw bytes : ";
		for (unsigned int i=0; i < dest.size(); i++)
		{
			int ival = dest[i]; 
			cout << ival << ' ';
		}
		cout << endl;
		
/*		
		cout << "Entity: ";	
		for (int i=0; i < min (4, dest.length()); i++)
		{
			cout << (unsigned int)dest[i]; 
			if  (i < 3)
				cout << '.';
		}	
		cout << endl;

		if (dest.length() >= 8)
		{
	
		long val = MAKELONG (MAKEWORD(dest[4],dest[5]), MAKEWORD(dest[6],dest[7]));

		for (int i=4; i < 8; i++)
		{
			val = val << 8;
			int ival = dest[i]; 
			val += ival;
		}

		cout << "Timestamp: " << ctime(&val) << endl;
		}
*/
		

  }  
  else if (argc == 2)
  {
		int len = strlen(argv[1]);
		const unsigned char * src = (const unsigned char *) argv[1];

		std::string dest;
		rfc1421encode(src, len, dest);

		cout << "original: '" << src << '\'' << endl;
		cout << "encoded: '" << dest.c_str() << '\'' << endl;
  }
  else
  {
    failure = ERROR_ARGS;
  }

  switch (failure) {
  case ERROR_EQUAL:
    fprintf (stderr, "%s %s: Misplaced `=' in standard input.\n",
						 argv[0], "1");
    break;
  case ERROR_INCOMPLETE:
    fprintf (stderr, "%s %s: Standard input ended without completing last byte quadruplet.\n",
						 argv[0], "1");
    break;
  case ERROR_ARGS:
    fprintf(stderr, "Usage:\n\t%s [-d | --version]\n\n", argv[0]);
    fprintf(stderr, "Encodes standard input to standard output for shipment via e-mail.\n");
    fprintf(stderr, "The \"-d\" option reverses the process.\n");
    fprintf(stderr, "The \"--version\" option prints the software version number.\n\n");
    fprintf(stderr, "This is BASE64 encoding.  See RFCs 1341, 1421, and 1113.\n");
  }

  return failure;
}


