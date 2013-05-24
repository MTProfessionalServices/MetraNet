/**************************************************************************
 * @doc XMLPARSER
 *
 * @module XML Parser Interface |
 *
 * This set of classes acts as a wrapper to the xmltok library.
 * It parses XML to a generic tree structure.  It also allows
 * these structures to be written.
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
 *
 * @index | XMLPARSER
 ***************************************************************************/

#ifndef _XMLPARSER_H
#define _XMLPARSER_H

// header for C library
#include <xmlparse.h>

#include <errobj.h>

#include <map>
#include <vector>
#include <stack>
#include <algorithm>

#include <global.h>
#include <mtmd5.h>

#include <autoptr.h>
#include <fastbuffer.h>
#include <BufferWriter.h>
#include <stdutils.h>

#ifdef UNIX
#ifndef ERROR_GEN_FAILUER
#define ERROR_GEN_FAILURE -1
#endif

#endif

#undef MAX_BUFFER_SIZE	// make sure the right definition is used
#define MAX_BUFFER_SIZE		1024
#define CHECKSUM_NAME			"Metratech-Checksum"
#define INSTRUCTION_START	"<?"
#define SPACE							" "
#define	INSTRUCTION_END		"?>"

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
#endif // WIN32


/*
 * class forward refs
 */
class XMLEntity;
class XMLObject;

using std::map; using std::vector;
using std::copy; using std::stack;
using std::for_each;


// explicit instantiation of functions
#ifdef _WIN32
template void destroyPtr(XMLObject *);
#endif

/*
 * NOTE: The choice of Unicode vs. ASCII is very important for this module.
 * Here is the difference:
 *  TODO: this isn't correct yet.
 *   UNICODE: All strings are stored as Unicode internally.  UTF-8 is converted
 *     to Unicode.
 *   ASCII: All strings are stored as ASCII internally.  UTF-8 is verified to
 *     contain only ASCII characters.
 * All strings within the objects are XMLStrings.
 */

/*
 * this class is (should be) threadsafe.
 * You must create a new XMLParser for each thread.
 */

typedef wstring XMLString;

// convert UTF8 to a wstring
// TODO: every function that calls this must check the return.
//       this function could also throw an exception
int Utf8ToXMLString(XMLString & arWstring, const char * apUtf8,
										int aLen = -1);

int XMLStringToUtf8(string & arString,
										const XMLString & arXmlString);

int XMLStringToAscii(string & arString,
										 const XMLString & arXmlString);


// both routines escape any special XML characters if there are any,
// or return FALSE if there aren't
BOOL EscapeXMLChars(wstring & arEscapedString,
										const wchar_t * apXmlString,
										BOOL isAttributeValue);

BOOL EscapeXMLChars(string & arEscapedString,
										const char * apXmlString,
										BOOL isAttributeValue);


typedef map<XMLString, XMLString> XMLNameValueMapDictionary;

typedef MTautoptr< XMLNameValueMapDictionary > XMLNameValueMap;
typedef MTautoptr<XMLEntity> AutoDTD;

/* @class
 *
 * Collection of helper functions to write XML data
 */
class XMLWriter
{
public:
	XMLWriter() : mTabCount(0), mEndFlag(FALSE)
	{ }

	~XMLWriter()
	{ }

	void SetPrettyPrint(BOOL aPrettyPrint)
	{ mBuffer.SetPrettyPrint(aPrettyPrint); }

	void GetData(const char * * apBuffer, int & arLength) const
	{ mBuffer.GetData(apBuffer, arLength); }

	// @cmember Print an opening tag
	void OutputOpeningTag(const char * apName);

	// @cmember Print an opening tag that has attributes
	void OutputOpeningTag(const char * apName,
																const XMLNameValueMap& arAttributes);

	// @cmember Print a closing tag.
	void OutputClosingTag(const char * apName);

	// @cmember output encoded data <?instruction data?>
	void OutputInstruction(const char * apTarget, const char* apData);

	// @cmember output an entity reference
	void OutputEntity(const char* pType,const char* pSetName,const char* pAccessType,const char* pData);
	
	// @cmember output the Standard XML header
	void OutputStandardHeader();

public:
	//
	// helper functions
	//

	// @cmember output <tag>data</tag>, a common case
	void OutputSimpleAggregate(const char * apTagName, const XMLString & arData);

	// @cmember output <tag>data</tag>, a common case
	void OutputSimpleAggregate(const char * apTagName, const char * apData);

	// @cmember helper - output encoded data
	void OutputCharacterData(const XMLString & arString);

	// @cmember helper - output encoded data
	void OutputCharacterData(const XMLString & arString, char * apWorkArea, int workAreaSize);

	// @cmember helper - output encoded data
	void OutputCharacterData(const char * apString);

	// @cmember helper - output encoded data
	void OutputCharacterData(const wchar_t * apString);

	// @cmember output the given characters
	void OutputAttributeValue(const XMLString & arString);

public:
	// @cmember output the given number of spaces.
	void OutputSpaces(int aSpaceCount);

	// @cmember output the given characters
	void OutputRawCharacters(const char * apStr);

	// @cmember output the given characters
	void OutputRawCharacters(const char * apStr, int aLen);

	// @cmember output the given characters
	void OutputRawCharacters(const string & apStr);

private:
	void IncreaseTabCount();
	void DecreaseTabCount();
	void OutputLeadingTabs();
	void SetEndFlag(BOOL aFlag);
	BOOL GetEndFlag() const;

private:
	long	mTabCount;
	BOOL	mEndFlag;

private:
	MTMemBuffer mBuffer;
};


/****************************************************** XMLWriter ***/

inline void XMLWriter::IncreaseTabCount()
{
	mTabCount++;
}

inline void XMLWriter::DecreaseTabCount()
{
	mTabCount--;
}

inline void XMLWriter::OutputLeadingTabs()
{
	OutputSpaces(mTabCount * 2);
}

inline void XMLWriter::SetEndFlag(BOOL aFlag)
{
	mEndFlag = aFlag;
}

inline BOOL XMLWriter::GetEndFlag() const
{
	return mEndFlag;
}

// @cmember output <tag>data</tag>, a common case
inline void XMLWriter::OutputSimpleAggregate(const char * apTagName,
																								const XMLString & arData)
{
	OutputOpeningTag(apTagName);
	OutputCharacterData(arData);
	OutputClosingTag(apTagName);
}

// @cmember output <tag>data</tag>, a common case
inline void XMLWriter::OutputSimpleAggregate(const char * apTagName,
																			const char * apData)
{
	OutputOpeningTag(apTagName);
	OutputCharacterData(apData);
	OutputClosingTag(apTagName);
}

inline void XMLWriter::OutputCharacterData(const char * apString)
{
	string utf8;
	string escaped;

	if (EscapeXMLChars(escaped, apString, FALSE))
		OutputRawCharacters(escaped);
	else
		OutputRawCharacters(apString);
}

inline void XMLWriter::OutputCharacterData(const wchar_t * apString)
{
	string utf8;

	XMLString escaped;
	if (EscapeXMLChars(escaped, apString, FALSE))
		XMLStringToUtf8(utf8, escaped);
	else
		XMLStringToUtf8(utf8, apString);

	OutputRawCharacters(utf8);

}

inline void XMLWriter::OutputCharacterData(const XMLString & arString)
{
	string utf8;

	XMLString escaped;
	if (EscapeXMLChars(escaped, arString.c_str(), FALSE))
		XMLStringToUtf8(utf8, escaped);
	else
		XMLStringToUtf8(utf8, arString);

	OutputRawCharacters(utf8);
}

inline void XMLWriter::OutputCharacterData(const XMLString & arString,
																							char * apWorkArea, int workAreaSize)
{
	XMLString escaped;
	const XMLString * outputString;
	if (EscapeXMLChars(escaped, arString.c_str(), FALSE))
		outputString = &escaped;
	else
		outputString = &arString;

	// attempt to do the conversion into the work area.
	// if this succeeds, output the characters.  Otherwise the work
	// area is too small so allocate enough bytes for it

#ifdef WIN32
	int len;
	len = WideCharToMultiByte(
		CP_UTF8,										// code page
		0,													// performance and mapping flags
		outputString->c_str(),						// wide-character string
		outputString->length(),					// number of chars in string
		apWorkArea,									// buffer for new string
		workAreaSize,								// size of buffer
		NULL,												// default for unmappable chars
		NULL);											// set when default char used

	if (len != 0)
	{
		// conversion succeeded
		OutputRawCharacters(apWorkArea, len);
	}
	else
#endif
	{
		OutputCharacterData(*outputString);
	}
}


inline void XMLWriter::OutputAttributeValue(const XMLString & arString)
{
	string utf8;

	XMLString escaped;
	if (EscapeXMLChars(escaped, arString.c_str(), TRUE))
		XMLStringToUtf8(utf8, escaped);
	else
		XMLStringToUtf8(utf8, arString);

	OutputRawCharacters(utf8);
}

inline void XMLWriter::OutputRawCharacters(const char * apStr)
{
	mBuffer.append(apStr);
}

inline void XMLWriter::OutputRawCharacters(const char * apStr, int aLen)
{
	mBuffer.append(apStr, aLen);
}

inline void XMLWriter::OutputRawCharacters(const string & arStr)
{
	mBuffer.append(arStr.c_str());
}

inline void XMLWriter::OutputOpeningTag(const char * apName)
{
	mBuffer.AppendNewLine();
	//mStream << endl;
	OutputLeadingTabs();
	IncreaseTabCount();

	mBuffer.append('<');
	mBuffer.append(apName);
	mBuffer.append('>');

  //mStream << '<' << apName << '>';

	SetEndFlag(FALSE);
}

// @cmember output encoded data <?instruction data?>
inline void XMLWriter::OutputInstruction(const char * apTarget, const char * apData)
{
	mBuffer.append("<?");
	mBuffer.append(apTarget);
	mBuffer.append(' ');
	mBuffer.append(apData);
	mBuffer.append("?>");
	mBuffer.AppendNewLine();

}

inline void XMLWriter::OutputOpeningTag(const char * apName,
																		const XMLNameValueMap& apAttributes)
{
	mBuffer.AppendNewLine();

	//mStream << endl;

	OutputLeadingTabs();
	IncreaseTabCount();

	mBuffer.append('<');
	mBuffer.append(apName);
  //mStream << '<' << apName;

	if ((&apAttributes))
	{
		// TODO: make sure this outputs attributes in the correct order
		XMLNameValueMapDictionary::const_iterator it;
		for (it = apAttributes->begin(); it != apAttributes->end(); it++)
		{
			const XMLString & name = it->first;
			const XMLString & value = it->second;

			mBuffer.append(' ');

			mBuffer.append(ascii(name).c_str());
			mBuffer.append("=\"");
			// treat the attributes like other character data
			OutputCharacterData(value);

			mBuffer.append('"');
		}
	}

	mBuffer.append('>');

	SetEndFlag(FALSE);
}

inline void XMLWriter::OutputClosingTag(const char * apName)
{
	DecreaseTabCount();

	if (GetEndFlag())
	{
		mBuffer.AppendNewLine();
		//mStream << endl;
		OutputLeadingTabs();
	}

	mBuffer.append("</");
	mBuffer.append(apName);
	mBuffer.append('>');

  //mStream << "</" << apName << '>';

	// NOTE: in strict XML this wouldn't be done.  I do it because it's
	// much easier to read the output for our purposes
	//mStream << endl;

	SetEndFlag(TRUE);
}

inline void XMLWriter::OutputSpaces(int aSpaceCount)
{
	mBuffer.OutputSpaces(aSpaceCount);
}

inline void XMLWriter::OutputEntity(const char* pType,
																		const char* pSetName,
																		const char* pAccessType,
																		const char* pData)
{
	// Should like like 
	// <!DOCTYPE xmlconfig SYSTEM "http://localhost/validation/listener.dtd">
	//
	// XXX This probably doesn't work for general purpose entities

	mBuffer.append("<!");
	mBuffer.append(pType);
	mBuffer.append(' ');
	mBuffer.append(pSetName);
	mBuffer.append(' ');
	mBuffer.append(pAccessType);
	mBuffer.append(' ');
	mBuffer.append('\"');
	mBuffer.append(pData);
	mBuffer.append('\"');
	mBuffer.append('>');

}

inline void XMLWriter::OutputStandardHeader()
{
	const char* pStandardHeader ="<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
	mBuffer.append(pStandardHeader);
	mBuffer.AppendNewLine();
}


/* @class
 *
 * Base class for the objects that make up an
 * XML document structure tree.
 */


class XMLObject
{
// @access Public:
public:
	virtual ~XMLObject()
	{ }


	// @cmember,menum Type of this object.
	// allow these objects to be placed in heterogeneous lists
	enum Type
	{
		OPENING_TAG,								// @@emem an opening tag
		AGGREGATE,									// @@emem an opening/closing tag combo
		INSTRUCTION,								// @@emem an instruction tag
		DATA,												// @@emem data
		USER,												// @@emem user defined data type (created by factory)
		ENTITY											// @@emem entity
	};

	// @cmember,mfunc Return the type of this object
	//  @@rdesc A valid Type enumeration constant
	virtual Type GetType() const = 0;

	// @cmember,mfunc allow the object to be put to a stream
	//  @@parm xml writer
	virtual void Output(XMLWriter & arWriter) const = 0;

	// NOTE: this function is only to enable these objects to be
	// placed into a vector.
	BOOL operator == (const XMLObject & /* arObj */) const
	{ ASSERT(0); return FALSE; }

// @access Private:
private:

};

class XMLObjectVector
{
public:
	virtual ~XMLObjectVector()
	{ }

	virtual int GetEntries() const = 0;

	virtual XMLObject * const & operator[](int aIndex) const = 0;
	virtual XMLObject * & operator[](int aIndex) = 0;

	virtual void Remove(int arIndex) = 0;

	virtual void DeleteAll() = 0;
	virtual void RemoveAll() = 0;

	enum VectorType
	{
		UNKNOWN = 0,
		ONE_ELEMENT,
		MULTI_ELEMENT
	};

	// simulated rtti
	virtual VectorType GetVectorType() const = 0;
};

// "vector" optimized for a single element
class OneElementXMLObjectVector : public XMLObjectVector
{
public:
	OneElementXMLObjectVector(OneElementXMLObjectVector & arOther) : mpObj(NULL)
	{
		if (arOther.GetEntries() > 0)
			mpObj = arOther[0];
	}

	OneElementXMLObjectVector() : mpObj(NULL)
	{ }

	// TODO: should this delete the element?
	virtual ~OneElementXMLObjectVector()
	{ }

	// simulated rtti
	virtual VectorType GetVectorType() const
	{ return ONE_ELEMENT; }

	virtual int GetEntries() const
	{ return mpObj ? 1 : 0; }

	virtual XMLObject * const & operator[](int aIndex) const
	{
		ASSERT(aIndex == 0);
		if (aIndex != 0)
		{
			// must return an lvalue
			ASSERT(mpObj == NULL);
			return mpObj;
		}

		return mpObj;
	}

	virtual XMLObject * & operator[](int aIndex)
	{
		ASSERT(aIndex == 0);
		if (aIndex != 0)
		{
			// must return an lvalue
			ASSERT(mpObj == NULL);
			return mpObj;
		}

		return mpObj;
	}

	virtual void Remove(int aIndex)
	{
		ASSERT(aIndex == 0);

		DeleteAll();
	}

	virtual void DeleteAll()
	{
		delete mpObj;
		mpObj = NULL;
	}

	virtual void RemoveAll()
	{
		mpObj = NULL;
	}

public:
	void SetObject(XMLObject * apObject)
	{
		ASSERT(!mpObj);
		mpObj = apObject;
	}

private:
	XMLObject * mpObj;
};

// multiple elements
class MultiElementXMLObjectVector : public XMLObjectVector
{
public:
	MultiElementXMLObjectVector()
	{ }

	MultiElementXMLObjectVector(MultiElementXMLObjectVector & arOther)
	{
		mObjects = arOther.GetVector();
	}

	// simulated rtti
	virtual VectorType GetVectorType() const
	{ return MULTI_ELEMENT; }

	virtual int GetEntries() const
	{
		return mObjects.size();
	}

	virtual XMLObject * const & operator[](int aIndex) const
	{
		return mObjects[aIndex];
	}

	virtual XMLObject * & operator[](int aIndex)
	{
		return mObjects[aIndex];
	}

	virtual void Remove(int aIndex);

	virtual void DeleteAll()
	{
		//for_each(mObjects.begin(), mObjects.end(), destroyPtr<XMLObject>);
		for (unsigned long i = 0; i < mObjects.size(); i++)
		{
			XMLObject* xmlObject = mObjects[i];
			delete xmlObject;
		}

		mObjects.clear();
	}

	virtual void RemoveAll()
	{
		mObjects.clear();
	}

	// access to internal vector
	vector<XMLObject *> & GetVector()
	{ return mObjects; }

public:
	void Append(XMLObject * apObj)
	{
		mObjects.push_back(apObj);
	}

private:
	vector<XMLObject *> mObjects;
};



/********************************************************************/

/* @class
 *
 * Opening tag.  Has a name and attributes.
 */

class XMLOpeningTag : public XMLObject
{
// @access Public:
public:
	// need a default constructor to be pooled
	XMLOpeningTag();

	// @cmember,mfunc Constructor.
	//  @@parm Name of the tag.
	XMLOpeningTag(const char * apName);

	virtual ~XMLOpeningTag();

	// @cmember,mfunc Set the name of the tag
	//  @@parm Name of the tag.
	void SetName(const char * apName);

	// @cmember,mfunc Retrieve the name of the tag.
	//  @@rdesc Name of the tag
	const char * GetName() const
	{
		return mName.GetBuffer();
	}

	// @cmember,mfunc Return the type of this object.
	//  @@rdesc type - OPENING_TAG
	Type GetType() const
	{ return OPENING_TAG; }

	// @cmember,mfunc Return the name/value attribute list.
	//  @@rdesc name -> value map
	XMLNameValueMap GetAttributes() const
	{ return mpAttributes; }

	// @cmember,mfunc Set attribute list from NULL terminated
	// array.
	//  @@parm array passed from xmltok
	void SetAttributes(const char * * apAttributes);

	// @cmember,mfunc Set attribute list from an existing
	// attribute list.
	//  @@parm copy a name -> value map from another object
	void SetAttributes(XMLNameValueMap& arAttributes);

	void ClearAttributes();

	// @cmember,mfunc Print the object to a stream
	//  @@parm xml writer
	void Output(XMLWriter & arWriter) const; 

public:

#ifdef WIN32
	void * operator new(size_t aSize);
	void operator delete(void* apObj);
#endif

// @access Protected:
protected:

// @access Private:
private:

	FastBuffer<char, 32> mName;

	// @cmember keep a list of the attributes
	// NOTE: map is only created if necessary
	XMLNameValueMap  mpAttributes;
};

/* @class
 *
 * An opening tag, closing tag, and
 * everything inbetween.
 */

class XMLAggregate : public XMLOpeningTag
{
public:
	// @cmember Constructor.  Create the aggregate,
	// giving it a name.
	// private so that this class can't be constructed directly
	XMLAggregate(const char * apName) :
		XMLOpeningTag(apName)
	{ }

	// @cmember,mfunc Return the type of this object
	//  @@rdesc type - AGGREGATE
	Type GetType() const
	{ return AGGREGATE; }

	// @cmember,mfunc
	//  @@rdesc Return a reference to the contents
	virtual XMLObject *const * GetContents(int & arCount) const = 0;

	// @cmember,mfunc Print the object to a stream
	//  @@parm xml writer
	void Output(XMLWriter & arWriter) const;

	// @cmember helper - cast object to an aggregate if name matches
	static XMLAggregate * Named(XMLObject * apObj,
															const char * apName,
															const char * apNameAlt = NULL);

	// @cmember helper - return data contents of an aggregate if there's nothing else in it
	BOOL GetDataContents(XMLString & arString);

	// @cmember helper - return data contents of an aggregate if there's nothing else in it
	static BOOL GetDataContents(XMLString & arString, const XMLObjectVector & arContents);

protected:
	virtual XMLObjectVector & GetVector() = 0;
	virtual const XMLObjectVector & GetVector() const = 0;

public:
#ifdef WIN32
	void * operator new(size_t aSize)
	{ return ::operator new(aSize); }

	void operator delete(void* apObj)
	{ ::operator delete(apObj); }
#endif
};

template<class T>
class XMLAggregateT : public XMLAggregate
{
public:
	XMLAggregateT(const char * apName, T & arContents) :
		XMLAggregate(apName), mContents(arContents)
	{
	}

	~XMLAggregateT()
	{
		mContents.DeleteAll();
	}

	// @cmember,mfunc
	//  @@rdesc Return a reference to the contents
	virtual XMLObject *const * GetContents(int & arCount) const
	{
		arCount = mContents.GetEntries();
		if (arCount > 0)
			return &mContents[0];
		else
			return NULL;
	}

protected:
	virtual XMLObjectVector & GetVector()
	{
		return mContents;
	}

	virtual const XMLObjectVector & GetVector() const
	{
		return mContents;
	}

private:
	T mContents;
};


/* @class
 *
 * Character data from an XML document.
 */

class XMLData : public XMLObject
{
// @access Public:
public:
	// default constructor required to go into the object pool
	XMLData();

	XMLData(wchar_t aSingleChar);

	// @cmember Create a data object.
	XMLData(const XMLString & arData)
	{
		SetData(arData.c_str());
	}

	XMLData(const char * apUtf8, int aLen,BOOL bCdataSection);

	// @cmember,mfunc Return the type of the object
	//  @@rdesc type - DATA
	Type GetType() const
	{ return DATA; }

	// @cmember,mfunc Return a pointer to the data.
	//  @@rdesc Unicode data string
	const wchar_t * GetData() const
	{ return mData.GetBuffer(); }

	// @cmember,mfunc Set the data for the object.
	//  @@parm Unicode data string
	void SetData(const wchar_t * apData)
	{
		mData.SetBuffer(apData);
		//mData = arData;
	}

	// @cmember,mfunc Print the object to a stream
	//  @@parm xml writer
	void Output(XMLWriter & arWriter) const; 

	// @cmember cast object to data type if possible
	static XMLData * Data(XMLObject * apObject);

public:
#ifdef WIN32
	void * operator new(size_t aSize);
	void operator delete(void* apObj);
#endif

// @access Protected:
protected:

// @access Private:
private:
	FastBuffer<wchar_t, 64> mData;

	// @cmember The data
	//XMLString mData;
};


/* @class
 *
 * An XML instruction tag
 */

class XMLInstruction : public XMLObject
{
// @access Public:
public:
	// @cmember Create an XML instruction object.
	XMLInstruction(const XMLString & arTarget, const XMLString & arData)
	{
		SetTarget(arTarget);
		SetData(arData);
	}

	// @cmember,mfunc Return the type.
	//  @@rdesc type - INSTRUCTION
	Type GetType() const
	{ return INSTRUCTION; }

	// @cmember,mfunc Return the target
	//  @@rdesc Target string
	const XMLString & GetTarget() const
	{ return mTarget; }

	// @cmember,mfunc Set the target
	//  @@parm Target string
	void SetTarget(const XMLString & arTarget)
	{ mTarget = arTarget; }


	// @cmember,mfunc Return the data
	//  @@rdesc Data string
	const XMLString & GetData() const
	{ return mData; }

	// @cmember,mfunc Set the data
	//  @@parm Data string
	void SetData(const XMLString & arData)
	{
		mData = arData;
	}

	// @cmember,mfunc Print the object to a stream
	//  @@parm xml writer
	void Output(XMLWriter & arWriter) const; 

// @access Protected:
protected:

// @access Private:
private:
	// @cmember The target of the instruction
  XMLString mTarget;
	// @cmember The data of the instruction
	XMLString mData;
};

/* @class
 *
 * An XML entity object.  Basically support for capturing DTD info
 */


class XMLEntity : public XMLObject
{
public:

	// constructors
	XMLEntity(const XMLString& aStr)
		: mEntityLocation(aStr), mType(DOC_DOCTYPE),
			mMethod(ACCESS_SYSTEM), mTopLevelSetName(L"")
	{}

	//	XMLEntity(XMLString& aStr,DocType aType, AccessMethod aMethod)
	// virtual function implementation
	Type GetType() const { return ENTITY; }

	void Output(XMLWriter &) const;

	const XMLString& GetLocation()
	{ return mEntityLocation; }

	void PutLocation(const XMLString& aLocation)
	{ mEntityLocation = aLocation; }

	void PutLocation(const char* pLocation);

	void PutSetName(const XMLString& aStr)
	{ mTopLevelSetName = aStr; }

	void PutSetName(const char* aStr);

protected:
	enum DocType {
		DOC_ENTITY,
		DOC_DOCTYPE
	};

	enum AccessMethod {
		ACCESS_PUBLIC,
		ACCESS_SYSTEM
	};

	DocType mType;
	AccessMethod mMethod;
	XMLString mTopLevelSetName;
	XMLString mEntityLocation;

};


/* @class
 *
 * An incomplete class that allows further derivation.  You can override
 * functions in XMLObjectFactory to return classes derived from XMLUserObject
 * instead of one of the default types (XMLOpeningTag, XMLAggregate, XMLData,
 * or XMLInstruction).
 * @devnote You must still override Output.
 */

class XMLUserObject : public XMLObject
{
// @access Public:
public:
	// @@cmember,mfunc
	//  @@rdesc type - USER object
	Type GetType() const
	{ return USER; }

	// @@cmember,mfunc
	//  @@rdesc identifier returned from XMLObjectFactory::GetUserObjectId().
	//   this is the same for every instance of the same type.
	virtual int GetTypeId() const = 0;
};

// most compliers don't support template members, so this
// has been brought outside of XMLUserObject
// [Dummy argument M to satisfy SUNPRO compiler.]
template<class M> M * ConvertUserObject(XMLObject * obj, M *)
{
	if (obj->GetType() == XMLObject::USER
			&& ((XMLUserObject *) obj)->GetTypeId() == M::msTypeId)
		return (M *) obj;
	return NULL;
}


/* @class
 *
 * class used to generate XMLObjects.
 * Override if you want to create different types of objects.
 */
class XMLObjectFactory : public virtual ObjectWithError
{
// @access Public:
public:
	// @cmember constructor
	XMLObjectFactory();

	// @cmember destructor
	virtual ~XMLObjectFactory();

	// @cmember,mfunc Create an opening tag
	//  @@parm tag name
	//  @@parm name -> value map of attributes
	//  @@rdesc object
	virtual XMLObject * CreateOpeningTag(
		const char * apName, const char * * apAttributes);

	// @cmember,mfunc Hook to create an aggregate.
	//  @@parm tag name
	//  @@parm name -> value map of attributes
	//  @@parm contents of the aggregate.  Remove anything you need out of this
	//         list because its remaining contents will be destroyed on return.
	//  @@rdesc object
	virtual XMLObject * CreateAggregate(
		const char * apName,
		XMLNameValueMap& apAttributes,
		XMLObjectVector & arContents);

	// @cmember,mfunc Hook to create a data field
	//  @@parm data
	//  @@rdesc object
	virtual XMLObject * CreateData(const char * apData, int aLen,BOOL bCdataSection);

	// @cmember,mfunc Hook to create an instruction
	//  @@parm target
	//  @@parm data
	//  @@rdesc object
	virtual XMLObject * CreateInstruction(
		const XMLString & arTarget, const XMLString & arData);

	virtual XMLObject* CreateEntity(const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId);

	// @cmember Generate an ID used to identity an XMLUserObject subtype
	// @devnote not multithreaded!
	static int GetUserObjectId();

// @access Private:
private:
	// @cmember The next ID returned by GetUserObjectId.  Ids are assigned
	// sequentially.
	// @devnote not multithreaded!
	static int msNextId;
};


/* @class
 *
 * Entry into the XML parser.
 * This class wraps James Clark's xmltok parser.
 */

class XMLParser : public ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
	XMLParser();

  // @cmember Destructor
	virtual ~XMLParser();

	// @cmember change the object factory
	void SetObjectFactory(XMLObjectFactory * apFactory);

  // @cmember Initializes the parser
  BOOL Init(const char * apEncoding = NULL, BOOL aMD5Flag = FALSE);

  // @cmember Clears the state of the parser so it's ready to start
	// parsing more data.
	BOOL Restart(const char * apEncoding = NULL);

  // @cmember Parse some of the document.
	BOOL Parse(const char * apStr, int aLen);

  // @cmember Parse the final piece of the document.
	BOOL ParseFinal(const char * apStr, int aLen,
									XMLObject * * apResults = NULL);

  // @cmember Parse some of the document.  The buffer is
	// internal to the parser and is returned with GetBuffer.
	BOOL ParseBuffer(int aLen);

  // @cmember Parse some of the document.  The buffer is
	// internal to the parser and is returned with GetBuffer.
	BOOL ParseBufferFinal(int aLen,
												XMLObject * * apResults = NULL);


  // @cmember Allocate an internal buffer and return a
	// pointer to it.
	// TODO: should this return void *?
	char * GetBuffer(int aSize)
	{
		return (char *) XML_GetBuffer(mParser, aSize);
	}

  // @cmember Return error information.
	void GetErrorInfo(int & arCode, const char * & arpMessage,
										int & arLine, int & arColumn, long & arByte)
	{
		arCode = XML_GetErrorCode(mParser);
		arpMessage = XML_ErrorString(arCode);
		arLine = XML_GetErrorLineNumber(mParser);
		arColumn = XML_GetErrorColumnNumber(mParser);
		arByte = XML_GetErrorByteIndex(mParser);
	}

	BOOL VerifyChecksum();

	char* GetChecksum()
	{
		return &mGeneratedChecksum[0];
	}

	AutoDTD GetEntity() { return mDtd; }



	// @access Private:
private:
  typedef stack<XMLObject *, vector<XMLObject *> > XMLObjectStack;

	// @cmember stack of XMLObjects
	XMLObjectStack mObStack;

	// @cmember reference to xmltok parser
  XML_Parser mParser;

	// @cmember current object factory
	XMLObjectFactory * mpFactory;

	// @cmember by default, build the simple objects
	XMLObjectFactory mDefaultFactory;
	BOOL mbCdataSection;



	//
	// wrappers around the factory
	//

	// @cmember Helper - call the factory
	XMLObject * CreateOpeningTag(
		const char * apName, const char * * apAttributes)
	{
		XMLObject * obj = mpFactory->CreateOpeningTag(apName, apAttributes);
		ASSERT(obj || mpFactory->GetLastError());
		return obj;
	}

	// @cmember Helper - call the factory
	XMLObject * CreateAggregate(
		const char * apName,
		XMLNameValueMap apAttributes,
		XMLObjectVector & arContents)
	{
		XMLObject * obj = mpFactory->CreateAggregate(apName, apAttributes, arContents);
		ASSERT(obj || mpFactory->GetLastError());
		return obj;
	}

	// @cmember Helper - call the factory
	XMLObject * CreateData(const char * apData, int aLen)
	{
		XMLObject * obj = mpFactory->CreateData(apData, aLen,mbCdataSection);
		return obj;
	}

	// @cmember Helper - call the factory
	XMLObject * CreateInstruction(
		const XMLString & arTarget, const XMLString & arData);

	XMLObject* CreateEntity(const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId)
	{
		XMLObject * obj = mpFactory->CreateEntity(context,base,systemId,publicId);
		ASSERT(obj || mpFactory->GetLastError());
		return obj;
	}



  /* Information is UTF-8 encoded. */

	// @cmember called when an opening tag is found
  // atts is array of name/value pairs, terminated by NULL;
	// names and values are '\0' terminated.
  int HandleStartElement(const char * apName, const char * * apAtts);

	// @cmember called when a closing tag is found
  int HandleEndElement(const char * apName);

	// @cmember called when character data is found
  int HandleCharacterData(const char * apStr, int aLen) ;

	// @cmember called when an instruction is found
  int HandleProcessingInstruction(const char * apTarget, const char * apData);

	// @cmember called when an external entity (aka DTD) is found
	int HandleExternalEntityRefHandler( const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId);

		

  /*
   * callbacks called by the C code
   * the userData holds the XMLParser pointer
   * use this to call the non-static member functions
   *
   * because they're callbacks, making them inline won't improve
   * efficiency at all.
   */
	// @cmember called when an opening tag is found
  static int StartElementHandler(void * apUserData,
																 const char * apName,
																 const char * * apAtts);

	// @cmember called when a closing tag is found
  static int EndElementHandler(void * apUserData,
															 const char * apName);

	// @cmember called when character data is found
  static int CharacterDataHandler(void * apUserData,
																	const char * apStr,
																	int aLen);

	// @cmember called when an instruction is found
  static int ProcessingInstructionHandler(void * apUserData,
																					const char * apTarget,
																					const char * apData);

	static int ProcessingExternalEntityRefHandler(XML_Parser parser,
					    const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId);

	static void ProcessingUnparsedEntityDeclHandler(void *userData,
					      const char *entityName,
					      const char *base,
					      const char *systemId,
					      const char *publicId,
					      const char *notationName);

	// @cmember called when a CDATA section starts
	static void ProcessingStartCData(void* userData);
	// @cmember called when a CDATA section ends
	static void ProcessingEndCData(void* userData);



	// @cmember Return the results from the last parse
	void GetResults(XMLObject * * apResults);

	// @cmember,mfunc Push an object onto the stack
	//  @@parm object to push
	void Push(XMLObject * apObject)
	{
		mObStack.push(apObject);
	}

	// @cmember Pop an object from the stack
	XMLObject * Pop();

	// @cmember,mfunc Peek at the top object on the stack
	//  @@rdesc top object
	XMLObject * Top()
	{
		return mObStack.top();
	}

	XMLOpeningTag * OpeningTagWithName(XMLObject * apObj, const char * apName);

	void SetParseErrorDetail();
	BOOL mParseComplete;

	MT_MD5_CTX mMD5Context;

public:

	// @cmember mMD5Flag specify whether to create MD5 checksum or not
	BOOL mMD5Flag;

	// @cmember mFileChecksum checksum value from file
	char mFileChecksum[MT_MD5_DIGEST_LENGTH * 2 + 1];

	// @cmember mGeneratedChecksum checksum value generated
	char mGeneratedChecksum[MT_MD5_DIGEST_LENGTH * 2 + 1];

protected:
	AutoDTD mDtd;

};



#endif /* _XMLPARSER_H */
