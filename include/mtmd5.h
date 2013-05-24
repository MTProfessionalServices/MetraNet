/* MTMD5.H - header file for MD5C.C
 */

/* Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All
rights reserved.

License to copy and use this software is granted provided that it
is identified as the "RSA Data Security, Inc. MD5 Message-Digest
Algorithm" in all material mentioning or referencing this software
or this function.

License is also granted to make and use derivative works provided
that such works are identified as "derived from the RSA Data
Security, Inc. MD5 Message-Digest Algorithm" in all material
mentioning or referencing the derived work.

RSA Data Security, Inc. makes no representations concerning either
the merchantability of this software or the suitability of this
software for any particular purpose. It is provided "as is"
without express or implied warranty of any kind.

These notices must be retained in any copies of any part of this
documentation and/or software.
 */


/* MetraTech NOTE: Procedures, structs, and defines in this module
   have been changed from the original RSA source.  They now all
   sport the "MT_" prefix.  This is to disambiguate these from
   those in the crypto libraries that comes with the various UNIX
   SSL toolkits.  -blount */ 

/* MD5 context. */

/* Package internal constants. */

#ifndef _MTMD5_H
#define _MTMD5_H

#ifdef UNIX
#define UINT4 unsigned int
#endif

#define MT_MD5_DIGEST_LENGTH 16

typedef struct {
  UINT4 state[4];                                   /* state (ABCD) */
  UINT4 count[2];        /* number of bits, modulo 2^64 (lsb first) */
  unsigned char buffer[64];                         /* input buffer */
} MT_MD5_CTX;

void MT_MD5_Init PROTO_LIST ((MT_MD5_CTX *));
void MT_MD5_Update PROTO_LIST
  ((MT_MD5_CTX *, unsigned char *, unsigned int));
void MT_MD5_Final PROTO_LIST ((unsigned char [16], MT_MD5_CTX *));

#endif /* _MTMD5_H */

