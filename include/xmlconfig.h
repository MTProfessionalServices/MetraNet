/**************************************************************************
 * @doc XMLCONFIG
 *
 * @module |
 *
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
 *
 * @index | XMLCONFIG
 ***************************************************************************/

#ifndef _XMLCONFIG_H
#define _XMLCONFIG_H

#include <metra.h>

#include <XMLParser.h>

#include <list>

#include <string>

#ifdef WIN32
#include <mtcom.h>
#include <MTDec.h>
#include <MTDecimalVal.h>
#endif // WIN32

// automatic enumeration conversion is only supported on NT
#ifdef WIN32
#define AUTO_ENUM_CONVERSION
#endif // WIN32

#ifdef WIN32
#if defined(DEFINING_XMLCONFIG) && !defined(DllExportXmlConfig)
#define DllExportXmlConfig __declspec(dllexport)
#else
#define DllExportXmlConfig __declspec( dllimport )
#endif
#else // WIN32
#define DllExportXmlConfig
#endif // WIN32

/******************************************** MTDecimalValue ***/

// container for decimal values.  This class is meant to shield
// the actual storage of decimal values

/*
#ifdef WIN32
class MTDecimalValue
{
public:
	DllExportXmlConfig
	BOOL Parse(const wchar_t * apStr);

	DllExportXmlConfig
	void Format(std::string & arBuffer) const;


	DllExportXmlConfig
	const MTDecimal & GetValue() const
	{ return mValue; }

	DllExportXmlConfig
  void SetValue(const MTDecimal & arValue)
	{ mValue = arValue; }

private:
	MTDecimal mValue;
};
#else

// mef: to be implemented
//#error Implement MTDecimalValue for unix
class MTDecimalValue
{
public:
	BOOL Parse(const wchar_t * apStr)
	{
		// NOT implemented
		// assert("MTDEcimalValue::Parse is not implemented");
		return FALSE;
	}


	void Format(std::string & arBuffer) const
	{
		// NOT implemented
		// assert("MTDEcimalValue::Parse is not implemented");
		// return FALSE;
	}
	
private:
	long mValue;
};

#endif
*/

/*************************************************** ValType ***/

class ValType
{
public:
	// possible types that can be expressed in the ptype="" clause.
	// if no type is specified, it will be stored as a BSTR
	enum Type
	{
		TYPE_UNKNOWN = 0,
		TYPE_DEFAULT,
		TYPE_INTEGER,
		TYPE_DECIMAL,
		TYPE_DOUBLE,
		TYPE_STRING,
		TYPE_DATETIME,
		TYPE_TIME,
		TYPE_BOOLEAN,
		TYPE_OPAQUE,
		TYPE_ENUM,
		TYPE_ID,
    TYPE_BIGINTEGER
	};

public:
	// @cmember return a type from the Type enum.  If apType is NULL, return DEFAULT.
	DllExportXmlConfig static Type GetType(const wchar_t * apType);
};


/******************************************* XMLConfigObject ***/

/*
 * base class of configuration objects - holds the object's name.
 */

class XMLConfigObjectFactory;

class XMLConfigNameVal;
class XMLConfigPropSet;
class XMLEntity;

class XMLConfigObject : public XMLUserObject
{
public:
	DllExportXmlConfig
	XMLConfigObject();

	DllExportXmlConfig
	XMLConfigObject(const char * apName);

	DllExportXmlConfig
	virtual ~XMLConfigObject();

	DllExportXmlConfig
	XMLConfigObject & operator =(const XMLConfigObject & arOther);

	DllExportXmlConfig
	const char * GetName() const;

	DllExportXmlConfig
	void SetName(const char * apName);

	DllExportXmlConfig
	XMLNameValueMap& GetMap() { return mValueMap; }

	DllExportXmlConfig
	void PutMap(XMLNameValueMap& aMap)
	{ mValueMap = aMap; }

	// sub classes must define
	virtual BOOL IsNameVal() const = 0;

	inline XMLConfigNameVal * AsNameVal();
	inline XMLConfigPropSet * AsPropSet();

	void ProcessOpenTag(MT_MD5_CTX* apMD5Context, const char* apName, XMLNameValueMap& apAttributes);

	void ProcessOpenTag(MT_MD5_CTX* apMD5Context, const char* apName);

	virtual void ProcessSubSet(MT_MD5_CTX* apMD5Context) = 0;

	void ProcessClosingTag(MT_MD5_CTX* apMD5Context, const char* apName);

	void PreProcessCharacterData(string& value, const XMLString & arString);

protected:
	// NOTE: since there are a lot of these objects (one per property),
	// the name is stored is a character buffer instead of a string
	char * mpName;
	XMLNameValueMap mValueMap;
};


/****************************************** XMLConfigNameVal ***/

/*
 * Holds a name value pair.
 * This class temporarily holds the name/value pair while
 * it's on the stack.  The value is later placed into a name->value map
 * in the XMLConfigPropSet class.
 */

class XMLConfigObjectFactory;

class XMLConfigNameVal : public XMLConfigObject
{
public:
	DllExportXmlConfig
	XMLConfigNameVal();

	DllExportXmlConfig
	XMLConfigNameVal(const XMLConfigNameVal & arOther);

	DllExportXmlConfig
	virtual ~XMLConfigNameVal();

	DllExportXmlConfig
	XMLConfigNameVal & operator =(const XMLConfigNameVal & arOther);

	//
	// accessors
	//
	DllExportXmlConfig
	virtual int GetTypeId() const;

	DllExportXmlConfig
	ValType::Type GetPropType() const;

	DllExportXmlConfig
	void	PutPropType(ValType::Type aType);


	DllExportXmlConfig
	BOOL GetBool() const;

	DllExportXmlConfig
	time_t GetDateTime() const;

	DllExportXmlConfig
	double GetDouble() const;

#ifdef WIN32
	DllExportXmlConfig
	const MTDecimalVal & GetDecimal() const;

	DllExportXmlConfig
	__int64 GetBigInt() const;
#endif
	DllExportXmlConfig
	int GetInt() const;

	DllExportXmlConfig
	const wstring & GetString() const;

	DllExportXmlConfig
	const int & GetEnum() const;

	DllExportXmlConfig
	const wstring * GetEnumStr() const;

	DllExportXmlConfig
	const wstring & GetID() const;

	DllExportXmlConfig
	int GetTime() const;


	//
	// mutators
	//
	DllExportXmlConfig
	void InitBool(BOOL aBoolVal);

	DllExportXmlConfig
	void InitDateTime(time_t aDateTimeVal);

	DllExportXmlConfig
	void InitDouble(double aDoubleVal);

#ifdef WIN32
	DllExportXmlConfig
	void InitDecimal(const MTDecimalVal & arDecimalVal);

	DllExportXmlConfig
	void InitBigInt(__int64 aIntegerVal);
#endif

	DllExportXmlConfig
	void InitInt(int aIntegerVal);

	DllExportXmlConfig
	void InitString(const wchar_t * apStringVal);

	DllExportXmlConfig
	void InitEnum(const XMLConfigNameVal & arOther);

	DllExportXmlConfig
	void InitEnum(const wchar_t * apStringVal);

	DllExportXmlConfig
	void InitEnum(const int& apStringVal);

	DllExportXmlConfig
	void InitEnum(const wchar_t * apStringVal,const int& aIntegerVal);


	DllExportXmlConfig
	void InitID(const wchar_t * apStringVal);

	DllExportXmlConfig
	void InitTime(int aTimeVal);


	//
	// format methods
	//
	DllExportXmlConfig
	BOOL FormatValue(string & arStr) const;

	DllExportXmlConfig
	BOOL FormatValue(wstring & arStr) const;


	//
	// this is a name value object
	//
	virtual BOOL IsNameVal() const
	{ return TRUE; }

	DllExportXmlConfig
	static XMLNameValueMapDictionary* CreateValueMapDictionary();

public:
	// type id - public so objects of this type can be placed
	//  in heterogeneous lists.
	static const int DllExportXmlConfig msTypeId;

	DllExportXmlConfig virtual void ProcessSubSet(MT_MD5_CTX* pMD5Context);

private:
	friend XMLConfigObjectFactory;

	// NOTE: GetType is defined in XMLObject (virtual).  We define it here
	// privately to keep people from calling it by mistake.
	virtual int GetType()
	{ return XMLUserObject::GetType(); }

	void Clear();

	DllExportXmlConfig
	static XMLConfigNameVal * Create(const char * apName, const wstring & arValue,
																	 XMLNameValueMap& aValueMap,
																	 BOOL aAutoConvertEnums = FALSE);
	

	DllExportXmlConfig
	BOOL Init(const char * apName, const wstring & arValue,
						XMLNameValueMap& aValueMap, BOOL aAutoConvertEnums = FALSE);

	DllExportXmlConfig
		void Output(XMLWriter & arWriter) const { (const_cast<XMLConfigNameVal*>(this))->RealOutput(arWriter); }

	void RealOutput(XMLWriter & arWriter);

public:
	DllExportXmlConfig static BOOL ConvertToDateTime(const wstring & arValue, time_t * apConverted);
	DllExportXmlConfig static BOOL ConvertToBoolean(const wstring & arValue, BOOL * apConverted);
	DllExportXmlConfig static BOOL ConvertToDouble(const wstring & arValue, double * apConverted);
#ifdef WIN32
	DllExportXmlConfig static BOOL ConvertToDecimal(const wstring & arValue, MTDecimalVal * apConverted);
	DllExportXmlConfig static BOOL ConvertToBigInteger(const wstring & arValue, __int64 * apConverted);
#endif
	DllExportXmlConfig static BOOL ConvertToInteger(const wstring & arValue, int * apConverted);
	DllExportXmlConfig static BOOL ConvertToTime(const wstring & arValue, long * apConverted);
	DllExportXmlConfig static BOOL ConvertToEnum(const wstring & arValue, const wstring & arSpace,
																							 const wstring & arType, long * apConverted);

private:
	static BOOL FormatTime(long aTime, string & arFormatted);
	static BOOL FormatDateTime(time_t aDateTime, string & arFormatted);
	static BOOL FormatInteger(int aInt, string & arFormatted);
	static BOOL FormatDouble(double aDouble, string & arFormatted);
#ifdef WIN32
	static BOOL FormatDecimal(const MTDecimalVal & arDecimal, string & arFormatted);
	static BOOL FormatBigInteger(__int64 aInt, string & arFormatted);
#endif

private:
	// NOTE: even though the type is in the variant, we need to store it
	//   here as well because we can store types that variant can't (like TIME)
	ValType::Type mType;

	// NOTE: members of unions aren't allowed to have copy constructors.
	// therefore, the union can't hold an wstring.  It holds a pointer to one on
	// the heap as well.

 public:
	typedef struct {
	  int mEnumTypeVal;
	  wstring* mpEnumTypeStr;
	} mEnumPair;

 private:
	union
	{
		BOOL mBoolVal;
		time_t mDateTimeVal;
		double mDoubleVal;
#ifdef WIN32
		MTDecimalVal * mpDecimalVal;
    __int64 mBigIntegerVal;
#endif
		int mIntegerVal;
		wstring * mpStringVal;
		int mTimeVal;
	        mEnumPair mEmp;
	};
};


/****************************************** XMLConfigPropSet ***/

/*
 * @class
 *
 * Holds a set of name value pairs and/or other property sets.
 */

class XMLConfigPropSet : public XMLConfigObject
{
public:
	XMLConfigPropSet(const char * apName) : XMLConfigObject(apName), mDtd(NULL)
	{ }

	DllExportXmlConfig
	~XMLConfigPropSet();

	//  heterogeneous list of XMLConfigPropSet or XMLConfigNameVal objects
	//  (use GetTypeId() to distinguish the two)
	typedef list<XMLConfigObject *> XMLConfigObjectList;

	//  Iterator through the contents of this property set
	typedef XMLConfigObjectList::iterator XMLConfigObjectIterator;

	// Add an object to this list of configuration objects
	DllExportXmlConfig
	void AddConfigObject(XMLConfigObject * apObject);

	DllExportXmlConfig
	XMLConfigObjectList & GetContents();

	DllExportXmlConfig
	const XMLConfigObjectList & GetContents() const;

	DllExportXmlConfig
	BOOL AddContents(XMLObjectVector & arContents);

	DllExportXmlConfig
	void Output(XMLWriter & arWriter) const;

	DllExportXmlConfig void TopLevelOutput(XMLWriter & arWriter,const char* pCheckSum);

	DllExportXmlConfig void ChecksumRefresh(string& pCheckSum);

	DllExportXmlConfig virtual void ProcessSubSet(MT_MD5_CTX* pMD5Context);

	DllExportXmlConfig
	virtual int GetTypeId() const;

	//
	// this is a _not_ a name value object
	//
	virtual BOOL IsNameVal() const
	{ return FALSE; }

	// type id - public so objects of this type can be placed
	//  in heterogeneous lists.
	static const int DllExportXmlConfig msTypeId;

	DllExportXmlConfig 
		AutoDTD GetEntity() { return mDtd; }

	DllExportXmlConfig
	void PutEntity(AutoDTD& aEntity) { mDtd = aEntity; }


private:
	XMLConfigObjectList mList;
	AutoDTD mDtd;

};


//
// helper functions
//
DllExportXmlConfig
XMLConfigObject * Next(XMLConfigPropSet::XMLConfigObjectIterator & arIterator,
											 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt);

DllExportXmlConfig
XMLConfigNameVal * NextVal(XMLConfigPropSet::XMLConfigObjectIterator & arIterator,
													 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt);

DllExportXmlConfig
XMLConfigObject * NextWithName(const char * apName,
															 XMLConfigPropSet::XMLConfigObjectIterator & arIterator,
															 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt);

DllExportXmlConfig
XMLConfigNameVal * NextValWithName(const char * apName,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arIterator,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt);

DllExportXmlConfig
BOOL NextStringWithName(const char * apName,
												XMLConfigPropSet::XMLConfigObjectIterator & arIterator,
												XMLConfigPropSet::XMLConfigObjectIterator & arEndIt,
												string & arString);

DllExportXmlConfig
XMLConfigPropSet * NextSetWithName(const char * apName,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arIterator,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt);


/************************************ XMLConfigObjectFactory ***/

/*
 * An object factory that knows how to parse MSIX tags.
 */
class XMLConfigObjectFactory : public XMLObjectFactory
{
public:
	DllExportXmlConfig
	XMLConfigObjectFactory();

	DllExportXmlConfig
	XMLObject * CreateData(const char * apData, int aLen,BOOL bCdataSection);

	DllExportXmlConfig
XMLObject * CreateAggregate(
		const char * apName,
		XMLNameValueMap& apAttributes,
		XMLObjectVector & arContents);

	DllExportXmlConfig
	XMLObject* CreateEntity(const char *apcontext,
					  const char *apbase,
					  const char *apsystemId,
					  const char *appublicId);



	DllExportXmlConfig
	void SetAutoConvertEnums(BOOL aConvert)
	{ mAutoConvertEnums = aConvert; }

	DllExportXmlConfig
	BOOL GetAutoConvertEnums()
	{ return mAutoConvertEnums; }

private:
	static BOOL DataOnly(const XMLObjectVector & arContents);

	// "ptype"
private:
	BOOL mAutoConvertEnums;
};

/******************************************* XMLConfigParser ***/

class XMLConfigParser : public XMLParser
{
public:
	DllExportXmlConfig
	XMLConfigParser(int aBufferSize);

	// @cmember destructor
	DllExportXmlConfig
	virtual ~XMLConfigParser();

	DllExportXmlConfig
	void SetAutoConvertEnums(BOOL aConvert)
	{ mFactory.SetAutoConvertEnums(aConvert); }

	DllExportXmlConfig
	BOOL GetAutoConvertEnums()
	{ return mFactory.GetAutoConvertEnums(); }

	// parse a file, return NULL if it fails
	DllExportXmlConfig
	XMLConfigPropSet * ParseFile(const char * apFilename);

	// parse a FILE *, return NULL if it fails
	DllExportXmlConfig
	XMLConfigPropSet * ParseFile(FILE * apFile);


private:
	XMLConfigObjectFactory mFactory;
};


/*************************************************** inlines ***/

inline XMLConfigNameVal * XMLConfigObject::AsNameVal()
{
	ASSERT(IsNameVal());
	return static_cast<XMLConfigNameVal *>(this);
}

inline XMLConfigPropSet * XMLConfigObject::AsPropSet()
{
	ASSERT(!IsNameVal());
	return static_cast<XMLConfigPropSet *>(this);
}



#endif /* _XMLCONFIG_H */

