#ifndef __XMLSET_H__
#define __XMLSET_H__
#include <PropValType.h>
#import <MTConfigLib.tlb>

union XML_Type_Union {
  _bstr_t* aBSTR;
  long* aLong;
  double* aDouble;
  char* aChar;
  int* aInt;
	bool* aBool;
  __int64* aBigInt;

  explicit XML_Type_Union() : aDouble(NULL) {}
  explicit XML_Type_Union(_bstr_t* a) : aBSTR(a) {}
  explicit XML_Type_Union(int* a) : aInt(a) {}
  explicit XML_Type_Union(long* a) : aLong(a) {}
  explicit XML_Type_Union(double* a) : aDouble(a) {}
  explicit XML_Type_Union(char* a) : aChar(a) {}
	explicit XML_Type_Union(bool* a) : aBool(a) {}
  explicit XML_Type_Union(__int64* a) : aBigInt(a) {}

};

enum XmlTypesEnum {
  XMLPROP_TYPE_UNKNOWN = 0,
	XMLPROP_TYPE_DEFAULT = 1,
	XMLPROP_TYPE_INTEGER = 2,
	XMLPROP_TYPE_DOUBLE = 3,
	XMLPROP_TYPE_STRING = 4,
	XMLPROP_TYPE_DATETIME = 5,
	XMLPROP_TYPE_TIME = 6,
	XMLPROP_TYPE_BOOLEAN = 7,
	XMLPROP_TYPE_SET = 8,
	XMLPROP_TYPE_OPAQUE = 9,
  XMLPROP_TYPE_CHAR = 10,
	XMLPROP_TYPE_BIGINTEGER = 11
};

class MTXmlSet_Item;

class MTXMLSetRepeat {
public:
  virtual void Iterate(MTXmlSet_Item []) = 0;
};


class MTXmlSet_Item {
private:
  MTXmlSet_Item() {}
public:
enum RepeatTypes {
  RepeatSet,
  SingleSet,
  SingleItem,
  RepeatItem,
};

  MTXmlSet_Item(const char* a,XmlTypesEnum b,
								XML_Type_Union c,MTXmlSet_Item* d,
								RepeatTypes aRepeatType,MTXMLSetRepeat* pRepeat,bool bOptional = false) :

								  pTag(a), aType(b), 
									mType(c), ppSet(d), 
									mRepeatType(aRepeatType),mpSetRepeatClass(pRepeat),
									mbOptional(bOptional)
									{}

  const char* pTag;
  XmlTypesEnum aType;
  XML_Type_Union mType;
  MTXmlSet_Item* ppSet;
  RepeatTypes mRepeatType;
  MTXMLSetRepeat* mpSetRepeatClass;
	bool mbOptional;
	MTConfigLib::IMTConfigAttribSetPtr aAttribsSet;
};

#define DEFINE_XML_SET(a) MTXmlSet_Item a[]  = { 

#define DEFINE_XML_STRING(a,b) MTXmlSet_Item(a,XMLPROP_TYPE_STRING,XML_Type_Union(&b),NULL,MTXmlSet_Item::SingleItem,NULL),
#define DEFINE_XML_STRING_NODATA(a) MTXmlSet_Item(a,XMLPROP_TYPE_STRING,XML_Type_Union(),NULL,MTXmlSet_Item::SingleItem,NULL),
#define DEFINE_XML_CHAR(a,b) MTXmlSet_Item(a,XMLPROP_TYPE_CHAR,XML_Type_Union(&b),NULL,MTXmlSet_Item::SingleItem,NULL),
#define DEFINE_XML_INT(a,b) MTXmlSet_Item(a,XMLPROP_TYPE_INTEGER,XML_Type_Union(&b),NULL,MTXmlSet_Item::SingleItem,NULL),
#define DEFINE_XML_INT_NODATA(a) MTXmlSet_Item(a,XMLPROP_TYPE_INTEGER,XML_Type_Union(),NULL,MTXmlSet_Item::SingleItem,NULL),
#define DEFINE_XML_OPTIONAL_INT(a,b) MTXmlSet_Item(a,XMLPROP_TYPE_INTEGER,XML_Type_Union(&b),NULL,MTXmlSet_Item::SingleItem,NULL,true),
#define DEFINE_XML_BOOL(a,b) MTXmlSet_Item(a,XMLPROP_TYPE_BOOLEAN,XML_Type_Union(&b),NULL,MTXmlSet_Item::SingleItem,NULL),

#define END_XML_SET() MTXmlSet_Item(NULL,XMLPROP_TYPE_UNKNOWN,XML_Type_Union(),NULL,MTXmlSet_Item::SingleItem,NULL) };

#define DEFINE_XML_SUBSET(a,b) MTXmlSet_Item(a,XMLPROP_TYPE_SET,XML_Type_Union(),b,MTXmlSet_Item::SingleSet,NULL),
#define DEFINE_XML_REPEATING_SUBSET(a,b,c) MTXmlSet_Item(a,XMLPROP_TYPE_SET,XML_Type_Union(),b,MTXmlSet_Item::RepeatSet,c),
#define DEFINE_XML_OPTIONAL_REPEATING_SUBSET(a,b,c) MTXmlSet_Item(a,XMLPROP_TYPE_SET,XML_Type_Union(),b,MTXmlSet_Item::RepeatSet,c,true),

/////////////////////////////////////////////////////////////////////////////
//class MTLoadXmlSet
/////////////////////////////////////////////////////////////////////////////
void MTLoadXmlSet(MTXmlSet_Item *,IMTConfigPropSet* aPropSetPtr,bool =false,MTXMLSetRepeat* pRepeatObj=NULL);

void ProcessIndividualSet(MTXmlSet_Item& aItem,MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
		// allways attach the attribset if it exists
	  if (!aItem.mbOptional || aPropSet->NextMatches(aItem.pTag, MTConfigLib::PROP_TYPE_UNKNOWN) == VARIANT_TRUE)
		{
			aItem.aAttribsSet = aPropSet->NextWithName(aItem.pTag)->GetAttribSet();
			aPropSet->Previous();
		}

    switch(aItem.aType) {
    case XMLPROP_TYPE_CHAR:
      ASSERT(aItem.mType.aChar);
      *(aItem.mType.aChar) = *(char*)_bstr_t(aPropSet->NextStringWithName(aItem.pTag));
      break;
    case XMLPROP_TYPE_INTEGER:
			if (!aItem.mbOptional || aPropSet->NextMatches(aItem.pTag, MTConfigLib::PROP_TYPE_INTEGER) == VARIANT_TRUE)
			{
				ASSERT(aItem.mType.aInt);
				*(aItem.mType.aInt) = aPropSet->NextLongWithName(aItem.pTag);
			}
      break;
    case XMLPROP_TYPE_BIGINTEGER:
			if (!aItem.mbOptional || aPropSet->NextMatches(aItem.pTag, MTConfigLib::PROP_TYPE_BIGINTEGER) == VARIANT_TRUE)
			{
				ASSERT(aItem.mType.aBigInt);
				*(aItem.mType.aBigInt) = aPropSet->NextLongLongWithName(aItem.pTag);
			}
      break;
    case XMLPROP_TYPE_STRING:
      ASSERT(aItem.mType.aBSTR);
      *(aItem.mType.aBSTR) = aPropSet->NextStringWithName(aItem.pTag);
      break;
		case XMLPROP_TYPE_BOOLEAN:
			ASSERT(aItem.mType.aBool);
			*(aItem.mType.aBool) = _variant_t(aPropSet->NextBoolWithName(aItem.pTag));
			break;

    case XMLPROP_TYPE_SET:
      {
        ASSERT(aItem.ppSet);
        MTConfigLib::IMTConfigPropSetPtr aSubSet = aPropSet->NextSetWithName(aItem.pTag);
        if(aSubSet == NULL) {
					// if not optional throw an error 
					if(!aItem.mbOptional) {
						ASSERT(!"Expecting subset tag");
						throw _com_error(E_POINTER);
					}
					else return;
        }

        switch(aItem.mRepeatType) {
        case MTXmlSet_Item::RepeatSet:
          MTLoadXmlSet(aItem.ppSet,(IMTConfigPropSet*)aSubSet.GetInterfacePtr(),true,aItem.mpSetRepeatClass);
          break;
        case MTXmlSet_Item::SingleSet:
          MTLoadXmlSet(aItem.ppSet,(IMTConfigPropSet*)aSubSet.GetInterfacePtr());
          break;
        default:
          ASSERT(!"Invalid type for subset");
        }
      }
      break;
    case 	XMLPROP_TYPE_DOUBLE:
      break;
    case XMLPROP_TYPE_UNKNOWN:
    case XMLPROP_TYPE_DEFAULT:
    case XMLPROP_TYPE_DATETIME:
    case XMLPROP_TYPE_TIME:
    case XMLPROP_TYPE_OPAQUE:
      ASSERT(!"Not implemented yet");
      break;
    default:
      ASSERT(!"Unkown set type");
    }
}

void MTLoadXmlSet(MTXmlSet_Item* aSet,IMTConfigPropSet* aPropSetPtr,bool bRepeat,MTXMLSetRepeat* pRepeatObj) 
{
  MTConfigLib::IMTConfigPropSetPtr aPropSet(aPropSetPtr);

  if(!bRepeat) {
    for(unsigned int i=0;aSet[i].pTag != NULL;i++) {
      ProcessIndividualSet(aSet[i],aPropSet);
    }
  }
  else {
    ASSERT(pRepeatObj);
    bool bStop(false);
    while(!bStop) {
      try {
        for(unsigned int i=0;aSet[i].pTag != NULL;i++) {
          ProcessIndividualSet(aSet[i],aPropSet);
        }
        pRepeatObj->Iterate(aSet);
      }
      catch(_com_error)
      {
        bStop = true;
      }
    }
  }
}

#endif //__XMLSET_H__
