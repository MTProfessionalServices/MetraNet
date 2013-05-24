/**************************************************************************
 * @doc BASE64
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

/***************************************************************
* This implementation of RFC1421 is Copyright 1994, 1995 by
* The University of Chicago Biological Sciences Division, Academic Computing
* Lee Newberg
*
* It is covered by the GNU General Public License included in
* this distribution and may be redistributed accordingly.
***************************************************************/
/*
 * adapted for use for MetraTech by dyoung
 */
#include <metralite.h>
#include "base64.h"

/* NOP is the "encoded" value for non-significant characters */
#define NOP  255
/* EQUAL is the "encode" value for the equal sign */
#define EQUAL 64
/* LINE is the number of encoded byte quadruplets printed per line */
#define LINE  19

/* Possible return values */
#define ERROR_NONE       0
#define ERROR_ARGS       1
#define ERROR_EQUAL      2
#define ERROR_INCOMPLETE 3

/* For converting 6 bits of data to an 8-bit printable character */
static unsigned char encode[64] = {'A', 'B', 'C', 'D', 'E', 'F', 'G',
'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6',
'7', '8', '9', '+', '/'};

/* For converting an 8-bit printable character to 6 bits of data */
static unsigned char decode[256] = {
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP,
NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP, NOP};

#if 0
/* rfc1421encode: Converts standard input containing arbitrary,
 * unsigned bytes into printable characters and writes them
 * to standard output.  A carriage-return/line-feed pair is
 * inserted after every 4 * LINE printed characters. */

int rfc1421encode()
{
  int i;
  unsigned int a, b, c;

  i = 0;
  while ((a = getchar()) != EOF)
  {
    if ((b = getchar()) != EOF)
    {
      if ((c = getchar()) != EOF)
      {
				/* Encode three bytes */
				putchar(encode[                  (a >> 2)]);
				putchar(encode[((a & 3) << 4)  + (b >> 4)]);
				putchar(encode[((b & 15) << 2) + (c >> 6)]);
				putchar(encode[((c & 63))]);
				if (++i == LINE)
				{
					putchar('\n');
					i = 0;
				}
      }
      else
      {
				/* Encode last two bytes */
				putchar(encode[                  (a >> 2)]);
				putchar(encode[((a & 3) << 4)  + (b >> 4)]);
				putchar(encode[((b & 15) << 2)           ]);
				putchar('=');
				i++;
				break;
      }
    }
    else
    {
      /* Encode last byte */
      putchar(encode[                  (a >> 2)]);
      putchar(encode[((a & 3) << 4)            ]);
      putchar('=');
      putchar('=');
      i++;
      break;
    }
  }
  if (i != 0) {
    putchar('\n');
  }

  return ERROR_NONE;
}
#endif


static BOOL rfc1421encode_internal(const unsigned char * apSrc, 
                                   int aSrcLen, string & arDest, BOOL nl)
{
  int i;
  unsigned int a, b, c;

	// the destination is about 1/3 bigger than the original.  We
	// take the easy estimate and double it.
	// NOTE: small strings will have padding added to the end
	// so the estimation doesn't work - that's why we add 8.
	char * buffer = new char[aSrcLen * 2 + 8];
	int bufferPos = 0;

  i = 0;
	int pos = 0;
	while (pos < aSrcLen)
	{
		a = apSrc[pos++];
		if (pos < aSrcLen)
		{
			b = apSrc[pos++];
			if (pos < aSrcLen)
			{
				c = apSrc[pos++];
				/* Encode three bytes */
				buffer[bufferPos++] = encode[                  (a >> 2)];
				buffer[bufferPos++] = encode[((a & 3) << 4)  + (b >> 4)];
				buffer[bufferPos++] = encode[((b & 15) << 2) + (c >> 6)];
				buffer[bufferPos++] = encode[((c & 63))];
				if (++i == LINE)
				{
          if (nl)
            buffer[bufferPos++] = '\n';
					i = 0;
				}
      }
      else
      {
				/* Encode last two bytes */
				buffer[bufferPos++] = encode[                  (a >> 2)];
				buffer[bufferPos++] = encode[((a & 3) << 4)  + (b >> 4)];
				buffer[bufferPos++] = encode[((b & 15) << 2)           ];
				buffer[bufferPos++] = '=';
				i++;
				break;
      }
    }
    else
    {
      /* Encode last byte */
      buffer[bufferPos++] = encode[                  (a >> 2)];
      buffer[bufferPos++] = encode[((a & 3) << 4)            ];
      buffer[bufferPos++] = '=';
      buffer[bufferPos++] = '=';
      i++;
      break;
    }
  }
  if (i != 0) {
		// NOTE: this was orignally
//     buffer[bufferPos++] = '\n';
		// but I changed it to output an = instead so whitespace could be ignored.
//    buffer[bufferPos++] = '=';
  }

	buffer[bufferPos] = '\0';
	arDest = buffer;
	delete [] buffer;
  return TRUE;
}

BOOL rfc1421encode(const unsigned char * apSrc, int aSrcLen, string & arDest)
{
  return rfc1421encode_internal(apSrc, aSrcLen, arDest, TRUE);
}


BOOL rfc1421encode_nonewlines(const unsigned char * apSrc, int aSrcLen, 
                              string & arDest)
{
  return rfc1421encode_internal(apSrc, aSrcLen, arDest, FALSE);
}





/* rfc1421decode: Converts standard input containing printable
 * characters into arbitrary, unsigned bytes and writes it to
 * standard output.  Characters of standard input that could not
 * come from standard output of rfc1421encode are ignored. */

int rfc1421decode (const char * apSrc, int aSrcLen,
									 vector<unsigned char> & arDest)
{
  unsigned int input;		/* Encoded input bytes */
  unsigned char a, b, c, d;	/* Decoded 6-bit input value  */
  int failure = ERROR_NONE;	/* Assume success */

	int pos = 0;									/* position into apSrc */

  if (decode['A'] == NOP) {

    /* We initialize decode in this routine rather than
     * statically because C does not provide a means for
     * statically initializing array elements if the order of
     * the array elements is not known by the programmer.  If we
     * were willing to assume that we were on an ASCII system,
     * we could use static initialization since the order of the
     * characters would then be known. */

    decode['A'] = 0;
    decode['B'] = 1;
    decode['C'] = 2;
    decode['D'] = 3;
    decode['E'] = 4;
    decode['F'] = 5;
    decode['G'] = 6;
    decode['H'] = 7;
    decode['I'] = 8;
    decode['J'] = 9;
    decode['K'] = 10;
    decode['L'] = 11;
    decode['M'] = 12;
    decode['N'] = 13;
    decode['O'] = 14;
    decode['P'] = 15;
    decode['Q'] = 16;
    decode['R'] = 17;
    decode['S'] = 18;
    decode['T'] = 19;
    decode['U'] = 20;
    decode['V'] = 21;
    decode['W'] = 22;
    decode['X'] = 23;
    decode['Y'] = 24;
    decode['Z'] = 25;
    decode['a'] = 26;
    decode['b'] = 27;
    decode['c'] = 28;
    decode['d'] = 29;
    decode['e'] = 30;
    decode['f'] = 31;
    decode['g'] = 32;
    decode['h'] = 33;
    decode['i'] = 34;
    decode['j'] = 35;
    decode['k'] = 36;
    decode['l'] = 37;
    decode['m'] = 38;
    decode['n'] = 39;
    decode['o'] = 40;
    decode['p'] = 41;
    decode['q'] = 42;
    decode['r'] = 43;
    decode['s'] = 44;
    decode['t'] = 45;
    decode['u'] = 46;
    decode['v'] = 47;
    decode['w'] = 48;
    decode['x'] = 49;
    decode['y'] = 50;
    decode['z'] = 51;
    decode['0'] = 52;
    decode['1'] = 53;
    decode['2'] = 54;
    decode['3'] = 55;
    decode['4'] = 56;
    decode['5'] = 57;
    decode['6'] = 58;
    decode['7'] = 59;
    decode['8'] = 60;
    decode['9'] = 61;
    decode['+'] = 62;
    decode['/'] = 63;
    /* '=' is a valid character even though it doesn't represent
       bits.  We'll assign it value EQUAL arbitrarily. */
    decode['='] = EQUAL;
  }

  while (1)
  {
		while (pos < aSrcLen)
		{
			input = apSrc[pos++];
			a = decode[input];
			if (a != NOP)
				break;
		}
		if (pos < aSrcLen)
    {
			while (pos < aSrcLen)
			{
				input = apSrc[pos++];
				b = decode[input];
				if (b != NOP)
					break;
			}

			if (pos < aSrcLen)
			{
				while (pos < aSrcLen)
				{
					input = apSrc[pos++];
					c = decode[input];
					if (c != NOP)
						break;
				}

				if (pos < aSrcLen)
				{
					while (pos < aSrcLen)
					{
						input = apSrc[pos++];
						d = decode[input];
						if (d != NOP)
							break;
					}

					if (pos <= aSrcLen)
					{
						/* Got four significant characters */
						if (a == EQUAL || b == EQUAL || (c == EQUAL && d != EQUAL)) {
							/* If the byte quadruplet has equal signs there
               * must be one or two and they must be the last
               * characters of the quadruplet.*/
							failure = ERROR_EQUAL;
							break;
						}
						if (d != EQUAL)
						{
							/* No '=' padding present */
							arDest.push_back((a << 2) + (b >> 4));
							arDest.push_back(((b & 15) << 4) + (c >> 2));
							arDest.push_back(((c & 3) << 6) + d);
						}
						else if (c != EQUAL)
						{
							/* One '=' padding character present */
							arDest.push_back((a << 2) + (b >> 4));
							arDest.push_back(((b & 15) << 4) + (c >> 2));
						}
						else if (b != EQUAL)
						{
							/* Two '=' padding characters present */
							arDest.push_back((a << 2) + (b >> 4));
						}
					}
					else
					{
						/* Got only three bytes of last BASE64 quadruplet */
						failure = ERROR_INCOMPLETE;
						break;
					}
				}
				else
				{
					/* Got only two bytes of last BASE64 quadruplet */
					failure = ERROR_INCOMPLETE;
					break;
				}
      }
      else
      {
				/* Got only one byte of last BASE64 quadruplet */
				failure = ERROR_INCOMPLETE;
				break;
      }
    }
    else
    {
      /* Reached end of input without error */
      break;
    }
  }

  return failure;
}

