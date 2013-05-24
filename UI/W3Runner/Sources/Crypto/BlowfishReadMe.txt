The README file for Visual Basic Blowfish functions

This is a Visual Basic version of Bruce Schneier's Blowfish algorithm
as detailed in "Applied Cryptography", 2nd edition, 1996

It has been tested in VB6 and Access VBA. Use at your own risk.

Version 5. Published 27 January 2002. History at end.
'************************* COPYRIGHT NOTICE*************************
' This code was originally written in Visual Basic by David Ireland
' and is copyright (c) 2000-2 D.I. Management Services Pty Limited,
' all rights reserved.

' You are free to use this code as part of your own applications
' provided you keep this copyright notice intact and acknowledge
' its authorship with the words:

'   "Contains cryptography software by David Ireland of
'   DI Management Services Pty Ltd <www.di-mgt.com.au>."

' If you use it as part of a web site, please include a link
' to our site in the form
' <A HREF="http://www.di-mgt.com.au/crypto.html">Cryptography
' Software Code</a>

' This code may only be used as part of an application. It may
' not be reproduced or distributed separately by any means without
' the express written permission of the author.

' David Ireland and DI Management Services Pty Limited make no
' representations concerning either the merchantability of this
' software or the suitability of this software for any particular
' purpose. It is provided "as is" without express or implied
' warranty of any kind.

' Please forward comments or bug reports to <code@di-mgt.com.au>.
' The latest version of this source code can be downloaded from
' www.di-mgt.com.au/crypto.html.
'****************** END OF COPYRIGHT NOTICE*************************


There are 12 VB modules and two VB projects.

The main modules are:

1. basBlowfishFns: the main wrapper fns you will call in your programs
2. basBlowfishCBC: similar wrapper fns in CBC mode
3. basBlowfishFileFns: wrapper functions for file encryption
4. basBlowfish: the actual Blowfish algorithm in Visual Basic
5. basBlfArrays: the blowfish S and P arrays
6. basUnsignedWord: utilities for unsigned word operations
7. basConvert: conversion utilities for byte-strings-hex-word 
8. basFileAPI: wrapper fns to read and write files using Windows API
   functions (these work better than VB's standard Open and Put fns).
9. basRadix64: functions to encode binary strings to base64 format
   and vice versa (aka radix64, Transfer Encoding, Printable Encoding).
10. basAPITimer: Timer functions by Litwin, Getz, Gilbert.

Plus these modules that contain test functions:
a. basTestBlowfish: examples of Blowfish use and a test suite
b. basTestRadix64: examples of base64/radix64 encoding and decoding

Plus three text files to use in testing the file encryption functions:
hello.txt, nowis.txt, sonnets.txt.

To use:

Add the files to your VB project or import them into modules in Access.

The main functions are:

blf_StringEnc(strData): Enciphers string strData with current key

blf_StringDec(strData): Deciphers string strData with current key

blf_FileEnc(sFileIn, sFileOut): Enciphers file with name sFileIn
   with current key and writes output to new file sFileOut

blf_FileDec(sFileIn, sFileOut): Deciphers file with name sFileIn
   with current key and writes output to new file sFileOut

To set the current key, call blf_KeyInit(aKey())
   where aKey() is the key as an array of Bytes.

The CBC functions are called in the same manner with an extra
parameter strIV in each case. This is the 8-byte
initialisation vector as a 16-digit hex string.

NB The padding technique is as described in RFC 2630.

Class Modules: It is a trivial exercise to convert these functions
to class modules. Please feel free to do so, but please keep the
copyright notice intact if you do.

Modification history
--------------------
20 October 2000: Version 1 first published.
=============================================
16 November 2000: Version 2:
 	Added new module basBlowfishCBC with CBC variants
	of main wrapper functions.
	Changed En(De)CryptBytes fns from private to public
	Changed name of bu_Str2Bytes to bu_HexStr2Bytes
	Ditto bu_Str2Words to bu_HexStr2Words
	Added new byte utility fns:
	bu_XorBytes
	bu_CopyBytes
	bu_Bytes2String
	bu_String2Bytes

	Added CBC tests to basTestBlowfish
=============================================
28 December 2000: Version 3:
  Added Radix64 functions and
  improved functionality of demo form.
  Improved (!) legalise in copyright notice.
  New base64/radix64 functions are:
  EncodeStr64 - encodes string of binary chars to radix 64 format.
   - does not add CRLFs or any other formatting.
  DecodeStr64 - decodes radix64 chars back to binary string.
   - ignores any non-radix64 characters.
=============================================
20 January 2001: Version 3a:
	Minor bug fix to demo project form frmBlowfish.frm.
	If ciphertext ends with an acsii zero and is then stored directly
	in a VB text box, the text box truncates the trailing zeroes.
	Changed code behind form to store ciphertext in a string instead.
	Thanks to Jim McCusker of epotec.com for this fix.
==============================================
12 May 2001: Version 4:
	Various minor improvements.
	Thanks to Doug J Ward for his suggestions and advice on improving
	the speed of some of the byte operations and for much improved
	ShiftLeft and ShiftRight functions used in basRadix64.
	Thanks also to Robert Garofalo for pointing out an error in
	the max length of the blowfish key and a fix in error handling.
==============================================
27 January 2002: Version 5:
	Major re-write.
	Improved internal Blowfish word manipulation functions.
	Major speed improvements to string encryption functions
	(with many thanks to Robert Garofalo for suggestions
	incorporated here).
	Replaced old-style byte conversion routines in basByteUtils
	with dynamic array versions in basConvert
==============================================


