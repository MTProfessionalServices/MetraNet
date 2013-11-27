#ifndef __SCHEMAOBJECTS_H__
#define __SCHEMAOBJECTS_H__
#pragma once

#include <vector>
#include <map>
#include <string>

#include <autoptr.h>
#include <NTLogger.h>

#define MAXSUPPORTED 0x7FFFFFFF
#import <MTConfigLib.tlb>


class MTSchemaElement;
class MTSchemaType;
class MTAttribute;
class MTschema;

typedef std::vector<MTSchemaElement* > MTSchemaElementList;
typedef std::vector<MTSchemaType*> MTSchemaTypeList;
typedef std::vector<MTAttribute*> MTAttributeList;
typedef std::vector<MTAttribute*>::iterator MTAttributeIterator;
typedef std::vector<std::string> MTElementOrderedList;

typedef std::map<std::string,MTSchemaElement*> ElementNodeDictionary;
typedef std::map<std::string,MTSchemaElement*>::iterator ElementNodeIterator;

typedef std::map<std::string,MTSchemaType*> TypeDictionary;
typedef std::map<std::string,MTSchemaType*>::iterator TypeIterator;

bool operator==(const MTSchemaType& a,const MTSchemaType& b);
bool operator==(const MTSchemaElement& a,const MTSchemaElement& b);
bool operator==(const MTAttribute& a,const MTAttribute& b);


/////////////////////////////////////////////////////////////////////////////
//	MTSchemabase
//
//	the base class for Elements and types
/////////////////////////////////////////////////////////////////////////////


class MTSchemabase {
public:
	MTSchemabase() :  bProcessedYet(false) {}
	MTSchemabase(const char* pName,const char* pType,MTConfigLib::IMTConfigPropPtr& aProp) : 
			mName(pName), mType(pType), mProp(aProp), bProcessedYet(false) {}



	const std::string& GetName() { return mName; }
	const std::string& GetType() { return mType; }
	void ReleaseProp() { mProp.Release(); }
	virtual void Process(MTschema& aSchema) = 0;

protected:
	bool bProcessedYet;
	std::string mName,mType;
	MTConfigLib::IMTConfigPropPtr mProp;

};

/////////////////////////////////////////////////////////////////////////////
//	MTAttribute
//
// Encapsulates a basic attribute
/////////////////////////////////////////////////////////////////////////////

class MTAttribute : public MTSchemabase {
public:
	MTAttribute() {}
	MTAttribute(const std::string& aName,const std::string& aType) 
		{mName = aName; mType = aType; }
	void Process(MTschema& aSchema);

};

/////////////////////////////////////////////////////////////////////////////
//	MTSchemaElement
//
// Encapsulates a basic Schema element
/////////////////////////////////////////////////////////////////////////////

class MTSchemaElement : public MTSchemabase {

public:
		// constructors
		MTSchemaElement() : mInlineType(NULL), aElementType(TYPE_UNKNOWN) {}
		MTSchemaElement(const char* pName,const char* pType,const char* pFixedValue,MTConfigLib::IMTConfigPropPtr& aProp);
		MTSchemaElement(MTSchemaElement& aElement);

public: //accessors
		void SetMinOcurrences(unsigned long aIn) { mMinOccurs = aIn; }
		unsigned long GetMinOccurences() { return mMinOccurs; }
		void SetMaxOccurrences(unsigned long aIn) { mMaxOccurrs = aIn; }
		unsigned long GetMaxOccurrences() { return mMaxOccurrs; }
		MTautoptr<MTSchemaType>& GetInlineType() { return mInlineType; }
		std::string& GetFixedValue() { return mFixedValue; }
		bool IsFixedValue() { return strcmp(mFixedValue.c_str(),"") == 0; }
		
		// this isn't quite right... we could be creating a user defined primative type
		bool IsSet() { return aElementType == TYPE_COMPLEX_CREATED; }
		void PutIsSet() { aElementType = TYPE_COMPLEX_CREATED; }

public: // methods

		void Process(MTschema& aSchema);
		void SetOccurences(const std::string& aMinStr,const std::string& aMaxStr);

protected:
	typedef enum {
		TYPE_UNKNOWN,
		TYPE_PRIMITIVE,
		TYPE_PRIMATIVE_CREATED,
		TYPE_COMPLEX_CREATED,
		} ElementType;

	unsigned long mMinOccurs;
	unsigned long mMaxOccurrs;
	bool bSimple;
	ElementType aElementType;
	std::string mFixedValue;
	MTautoptr<MTSchemaType> mInlineType;

};

/////////////////////////////////////////////////////////////////////////////
//	encapsulates a basic Schema Type
//
//
/////////////////////////////////////////////////////////////////////////////
typedef MTautoptr<MTAttributeList > AutoAttrList;

class MTSchemaType : public MTSchemabase {
public:
	// constructors
	MTSchemaType() : mAttributeList(NULL) {}
	~MTSchemaType();
	MTSchemaType(const char* pName,MTConfigLib::IMTConfigPropPtr& aProp);
	// methods
	void Process(MTschema& aSchema);

	MTSchemaElementList& GetElementList() { return aElementList; }
	AutoAttrList getAttrList() { return mAttributeList; }


protected:
	MTSchemaElementList aElementList;
	AutoAttrList mAttributeList;

};

/////////////////////////////////////////////////////////////////////////////
//	Handler class for an entire schema
//
//
/////////////////////////////////////////////////////////////////////////////

class MTschema {
friend MTSchemaType;
friend MTSchemaElement;
friend MTAttribute;

public:
	// ctors, dtors
	MTschema();
	~MTschema();

public: // methods

	void ProcessSchema(MTConfigLib::IMTConfigPropSetPtr& aPropSet,std::string aPrefix);

	ElementNodeDictionary& GetElementDictionary() { return mElementDictionary; }
	TypeDictionary& GetTypeDictionary() { return mTypeDictionary; }
	MTElementOrderedList& GetElementOrderedList() { return mElementOrderedList; }

	const MTSchemaElement& GetElement(const std::string& aStr);
	const MTSchemaType& GetType(const std::string& aStr);
	std::string RemoveNamespaceFromString(const std::string& aStr);

protected:
	ElementNodeDictionary mElementDictionary;
	TypeDictionary mTypeDictionary;
	MTElementOrderedList mElementOrderedList;
	NTLogger mLogger;
	std::string mNamespacePrefix;

};


#endif //__SCHEMAOBJECTS_H__
