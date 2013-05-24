/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LISCENCED SOFTWARE OR
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

#include <metra.h>
#include <XMLParser.h>

#include <stdlib.h>
#include <stdio.h>

#ifdef UNIX
#include <wchar.h>
#endif

#ifdef WIN32
#include <objectpool.h>
#endif

#include "MTUtil.h"
#include "stdutils.h"

#include <mtmd5.h>

using namespace std;

// TODO: this doesn't work when aLen = -1
// UPDATE: I think it works now for aLen = -1, should verify this
int Utf8ToXMLString(XMLString & arWstring, const char * apUtf8,
									int aLen /* = -1 */)
{
	// TODO: rewrite this function to be portable.

	// if no length given, string should be null terminated.

#ifdef WIN32
	if (aLen == -1)
		aLen = strlen(apUtf8);

	int len = MultiByteToWideChar(
		CP_UTF8,										// code page
		0,													// character-type options
		apUtf8,											// address of string to map
		aLen,												// number of bytes in string
		NULL,												// address of wide-character buffer
		0);													// size of buffer

	wchar_t * out = new wchar_t[len + 1];
	(void) MultiByteToWideChar(
		CP_UTF8,										// code page
		0,													// character-type options
		apUtf8,											// address of string to map
		aLen,												// number of bytes in string
		out,												// address of wide-character buffer
		len);												// size of buffer

	// put it into the wstring
	// TODO: is there a better way to do this?
	out[len] = L'\0';
	arWstring = out;
	//XMLString temp(out);
	//temp.append(out, len);
	//arWstring = temp;
	//.assign(out, len);


	delete [] out;
	return 1;
#else
  if (aLen <= 0)
    aLen = strlen(apUtf8);

  char *scratch = (char *)malloc(aLen + 1);
  strncpy(scratch, apUtf8, aLen);
  scratch[aLen] = 0;
  wchar_t * get_size = new wchar_t[aLen];
  int len = mbstowcs(get_size, scratch, aLen);
  delete [] get_size;
	wchar_t * out = new wchar_t[len];
  mbstowcs(out, scratch, len);

  free(scratch);
  wstring temp(out, len);
  arWstring = temp;
  
  // arWstring.assign(out, len);
	delete [] out;
	
	return 1;

#endif

#if 0
	// if no length given, string should be null terminated.
	if (aLen == -1)
		aLen = strlen(apUtf8);

	// NOTE: I believe the xmltok parser won't store nulls in the strings,
	// so mblen and mbstowcs can be used for string handling.
	// to verify this I put &#0; into a document and xmltok complained
	// that it was an invalid character.

	// TODO: does this call use aLen correctly?
	int len = mbstowcs(NULL, apUtf8, aLen);
	if (len == -1)
		return 0;										// an invalid mb was encountered

	// NOTE: mbstowcs will only null terminate the string
	// if the original UTF8 string was null terminated.
	// therefore, we can make the array exactly the size
	// returned by the first call to mbstowcs
	wchar_t * out = new wchar_t[len];
	if (mbstowcs(out, apUtf8, len) == -1)
	{
		delete [] out;
		return 0;										// an invalid mb was encountered
	}

	// put it into the wstring
	arWstring.assign(out, len);
	delete [] out;
	return 1;
#endif
}


int XMLStringToAscii(string & arString, const XMLString & arXmlString)
{
	// TODO: this doesn't do anything differently than XMLStringToUtf8
	//return XMLStringToUtf8(arString, arXmlString);

	arString = ascii(arXmlString);
	return TRUE;
}

//
// PERFORMANCE NOTE:
// this routine is a low level routine that can be called thousands
// of times.  therefore, there is an ASCII and a Unicode version of the
// call.  They must both act the same way.
//

//
// STANDARDS NOTE: Escaping for attribute values differs for that of
// "between the tag" data
//
BOOL EscapeXMLChars(wstring & arEscapedString,
										const wchar_t * apXmlString,
										BOOL isAttributeValue)
{
	//
	// NOTE: this routine is optimized to do a straight string
	// copy if there are no characters that need escaping.
	//

	if (wcspbrk(apXmlString, L"<>'\"&") == NULL)
		return FALSE;								// do nothing!

	if (isAttributeValue) {

		for (int i = 0; apXmlString[i] != L'\0'; i++)
		{
			switch (apXmlString[i])
			{
			case L'<':
				arEscapedString += L"&lt;";
				break;
			case L'>':
				arEscapedString += L"&gt;";
				break;
			case L'\'':
				arEscapedString += L"&apos;";
				break;			
			case L'"':
				arEscapedString += L"&quot;";
				break;
			case L'&':
				arEscapedString += L"&amp;";
				break;
			default:
				arEscapedString += apXmlString[i];
				break;
			}
		}

	} else {

		for (int i = 0; apXmlString[i] != L'\0'; i++)
		{
			switch (apXmlString[i])
			{
			case L'<':
				arEscapedString += L"&lt;";
				break;
			case L'>':
				arEscapedString += L"&gt;";
				break;
			case L'&':
				arEscapedString += L"&amp;";
				break;
			default:
				arEscapedString += apXmlString[i];
				break;
			}
		}
	}
	return TRUE;
}


BOOL EscapeXMLChars(string & arEscapedString,
										const char * apXmlString,
										BOOL isAttributeValue)
{
	//
	// NOTE: this routine is optimized to do a straight string
	// copy if there are no characters that need escaping.
	//

	if (strpbrk(apXmlString, "<>'\"&") == NULL)
		return FALSE;

	if (isAttributeValue) {

		for (int i = 0; apXmlString[i] != '\0'; i++)
		{
			switch (apXmlString[i])
			{
			case '<':
				arEscapedString += "&lt;";
				break;
			case '>':
				arEscapedString += "&gt;";
				break;
			case '\'':
				arEscapedString += "&apos;";
				break;			
			case '"':
				arEscapedString += "&quot;";
				break;
			case '&':
				arEscapedString += "&amp;";
				break;
			default:
				arEscapedString += apXmlString[i];
				break;
			}
		}
	} else {

		for (int i = 0; apXmlString[i] != '\0'; i++)
		{
			switch (apXmlString[i])
			{
			case '<':
				arEscapedString += "&lt;";
				break;
			case '>':
				arEscapedString += "&gt;";
				break;
			case '&':
				arEscapedString += "&amp;";
				break;
			default:
				arEscapedString += apXmlString[i];
				break;
			}
		}
	}
	return TRUE;
}

int XMLStringToUtf8(string & arString, const XMLString & arXmlString)
{
	int len;

#ifdef WIN32

	len = WideCharToMultiByte(
		CP_UTF8,										// code page
		0,													// performance and mapping flags
		arXmlString.c_str(),				// wide-character string
		arXmlString.length(),				// number of chars in string
		NULL,												// buffer for new string
		0,													// size of buffer
		NULL,												// default for unmappable chars
		NULL);											// set when default char used

	if (len == 0)
		return FALSE;

	char * out = new char[len];
	len = WideCharToMultiByte(
		CP_UTF8,										// code page
		0,													// performance and mapping flags
		arXmlString.c_str(),				// wide-character string
		arXmlString.length(),				// number of chars in string
		out,												// buffer for new string
		len,												// size of buffer
		NULL,												// default for unmappable chars
		NULL);											// set when default char used

	if (len == 0)
	{
		int err = ::GetLastError();

		return FALSE;
	}

	//arString = out;
	string temp(out, len);
	arString = temp;

	delete [] out;

	return TRUE;

#else
	// TODO: does this call use len correctly? Now it does.
	char * temp_str = new char[arXmlString.length()];
	len = wcstombs(temp_str, arXmlString.c_str(), arXmlString.length());
	delete [] temp_str;
	if (len == -1)
		return 0;										// an invalid mb was encountered

	// NOTE: wcstombs will only null terminate the string
	// if the original wide char string was null terminated.
	// therefore, we can make the array exactly the size
	// returned by the first call to wcstombs
	char * out = new char[len];
	if (wcstombs(out, arXmlString.c_str(), len) == -1)
	{
		delete [] out;
		return 0;										// an invalid mb was encountered
	}

	// put it into the wstring
	// TODO: can this be done differently?
	string temp(out, len);
	arString = temp;
	//arString.assign(out, len);

	delete [] out;
	return TRUE;

#endif
}

#if 0
// an alternate method of converting mb strings to wstrings.
// this function handles multibyte strings with embedded nulls,
// and strings with partial character codes.
int convert()
{
  char buffer[BUFSIZ + MB_LEN_MAX];
  int filled = 0;
  int eof = 0;

  while (!eof)
	{
		int nread;
		int nwrite;
		char *inp = buffer;
		wchar_t outbuf[BUFSIZ];
		wchar_t *outp = outbuf;

		/* Fill up the buffer from the input file.  */
		nread = read (input, buffer + filled, BUFSIZ);
		if (nread < 0)
		{
			perror ("read");
			return 0;
		}
		/* If we reach end of file, make a note to read no more. */
		if (nread == 0)
			eof = 1;

		/* filled is now the number of bytes in buffer. */
		filled += nread;

		/* Convert those bytes to wide characters--as many as we can. */
		while (1)
		{
			int thislen = mbtowc (outp, inp, filled);
			/* Stop converting at invalid character;
				 this can mean we have read just the first part
				 of a valid character.  */
			if (thislen == -1)
				break;
			/* Treat null character like any other,
				 but also reset shift state. */
			if (thislen == 0) {
				thislen = 1;
				mbtowc (NULL, NULL, 0);
			}
			/* Advance past this character. */
			inp += thislen;
			filled -= thislen;
			outp++;
		}

		/* Write the wide characters we just made.  */
		nwrite = write (output, outbuf,
										(outp - outbuf) * sizeof (wchar_t));
		if (nwrite < 0)
		{
			perror ("write");
			return 0;
		}

		/* See if we have a real invalid character. */
		if ((eof && filled > 0) || filled >= MB_CUR_MAX)
		{
			error ("invalid multibyte character");
			return 0;
		}

		/* If any characters must be carried forward,
			 put them at the beginning of buffer. */
		if (filled > 0)
			memcpy (inp, buffer, filled);
	}
}
#endif

//#ifdef UNIX
//unsigned int UnixHashFunc(const wstring &key)
//{
//  return wstring::hash(key);
//}
//#endif

/* atts is array of name/value pairs, terminated by NULL;
	 names and values are '\0' terminated. */
int XMLParser::HandleStartElement(const char * apName, const char * * apAtts)
{
	// NOTE: tag is assumed to be ASCII only
	XMLObject * opening = CreateOpeningTag(apName, apAtts);

	// return false if it was a semantic error
	if (!opening)
		return 0;

	// add to the stack
	Push(opening);

	if  (mMD5Flag == TRUE)
	{
		MT_MD5_Update(&mMD5Context,
		// casting hell!
		reinterpret_cast<unsigned char*>(const_cast<char*>((const char*)apName)),
		strlen(apName));

		for(unsigned int i=0;apAtts[i] != NULL;i++)
		{
			MT_MD5_Update(&mMD5Context,
			// casting hell!
			reinterpret_cast<unsigned char*>(const_cast<char*>((const char*)apAtts[i])),
			strlen(apAtts[i]));

		}

	}

	return 1;
}


/****************************************************** XMLParser ***/

// @mfunc Constructor
XMLParser::XMLParser() : mbCdataSection(FALSE), mDtd(NULL)
{
	// set up a default factory
	mpFactory = &mDefaultFactory;
	// parser is not initialized
	mParser = NULL;

	// it's OK to call Parse
	mParseComplete = FALSE;

	// default is to turn off the flag - no MD5 checksum
	mMD5Flag = FALSE;
}

// @mfunc Destructor
XMLParser::~XMLParser()
{
	if(mParser) {
		XML_ParserFree(mParser);
	}
}

// @mfunc change the object factory
// @parm pointer to new object factory
void XMLParser::SetObjectFactory(XMLObjectFactory * apFactory)
{
	mpFactory = apFactory;
}


int XMLParser::StartElementHandler(void * apUserData,
																		const char * apName,
																		const char * * apAtts)
{
  XMLParser * parser = (XMLParser *) apUserData;

  return parser->HandleStartElement(apName, apAtts);
}

int XMLParser::EndElementHandler(void * apUserData,
																 const char * apName)
{
  XMLParser * parser = (XMLParser *) apUserData;
  int res = parser->HandleEndElement(apName);

	return res;
}

int XMLParser::CharacterDataHandler(void * apUserData,
																		const char * apStr,
																		int aLen)
{
  XMLParser * parser = (XMLParser *) apUserData;

  return parser->HandleCharacterData(apStr, aLen);

}

int XMLParser::ProcessingInstructionHandler(void * apUserData,
																						const char * apTarget,
																						const char * apData)
{
  XMLParser * parser = (XMLParser *) apUserData;
  return parser->HandleProcessingInstruction(apTarget, apData);

}

int XMLParser::ProcessingExternalEntityRefHandler(XML_Parser parser,
					    const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId)
{
	
	XMLParser* pThis  = (XMLParser*)XML_GetUserData(parser);

	return pThis->HandleExternalEntityRefHandler(context,base,systemId,publicId);

}

void XMLParser::ProcessingUnparsedEntityDeclHandler(void *userData,
					      const char *entityName,
					      const char *base,
					      const char *systemId,
					      const char *publicId,
					      const char *notationName)
{
	// XXX not implemented yet
}

void XMLParser::ProcessingStartCData(void* apUserData)
{
	XMLParser * parser = (XMLParser *) apUserData;
	parser->mbCdataSection = TRUE;
}

void XMLParser::ProcessingEndCData(void* apUserData)
{
	XMLParser * parser = (XMLParser *) apUserData;
	parser->mbCdataSection = FALSE;
}


BOOL XMLParser::VerifyChecksum()
{
	if (mMD5Flag == FALSE)
		return FALSE;

	if ((strlen(mFileChecksum) == 0) && (strlen(mGeneratedChecksum) != 0))
		return FALSE;

	if (strncmp(mFileChecksum, mGeneratedChecksum, strlen(mGeneratedChecksum)) == 0)
		return TRUE;
	else
		return FALSE;
}


XMLObject * XMLParser::CreateInstruction(const XMLString & arTarget,
																				 const XMLString & arData)
{
	return mpFactory->CreateInstruction(arTarget, arData);
}


// @mfunc Initializes the parser
// @parm name of the charset from the Content-Type header if the Content-Type is text/xml,
//       null otherwise.
// @rdesc true if function succeeds.
BOOL XMLParser::Init(const char * apEncoding /* = NULL */, 
										 BOOL aMD5Flag/* = FALSE */)
{
	mParseComplete = FALSE;

	mMD5Flag = aMD5Flag;

	if (mParser)
	{
		// NOTE: the programmer should call init once, then call restart every time.
		// if this assert gets in the way it can be removed.
		//ASSERT(0);
		// free the existing parser if init is being called more than once
		XML_ParserFree(mParser);
	}

	if (mMD5Flag == TRUE) // create MD5 checksum only when it is told to do so
	{
		// Initialize MD5
		MT_MD5_Init(&mMD5Context);
		memset(mFileChecksum, 0, sizeof(mFileChecksum));
		memset(mGeneratedChecksum, 0, sizeof(mGeneratedChecksum));
	}

  mParser = XML_ParserCreate(apEncoding);
  if (!mParser)
	{
		// TODO: use a real error number!
		SetError(0, ERROR_MODULE, ERROR_LINE, "XMLParser::Init");
    return FALSE;
	}

  // this value is passed as the userData argument to the callbacks
  // use it to get the this pointer back
  XML_SetUserData(mParser, this);

  XML_SetElementHandler(mParser, StartElementHandler,
												EndElementHandler);

  XML_SetCharacterDataHandler(mParser, CharacterDataHandler);

  XML_SetProcessingInstructionHandler(mParser,
																			ProcessingInstructionHandler);

	XML_SetExternalEntityRefHandler(mParser,ProcessingExternalEntityRefHandler);

	XML_SetUnparsedEntityDeclHandler(mParser,ProcessingUnparsedEntityDeclHandler);

	XML_SetCdataSectionHandler(mParser,ProcessingStartCData,ProcessingEndCData);

	XML_SetParamEntityParsing(mParser,XML_PARAM_ENTITY_PARSING_ALWAYS);


	return TRUE;
}

// @mfunc Clears the state of the parser so it's ready to start
// parsing more data.
// @parm name of the charset from the Content-Type header if the Content-Type is text/xml,
//       null otherwise.
// @rdesc true if function succeeds.
BOOL XMLParser::Restart(const char * apEncoding /* = NULL */)
{
	// clear the old parser
	ASSERT(mParser);
	XML_ParserFree(mParser);
	mParser = NULL;

	// TODO: is this all we have to do?
	return Init(apEncoding);
}


// @mfunc Parse some of the document.
// @parm Buffer to parse.
// @parm Length of buffer.
// @rdesc TRUE if parse successful
BOOL XMLParser::Parse(const char * apStr, int aLen)
{
	ASSERT(!mParseComplete);
	ASSERT(mParser);

	// last param is is final
	if (!XML_Parse(mParser, apStr, aLen, FALSE))
	{
		// TODO: use a real error number!
		SetError(0, ERROR_MODULE, ERROR_LINE, "XMLParser::Parse");
		SetParseErrorDetail();
		return FALSE;
	}
	else
		return TRUE;
}

// @mfunc Parse some of the document.
// @parm Buffer to parse.
// @parm Length of buffer.
// @parm Will be set to the aggregate that holds
//       all data in the document.
// @rdesc TRUE if parse successful
BOOL XMLParser::ParseFinal(const char * apStr, int aLen,
													 XMLObject * * apResults)
{
	ASSERT(!mParseComplete);
	ASSERT(mParser);

	// last param is is final
	BOOL res = XML_Parse(mParser, apStr, aLen, TRUE);

	if (mMD5Flag == TRUE) {

		unsigned char rawDigest[MT_MD5_DIGEST_LENGTH];

		// 128 bits as 16 x 8 bit bytes.
		MT_MD5_Final(rawDigest, &mMD5Context);

		// Convert from 16 x 8 bits to 32 hex characters.
		for(int count = 0; count < MT_MD5_DIGEST_LENGTH; count++)
		{
				sprintf( &mGeneratedChecksum[count*2], "%02x", rawDigest[count] );
		}
	}
	
	GetResults(apResults);
	if (!res)
	{
		// TODO: use a real error number!
		SetError(0, ERROR_MODULE, ERROR_LINE, "XMLParser::ParseFinal");
		SetParseErrorDetail();
	}
	return res;
}


// @mfunc Parse some of the document.  The buffer is
// internal to the parser and is returned with GetBuffer.
// @parm Length of buffer.
// @rdesc TRUE if parse successful
BOOL XMLParser::ParseBuffer(int aLen)
{
	ASSERT(!mParseComplete);
	ASSERT(mParser);

	// last param is isfinal
	if (!XML_ParseBuffer(mParser, aLen, FALSE))
	{
		// TODO: use a real error number!
		SetError(0, ERROR_MODULE, ERROR_LINE, "XMLParser::ParseBuffer");
		SetParseErrorDetail();
		return FALSE;
	}
	else
		return TRUE;
}

// @mfunc Parse the final piece of the document from the internal buffer.
//   The buffer is internal to the parser and is returned with GetBuffer.
// @parm Length of buffer.
// @parm Will be set to the aggregate that holds
//       all data in the document.
// @rdesc TRUE if parse successful
BOOL XMLParser::ParseBufferFinal(int aLen, XMLObject * * apResults)
{
	ASSERT(!mParseComplete);
	ASSERT(mParser);

  // 128 bits as 16 x 8 bit bytes.
  unsigned char rawDigest[MT_MD5_DIGEST_LENGTH];

	// last param is isfinal
	BOOL res = XML_ParseBuffer(mParser, aLen, TRUE);
	
	MT_MD5_Final(rawDigest, &mMD5Context);

  // Convert from 16 x 8 bits to 32 hex characters.
  for(int count = 0; count < MT_MD5_DIGEST_LENGTH; count++)
  {
		sprintf( &mGeneratedChecksum[count*2], "%02x", rawDigest[count] );
  }

	GetResults(apResults);

	// don't try again without restarting
	mParseComplete = TRUE;

	if (!res)
	{
		// TODO: use a real error number!
		SetError(0, ERROR_MODULE, ERROR_LINE, "XMLParser::ParseBufferFinal");
		SetParseErrorDetail();
		return FALSE;
	}
	else
		return TRUE;
}



void XMLParser::GetResults(XMLObject * * apResults)
{
	// TODO: always clear the stack
	if (apResults)
	{
		*apResults = NULL;
		// There should just be one aggregate on the stack now containing the
		// document.  If there is more, then there must have been an unclosed
		// tag.
		// if the tag is not an aggregate, then there must have been data that
		// wasn't enclosed in tags.
		XMLObject * obj = Pop();

		// The next thing must be either nothing or an XML entity reference for the DTD.
		// This probably needs better support is we want to support general entities
		XMLObject * next = Pop();
		if(next) {
			if(next->GetType() == XMLObject::ENTITY) {
				mDtd = (XMLEntity*)next;
			}
			else {
				delete next;
				SetError(ERROR_GEN_FAILURE, ERROR_MODULE, ERROR_LINE, "XMLParser::GetResults");
				return;									// TODO: what error should be returned?
			}
		}

		*apResults = obj;

		if (!*apResults)
			// TODO: real error number
			SetError(ERROR_GEN_FAILURE, ERROR_MODULE, ERROR_LINE, "XMLParser::GetResults");

		return;
	}
}


XMLOpeningTag * XMLParser::OpeningTagWithName(XMLObject * apObj, const char * apName)
{
	if (apObj && apObj->GetType() == XMLObject::OPENING_TAG)
	{
		XMLOpeningTag * tag = (XMLOpeningTag *) apObj;
		if (0 == strcmp(tag->GetName(), apName))
			return tag;
	}
	return NULL;
}


int XMLParser::HandleEndElement(const char * apName)
{
	// NOTE: this method is called quite often during parsing so it's
	// important to keep it as quick as possible.  Avoid using memory structures
	// unless required.

	// keep popping objects off the stack until we find the matching
	// opening tag.  Create an aggregate out of that, and also retrieve the
	// attributes.

	// NOTE: sizing this at 5 initially is a heuristic that works well for
	// XML that contains lots of tag pairs with very little inside them.
	// for instance:
	//  <open>one thing</open>
  //  <open2>another thing</open2>
	//
	// TODO: since a single element within tag pairs is so common, we could optimize
	// for this and avoid the vector entirely.  XMLAggregate could also be optimized
	// for this and store a single pointer instead of a vector of pointers.

	XMLObject * obj1 = Pop();
	if (!obj1)
	{
		ASSERT(0);
		return 0;										// stack underflow
	}

	if (mMD5Flag == TRUE)
	{
		MT_MD5_Update(&mMD5Context,
			// casting hell!
			reinterpret_cast<unsigned char*>(const_cast<char*>(apName)),
			strlen(apName));
	}

	XMLOpeningTag * open;
	open = OpeningTagWithName(obj1, apName);
	if (open)
	{
		//
		// simplest case - opening and closing tag are right next to each
		// other with nothing inbetween
		//
		OneElementXMLObjectVector single;
		// nothing inside
		single.SetObject(NULL);

		XMLObject * agg = CreateAggregate(apName, open->GetAttributes(), single);

		// NOTE: anything left in contents is deleted.
		single.DeleteAll();

		// the opening tag is no longer used now
		delete open;

		if (!agg)
			return 0;										// return false on semantic error

		// push the aggregate back on the stack
		Push(agg);

		return 1;
	}

	XMLObject * obj2 = Pop();
	if (!obj2)
	{
		ASSERT(0);
		return 0;										// stack underflow
	}

	open = OpeningTagWithName(obj2, apName);
	if (open)
	{
		//
		// another simple case - opening and closing tag with only one element in between.
		//
		OneElementXMLObjectVector single;
		// one thing inside
		single.SetObject(obj1);


		XMLObject * agg = CreateAggregate(apName, open->GetAttributes(), single);

		// NOTE: anything left in contents is deleted.
		single.DeleteAll();

		// the opening tag is no longer used now
		delete open;

		if (!agg)
			return 0;										// return false on semantic error

		// push the aggregate back on the stack
		Push(agg);

		return 1;
	}


	//
	// otherwise we have more than one elements between the tags
	//
	MultiElementXMLObjectVector contents;
	// have to start with the two that were already pulled off
	contents.Append(obj1);
	contents.Append(obj2);

	while (TRUE)
	{
		XMLObject * obj = Pop();
		if (!obj)
		{
			ASSERT(0);
			break;										// stack underflow
		}

		open = OpeningTagWithName(obj, apName);
		if (open)
			break;

		// not the tag - add it to the contents list
		contents.Append(obj);
	}

	// now reverse the order of the vector before passing it to CreateAggregate
	// TODO: can this be done more efficiently?
	int contentsSize = contents.GetEntries();
	for (int i = 0; i < contentsSize / 2; i++)
	{
		XMLObject * temp = contents[i];
		contents[i] = contents[contentsSize - i - 1];
		contents[contentsSize - i - 1] = temp;
	}


	XMLObject * agg = CreateAggregate(apName, open->GetAttributes(), contents);

	// NOTE: anything left in contents is deleted.
	contents.DeleteAll();

	// the opening tag is no longer used now
	delete open;

	if (!agg)
		return 0;										// return false on semantic error

	// push the aggregate back on the stack
	Push(agg);

	return 1;
}


int XMLParser::HandleCharacterData(const char * apStr, int aLen)
{
	// we call CreateData before doing conversion to Unicode in case the
	// user wants to ignore the data or do something differently with it.
	XMLObject * data = CreateData(apStr, aLen);
	// allow CreateData to return NULL.  In this case the user
	// means the data should be ignored.
	if (data)
	{
		Push(data);

		if (mMD5Flag == TRUE)
		{
			MT_MD5_Update(&mMD5Context, (unsigned char*)const_cast<char*>(apStr), aLen);
		}
	}


	return 1;
}

int XMLParser::HandleProcessingInstruction(const char * apTarget,
																						const char * apData)
{
	int dataLen;
	XMLString target;
	XMLString data;

	// TODO: check return
	(void) Utf8ToXMLString(target, apTarget);
	(void) Utf8ToXMLString(data, apData);
	XMLObject * instr = CreateInstruction(target, data);
	// allow CreateInstruction to return NULL.  In this case the
	// user means the instruction should be ignored.
	if (instr)
		Push(instr);

	if (mMD5Flag == TRUE)
	{
		if (0 == strcmp(apTarget, CHECKSUM_NAME))
		{
			dataLen = strlen(apData);
			if (dataLen != 0)
			{
				memcpy(mFileChecksum, apData, dataLen < sizeof(mFileChecksum)? dataLen : sizeof(mFileChecksum));
			}
		}
	}

	return 1;
}

int XMLParser::HandleExternalEntityRefHandler( const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId)
{
	// XXX  If the default HandleExternalEntityRefHandler is called 
	// the parsing will probably fail because we expect only one node 
	// at the top level of the document.

	XMLObject* pEntity = CreateEntity(context,base,systemId,publicId);
	if(pEntity) Push(pEntity);
	return 1;
}

XMLObject * XMLParser::Pop()
{
	if (mObStack.empty())
		return NULL;

	// remove and return the top element
	XMLObject * top = mObStack.top();
	mObStack.pop();
	return top;
}

void XMLParser::SetParseErrorDetail()
{
	int code, line, col;
	long byt;
	const char * message;

	GetErrorInfo(code, message, line, col, byt);
	if (code == XML_ERROR_SEMANTIC_ERROR)
	{
		// semantic errors are generated from the object factory,
		// so pass that back directly..
		if (mpFactory)
		{
			const ErrorObject * err = mpFactory->GetLastError();
			if (err)
			{
				SetError(err);
				return;
			}
			else
			{
				SetError(ERROR_GEN_FAILURE, ERROR_MODULE, ERROR_LINE, "XMLParser::SetParseErrorDetail",
								 "No detailed message provided");
				return;
			}
		}
	}

	ASSERT(mpLastError);
	string & detail = mpLastError->GetProgrammerDetail();
	detail = message;
	// TODO: not ANSI
	char buffer[20];
  sprintf(buffer, "%d", code);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", code=";
	detail += buffer;

  sprintf(buffer, "%d", line);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", line=";
	detail += buffer;

  sprintf(buffer, "%d", col);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", col=";
	detail += buffer;

  sprintf(buffer, "%ld", byt);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", byte=";
	detail += buffer;
}


/************************************************** XMLOpeningTag ***/

#ifdef WIN32

static ObjectPool<XMLOpeningTag, 1000> gXMLOpeningTagObjectPool;

void* XMLOpeningTag::operator new(unsigned int nSize)
{
	ASSERT(nSize == sizeof(XMLOpeningTag));
	// allocate from the pool
	XMLOpeningTag * obj = gXMLOpeningTagObjectPool.CreateElement();

	if (!obj)
	{
		// pool is full - allocate from global heap
		obj = (XMLOpeningTag *) ::operator new(nSize);
		ASSERT(obj);
	}

	return obj;
}

void XMLOpeningTag::operator delete(void* apObj)
{
	XMLOpeningTag * obj = (XMLOpeningTag *) apObj;

	if (!gXMLOpeningTagObjectPool.DeleteElement(obj))
	{
		// release from global heap
		::operator delete(obj);
	}
}

#endif

XMLOpeningTag::XMLOpeningTag()
	: mpAttributes(NULL)
{

}

XMLOpeningTag::XMLOpeningTag(const char * apName)
	: mpAttributes(NULL)
		//mpName(NULL)
		//mStorageType(UNDEFINED_STORAGE)
	//: mAttributes(wstring::hash)
{
	SetName(apName);
}

XMLOpeningTag::~XMLOpeningTag()
{
	ClearAttributes();
}

void XMLOpeningTag::ClearAttributes()
{
	//mpAttributes.Release();
}

void XMLOpeningTag::SetName(const char * apName)
{
	// NOTE: parsing involves the creation/destruction of a lot of these
	// objects, so we manage the string ourself to make it faster

	mName.SetBuffer(apName);
}

void XMLOpeningTag::Output(XMLWriter & arWriter) const
{
	arWriter.OutputOpeningTag(GetName(), GetAttributes());
}

void XMLOpeningTag::SetAttributes(const char * * apAtts)
{
	// only allocate memory if we need to
	if (apAtts && *apAtts)
	{
		mpAttributes = new XMLNameValueMapDictionary;

		while (*apAtts)
		{
			// they come in pairs
			const char * name = *apAtts++;
			const char * value = *apAtts++;

			XMLString xmlName;
			XMLString xmlValue;

			Utf8ToXMLString(xmlName, name);
			Utf8ToXMLString(xmlValue, value);

			(*mpAttributes)[xmlName] = xmlValue;
		}
	}
	else
		ClearAttributes();
}

void XMLOpeningTag::SetAttributes(XMLNameValueMap& apAttributes)
{
	mpAttributes = apAttributes;
}

/*************************************************** XMLAggregate ***/

void XMLAggregate::Output(XMLWriter & writer) const
{
	// put the opening tag to begin with
	XMLOpeningTag::Output(writer);

	const XMLObjectVector & contents = GetVector();
	// now put the contents
	for (int i = 0; i < (int) contents.GetEntries(); i++)
	{
		XMLObject * obj = contents[i];

		// TODO: do we need to worry about indentation levels?

		// allow the element to put itself
		obj->Output(writer);
	}

	// put the closing tag
	//writer.mStream << "</" << GetName() << '>';
	writer.OutputClosingTag(GetName());
}


// @mfunc helper - cast object to an aggregate if name matches
// @parm object to test
// @parm name to compare to
// @parm optional alternate name to compare to
// @rdesc aggregate if the name matches or NULL if not
XMLAggregate * XMLAggregate::Named(
	XMLObject * apObj, const char * apName, const char * apNameAlt /* = NULL */)
{
	if (!apObj->GetType() == AGGREGATE)
		return NULL;
	XMLAggregate * agg = (XMLAggregate *) apObj;
	if (0 == strcmp(agg->GetName(), apName))
		return agg;
	if (apNameAlt && 0 == strcmp(agg->GetName(), apNameAlt))
		return agg;
	return NULL;
}

// @mfunc helper - return data contents of an aggregate if there's nothing else in it
// @parm name to compare to
// @rdesc TRUE if aggregate held only data
BOOL XMLAggregate::GetDataContents(XMLString & arString)
{
	return GetDataContents(arString, GetVector());
}

BOOL XMLAggregate::GetDataContents(XMLString & arString,
																	 const XMLObjectVector & arContents)
{
	BOOL firstCopy = TRUE;

	// HACK: cast away const
	for (int i = 0; i < arContents.GetEntries(); i++)
	{
		XMLObject * obj = arContents[i];
		XMLData * data = XMLData::Data(obj);

		if (!data)
			return FALSE;
		// copying of strings can be done efficiently,
		// so in the common case where the aggregate only holds a
		// single XMLData element, do a copy.
		// If it contains more data, do the more expensive concatenation
		if (firstCopy)
		{
			firstCopy = FALSE;
			arString = data->GetData();
		}
		else
			arString += data->GetData();
	}
	return TRUE;
}



/*************************************************** XMLData ***/

#ifdef WIN32

static ObjectPool<XMLData, 1000> gXMLDataObjectPool;

void* XMLData::operator new(unsigned int nSize)
{
	ASSERT(nSize == sizeof(XMLData));
	// allocate from the pool
	XMLData * obj = gXMLDataObjectPool.CreateElement();

	if (!obj)
	{
		// pool is full - allocate from global heap
		obj = (XMLData *) ::operator new(nSize);
		ASSERT(obj);
	}

	return obj;
}

void XMLData::operator delete(void* apObj)
{

	XMLData * obj = (XMLData *) apObj;

	if (!gXMLDataObjectPool.DeleteElement(obj))
	{
		// release from global heap
		::operator delete(obj);
	}
}

#endif

void XMLData::Output(XMLWriter & arWriter) const
{
	arWriter.OutputCharacterData(GetData());
}


// @cmember cast object to data type if possible
// @parm object to test.
// @rdesc data, or NULL if not a data object
XMLData * XMLData::Data(XMLObject * apObject)
{
	if (apObject->GetType() == DATA)
		return (XMLData *) apObject;
	return NULL;
}


XMLData::XMLData()
{ }


XMLData::XMLData(wchar_t aSingleChar)
{
	wchar_t * buffer = mData.DirectSetup();
	buffer[0] = aSingleChar;
	buffer[1] = '\0';
}


XMLData::XMLData(const char * apUtf8, int aLen,BOOL bCdataSection)
{
	// estimate the length of the data.  even if every byte of data were to turn
	// into two, that would only double the length
	int estimate = aLen * 2 + 10;
	BOOL direct = (estimate < mData.BufferSize());

	wchar_t * buffer;

#ifdef WIN32

	if (direct)
		buffer = mData.DirectSetup();
	else
		buffer = new wchar_t[estimate];
			
#if 0
	// TODO: do we need this call?
	int len = MultiByteToWideChar(
							CP_UTF8,										// code page
							0,													// character-type options
							apUtf8,											// address of string to map
							aLen,												// number of bytes in string
							NULL,												// address of wide-character buffer
							0);													// size of buffer


	int retval = MultiByteToWideChar(
							CP_UTF8,									// code page
							0,												// character-type options
							apUtf8,										// address of string to map
							aLen,									// number of bytes in string
							buffer,										// address of wide-character buffer
							len);								// size of buffer
#endif
	int len = MultiByteToWideChar(
							CP_UTF8,									// code page
							0,												// character-type options
							apUtf8,										// address of string to map
							aLen,									// number of bytes in string
							buffer,										// address of wide-character buffer
							estimate);								// size of buffer


	if(bCdataSection && apUtf8[aLen - 1] == '\n')
	{
		buffer[len] = L'\n';	
		buffer[len+1] = L'\0';	
	}
	else 
	{
		buffer[len] = L'\0';
	}

#if 0

	int retval = MultiByteToWideChar(
		CP_UTF8,									// code page
		0,												// character-type options
		apUtf8,										// address of string to map
		estimate,									// number of bytes in string
		buffer,										// address of wide-character buffer
		estimate);								// size of buffer

	if(bCdataSection && apUtf8[aLen] == '\n')
	{
		buffer[aLen] = L'\n';	
		buffer[aLen+1] = L'\0';	
	}
	else 
	{
		buffer[aLen] = L'\0';
	}
#endif

	if (!direct)
	{
		mData.Attach(buffer);
	}

#else

	if (aLen <= 0) {
		aLen = strlen(apUtf8);
	}

	buffer = new wchar_t[aLen + 1];
  int len = mbstowcs(buffer, apUtf8, aLen);
  
	if(bCdataSection && apUtf8[aLen] == '\n') {
		buffer[len] = L'\n';	
		buffer[len+1] = L'\0';	
	}
	else {
		buffer[len] = L'\0';
	}
	
	mData.Attach(buffer);

#endif

}

/******************************************** XMLInstruction ***/

void XMLInstruction::Output(XMLWriter & arWriter) const
{
	arWriter.OutputInstruction(ascii(GetTarget()).c_str(), ascii(GetData()).c_str());
}

/************************************************* XMLEntity ***/

void XMLEntity::Output(XMLWriter &aWriter) const
{
	aWriter.OutputEntity(mType == DOC_DOCTYPE ? "DOCTYPE" : "ENTITY",
											 ascii(mTopLevelSetName).c_str(),
											 mType == ACCESS_PUBLIC ? "PUBLIC" : "SYSTEM",
											 ascii(mEntityLocation).c_str());
}

void XMLEntity::PutLocation(const char* pLocation)
{
	ASCIIToWide(mEntityLocation, pLocation, strlen(pLocation));
}

void XMLEntity::PutSetName(const char* aStr)
{
	ASCIIToWide(mTopLevelSetName, aStr, strlen(aStr));
}


/****************************************** XMLObjectFactory ***/

// start IDs at 1 so that objects returning 0 will be detected.
int XMLObjectFactory::msNextId = 1;

XMLObjectFactory::XMLObjectFactory()
{ }

XMLObjectFactory::~XMLObjectFactory()
{ }

// @mfunc Generate an ID used to identity an XMLUserObject subtype
//  @rdesc ID that should be returned by XMLUserObject::GetTypeId()
int XMLObjectFactory::GetUserObjectId()
{
	// NOTE: this is not threadsafe!
	return msNextId++;
}


XMLObject * XMLObjectFactory::CreateOpeningTag(
	const char * apName,
	const char * * apAttributes)
{
	XMLOpeningTag * tag = new XMLOpeningTag(apName);
	if (apAttributes && *apAttributes)
		tag->SetAttributes(apAttributes);

	return tag;
}


#if 0
#ifdef WIN32

static ObjectPool<XMLAggregateT<OneElementXMLObjectVector>, 1000>
 gOneElementAggregateObjectPool;


XMLAggregateT<OneElementXMLObjectVector> * AllocateOneElementAggregate()
{
	// allocate from the pool
	XMLAggregateT<OneElementXMLObjectVector> * obj =
		gOneElementAggregateObjectPool.CreateElement();

	if (!obj)
	{
		// pool is full - allocate from global heap
		obj = (XMLData *) ::operator new(nSize);
		ASSERT(obj);
	}

	// explicitly call the constructor
	// TODO: do this?
//	obj->Temp::Temp();

	return obj;

}

void* XMLData::operator new(unsigned int nSize)
{
	ASSERT(nSize == sizeof(XMLData));
	// allocate from the pool
	XMLData * obj = gXMLDataObjectPool.CreateElement();

	if (!obj)
	{
		// pool is full - allocate from global heap
		obj = (XMLData *) ::operator new(nSize);
		ASSERT(obj);
	}

	// explicitly call the constructor
	// TODO: do this?
//	obj->Temp::Temp();

	return obj;
}


void XMLData::operator delete(void* apObj)
{
	XMLData * obj = (XMLData *) apObj;

	// explicitly call the destructor
	// TODO: do this?
//	obj->Temp::~Temp();

	if (!gXMLDataObjectPool.DeleteElement(obj))
	{
		// release from global heap
		::operator delete(obj);
	}
}

#endif // WIN32

#endif



XMLObject * XMLObjectFactory::CreateAggregate(
		const char * apName,
		XMLNameValueMap& apAttributes,
		XMLObjectVector & arContents)
{
	XMLAggregate * agg = NULL;

	// we simulate rtti here and cast the vector to the appropriate subclass
	switch (arContents.GetVectorType())
	{
	case XMLObjectVector::ONE_ELEMENT:
		agg = new XMLAggregateT<OneElementXMLObjectVector>
			(apName, (OneElementXMLObjectVector &) arContents);
		break;
	case XMLObjectVector::MULTI_ELEMENT:
		agg = new XMLAggregateT<MultiElementXMLObjectVector>
			(apName, (MultiElementXMLObjectVector &) arContents);
		break;
	default:
		ASSERT(0);
		return NULL;
	}

	// TODO: will this copy work
	agg->SetAttributes(apAttributes);

	// this copy is a shallow copy.  Remove the elements from arContents
	// so that they won't be deleted after this method returns

	arContents.RemoveAll();

	return agg;
}


void MultiElementXMLObjectVector::Remove(int aIndex)
{
	  vector<XMLObject*>::iterator iter;
	  int i;

	  for (iter = mObjects.begin(), i=0; i < aIndex; iter++, i++)
			;

	  ASSERT(i == aIndex);

	  mObjects.erase(iter);
	  //		mObjects.erase(*(&mObjects[aIndex]));
}


XMLObject * XMLObjectFactory::CreateData(const char * apData, int aLen,BOOL bCdataSection)
{
	// NOTE: it is very important that this function is as fast as possible

	// convert to Unicode and create a data object with it

	// simple newlines are a common case - not worth calling
	//  Utf8ToXMLString for these
	if (apData[0] == '\n')
	{
		//static XMLString newline(L"\n");
		return new XMLData('\n');
	}
	else
	{
		return new XMLData(apData, aLen,bCdataSection);
	}
}

XMLObject * XMLObjectFactory::CreateInstruction(
	const XMLString & arTarget, const XMLString & arData)
{
	//return new XMLInstruction(arTarget, arData);
	return NULL;
}

XMLObject* XMLObjectFactory::CreateEntity(const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId)
{
	return NULL;
}
