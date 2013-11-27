
#include <StdAfx.h>
#include <metra.h>
#include "SchemaObjects.h"
#include <errobj.h>
#include "loggerconfig.h"

using namespace std;


bool operator==(const MTSchemaType& a,const MTSchemaType& b)
{
	ASSERT(false);
	return false;

}

bool operator==(const MTSchemaElement& a,const MTSchemaElement& b)
{
	ASSERT(false);
	return false;
}

bool operator==(const MTAttribute& a,const MTAttribute& b)
{
	ASSERT(false);
	return false;
}

#define TYPE_TAG "type"
#define ELEMENT_TAG "element"
#define NAME_TAG "name"
#define ATTRIBUTE_TAG "attribute"
#define MINOCURRS_ATTRIBUTE "minOccurs"
#define MAXOCURRS_ATTRIBUTE "maxOccurs"
#define FIXED_ATTRIBUTE "fixed"
#define REF_ATTRIBUTE "ref"

string pTypeTag(TYPE_TAG);
_bstr_t pTypeTagBstr(TYPE_TAG);

string pElementTag(ELEMENT_TAG);
_bstr_t pElementTagBstr(ELEMENT_TAG);

string pAttributeTag(ATTRIBUTE_TAG);
_bstr_t pAttributeTagBstr(ATTRIBUTE_TAG);

_bstr_t pMinOccursAttrBstr(MINOCURRS_ATTRIBUTE);
_bstr_t pMaxOccursAttrBstr(MAXOCURRS_ATTRIBUTE);
_bstr_t pFixedAttrBstr(FIXED_ATTRIBUTE);
_bstr_t pRefAttrBstr(REF_ATTRIBUTE);

_bstr_t pNameTag(L"name");


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSchemaElement::MTSchemaElement
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

MTSchemaElement::MTSchemaElement(const char* pName,const char* pType,const char* pFixedValue,MTConfigLib::IMTConfigPropPtr& aProp) :
	MTSchemabase(pName,pType,aProp),
	mMinOccurs(1),
	mMaxOccurrs(1),
	bSimple(true),
	mInlineType(NULL),
	mFixedValue(pFixedValue)
{

	if(mType.find(':') != string::npos) {
		aElementType = TYPE_COMPLEX_CREATED;
	}
	else {
		aElementType = TYPE_PRIMITIVE;
	}

}

MTSchemaElement::MTSchemaElement(MTSchemaElement& aElement) :
	MTSchemabase(aElement.mName.c_str(),aElement.mType.c_str(),aElement.mProp),
	mMinOccurs(1),
	mMaxOccurrs(1),
	bSimple(true),
	mInlineType(NULL),
	aElementType(aElement.aElementType)
	{}
	



/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSchemaElement::Process
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSchemaElement::Process"
void MTSchemaElement::Process(MTschema& aSchema)
{
	if(bProcessedYet) return;

	bool bInlineset = false;

	ASSERT(mProp != NULL);
	MTConfigLib::IMTConfigAttribSetPtr aAttribSet;
	MTConfigLib::IMTConfigPropPtr aInlineSet;
	BSTR aBstrTemp;

	try {
		// step 1: get the attributes on the node
		string aName,aType,aMinOccurs,aMaxOccurs;
	
		// step : decide if this is a node or a set.
		// if it is a set it must have an inline type
		if(mProp->GetPropType() == MTConfigLib::PROP_TYPE_SET) {
			bInlineset = true;
			MTConfigLib::IMTConfigPropSetPtr aTempSet;
			aTempSet = mProp->GetPropValue();
			aAttribSet = aTempSet->GetAttribSet();
			aInlineSet = aTempSet->NextWithName(pTypeTagBstr);
			if(aInlineSet == NULL) {
				// must be kind of datatype set that isn't supported.
				// set the type name to "string"
				aType = "string";
				bInlineset = false;
			}
		}
		else {
			aAttribSet = mProp->GetAttribSet();
		}

		aName = aAttribSet->GetAttrValue(pNameTag);
		if(!bInlineset && strcmp(aType.c_str(),"") == 0) {
			aType = aAttribSet->GetAttrValue(pTypeTagBstr);
		}
		mType = aType;
		if(strncmp(aSchema.mNamespacePrefix.c_str(),mType.c_str(),strlen(aSchema.mNamespacePrefix.c_str())) == 0) {
			mType = aSchema.RemoveNamespaceFromString(mType);
			aElementType = TYPE_COMPLEX_CREATED;
		}
		

		if(SUCCEEDED(aAttribSet->get_AttrValue(pMinOccursAttrBstr,&aBstrTemp))) {
			aMinOccurs = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pMaxOccursAttrBstr,&aBstrTemp))) {
			aMaxOccurs = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pFixedAttrBstr,&aBstrTemp))) {
			mFixedValue = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}

		SetOccurences(aMinOccurs,aMaxOccurs);

		if(bInlineset) {
			mInlineType = new MTSchemaType("",aInlineSet);
			mInlineType->Process(aSchema);

			int aEntries = mInlineType->GetElementList().size();

			if(aEntries > 1) {
				aElementType = TYPE_COMPLEX_CREATED;
			}
			else if(aEntries == 1) {
				MTSchemaElement* pElement = mInlineType->GetElementList()[0];
				if(pElement->IsSet()) {
					aElementType = TYPE_COMPLEX_CREATED;
				}
			}
		}

	}
	catch(_com_error& e) {
		ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,PROCEDURE);
		aError.SetProgrammerDetail((const char*)e.Description());
		throw aError;
	}
	bProcessedYet = true;


}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSchemaElement::SetOccurences
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

void MTSchemaElement::SetOccurences(const string& aMinStr,const string& aMaxStr)
{
	if(strcmp(aMinStr.c_str(),"") != 0) {
		int aTemp = atoi(aMinStr.c_str());
		if(aTemp < 0) {
			ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,"SetOccurences");
			aError.SetProgrammerDetail("Min Occurs is less than 0");
			throw aError;
		}
		mMinOccurs = aTemp;
	}
	if(strcmp(aMaxStr.c_str(),"") != 0) {
		if(strcmp(aMaxStr.c_str(),"*") == 0) {
			mMaxOccurrs = MAXSUPPORTED;
		}
		else {
			mMaxOccurrs = atoi(aMaxStr.c_str());
			if(mMaxOccurrs < mMinOccurs) {
				ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,"SetOccurences");
				aError.SetProgrammerDetail("Max occurences can not be less than Minimum occurences");
				throw aError;
			}
		}
	}
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSchemaType::MTSchemaType
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

MTSchemaType::MTSchemaType(const char* pName,MTConfigLib::IMTConfigPropPtr& aProp) :
	MTSchemabase(pName,"",aProp), mAttributeList(NULL)
{

}

MTSchemaType::~MTSchemaType()
{
	if(mAttributeList) 
	{
		for(MTAttributeIterator it = mAttributeList->begin(); it != mAttributeList->end(); it++)
		{
			delete *it;
		}
		mAttributeList->clear();
	}
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSchemaType::Process
// Description	  : 
/////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSchemaType::Process"
void MTSchemaType::Process(MTschema& aSchema)
{
	// step 1: only do this if we are not yet processed
	if(bProcessedYet) return;

	// do this here to avoid infinite recursion
	bProcessedYet = true;


	// step 2: make sure we have a prop set!
	MTConfigLib::IMTConfigPropSetPtr aPropSet;
	aPropSet = mProp->GetPropValue();
	if(aPropSet == NULL) {
		ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,PROCEDURE);
		aError.SetProgrammerDetail("Type can only use set configuration");
		throw aError;
	}

	string aName;
	string aType;
	string aTagName;
	string aMinOccurs;
	string aMaxOccurs;
	string aRef;
	string aFixedValue;
	MTSchemaType* pType;
	

	MTConfigLib::IMTConfigPropPtr aCurrentProp;
	MTConfigLib::IMTConfigAttribSetPtr aAttribSet;

	while((aCurrentProp = aPropSet->Next())) {

		if(aCurrentProp->GetPropType() == MTConfigLib::PROP_TYPE_SET) {
			MTConfigLib::IMTConfigPropSetPtr aTemp = aCurrentProp->GetPropValue();
			aAttribSet = aTemp->GetAttribSet();
		}
		else {
			aAttribSet =aCurrentProp->GetAttribSet();
		}
		aTagName = aCurrentProp->GetName();
		aName = "";
		aMinOccurs = "";
		aMaxOccurs = "";
		aType = "";
		aRef = "";
		aFixedValue = "";
		BSTR aBstrTemp;
		pType = NULL;

		if(SUCCEEDED(aAttribSet->get_AttrValue(pNameTag,&aBstrTemp))) {
			aName = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pTypeTagBstr,&aBstrTemp))) {
			aType = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pMinOccursAttrBstr,&aBstrTemp))) {
			aMinOccurs = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pMaxOccursAttrBstr,&aBstrTemp))) {
			aMaxOccurs = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pRefAttrBstr,&aBstrTemp))) {
			aRef = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
		if(SUCCEEDED(aAttribSet->get_AttrValue(pFixedAttrBstr,&aBstrTemp))) {
			aFixedValue = _bstr_t(aBstrTemp,false);
			::SysFreeString(aBstrTemp);
		}
	
		if(strncmp(aSchema.mNamespacePrefix.c_str(),aType.c_str(),strlen(aSchema.mNamespacePrefix.c_str())) == 0) {
			// make sure that this type is allready processed
			aType = aSchema.RemoveNamespaceFromString(aType);
			TypeIterator it = aSchema.mTypeDictionary.find(aType);
			if(it != aSchema.mTypeDictionary.end()) {
				pType = it->second;
				pType->Process(aSchema);
			}
			else {
				ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,PROCEDURE);
				string aTemp = "Type ";
				aTemp += aType + " ";
				aTemp += "not found in type list";
				aError.SetProgrammerDetail(aTemp);
				throw aError;
			}
		}

		if(aTagName == pElementTag) {
			MTSchemaElement* pElement;
			// check if this is a reference or not
			if(strcmp(aRef.c_str(),"") != 0) {
				// verify that we are referencing a defined element
				aRef = aSchema.RemoveNamespaceFromString(aRef);
				ElementNodeIterator it = aSchema.mElementDictionary.find(aRef);
				if(it != aSchema.mElementDictionary.end()) {
					MTSchemaElement* aElement = it->second;
					aElement->Process(aSchema);
					pElement = new MTSchemaElement(*aElement);

				}
				else {
					ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,PROCEDURE);
					aError.SetProgrammerDetail("Failed to find referenced element \"" + aRef + "\" in element list");
					throw aError;

				}
			}
			else {
				pElement = new MTSchemaElement(aName.c_str(),aType.c_str(),aFixedValue.c_str(),aCurrentProp);
				if(aCurrentProp->GetPropType() == MTConfigLib::PROP_TYPE_SET) {
					pElement->Process(aSchema);
				}
			}
			if(pType) {
				if(pType->GetElementList().size() >= 1/* ||
					(pType->GetElementList().entries() == 1 && 
					pType->GetElementList()[0]->GetMaxOccurrences() > 1) */) {
					pElement->PutIsSet();
				}
			}
			pElement->SetOccurences(aMinOccurs,aMaxOccurs);
			aElementList.push_back(pElement);

		}
		else if(aTagName == pAttributeTag) {
			if(aCurrentProp->GetPropType() == MTConfigLib::PROP_TYPE_SET) {
				// don't currently support sets
				ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,PROCEDURE);
				aError.SetProgrammerDetail("Support for sets in type declaration not supported");
				throw aError;
			}


			MTAttribute* pAttribute = new MTAttribute(aName,aType);
			if(!&mAttributeList) {
				mAttributeList = new MTAttributeList;
			}
			mAttributeList->push_back(pAttribute);
		}
		else {
			ErrorObject aError(false,ERROR_MODULE,ERROR_LINE,PROCEDURE);
			string aTempStr = aTagName + " not supported";
			aError.SetProgrammerDetail(aTempStr);
			throw aError;
		}

	}
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: MTAttribute::Process
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

void MTAttribute::Process(MTschema& aSchema)
{
	
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: MTschema::MTschema
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

MTschema::MTschema() 
{
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("MTSchema"), "[MTSchema]");

}

MTschema::~MTschema()
{
	for(ElementNodeIterator elementIt = mElementDictionary.begin(); elementIt != mElementDictionary.end(); elementIt++)
	{
		delete elementIt->second;
	}
	mElementDictionary.clear();

	for(TypeIterator typeIt = mTypeDictionary.begin(); typeIt != mTypeDictionary.end(); typeIt++)
	{
		delete typeIt->second;
	}
	mTypeDictionary.clear();

}

string MTschema::RemoveNamespaceFromString(const string& aStr)
{
//	aStr.remove(0,(strlen(mNamespacePrefix.c_str()) + 1));
	return aStr.substr(mNamespacePrefix.length() + 1);
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTschema::ProcessSchema
// Description	  : 
/////////////////////////////////////////////////////////////////////////////


void MTschema::ProcessSchema(MTConfigLib::IMTConfigPropSetPtr& aPropSet,string aPrefix)
{
	mNamespacePrefix = aPrefix;

	MTConfigLib::IMTConfigPropPtr aProp;
	MTConfigLib::IMTConfigPropSetPtr aNodePropSet;
	string aPropName;
	string aName;

	try {
		while((aProp = aPropSet->Next()) != NULL) {
			aPropName = aProp->GetName();
			if(aProp->GetPropType() == MTConfigLib::PROP_TYPE_SET) {
				aNodePropSet = aProp->GetPropValue();
				aName = aNodePropSet->GetAttribSet()->GetAttrValue(pNameTag);
			}
			else {
				aName = aProp->GetAttribSet()->GetAttrValue(pNameTag);
			}


			if(aPropName == pTypeTag) {
				mTypeDictionary[aName] = new MTSchemaType(aName.c_str(),aProp);
				
			}
			else if(aPropName == pElementTag) {
				mElementOrderedList.push_back(aName);
				mElementDictionary[aName] = new MTSchemaElement(aName.c_str(),"","",aProp);

			}
			else {
				ASSERT(!"Tag not supported yet");
				throw ErrorObject(false,ERROR_MODULE,ERROR_LINE,"ProcessSchema: Tag not supported yet");
			}

		}

		;

		for(TypeIterator aTypeIt = mTypeDictionary.begin(); 
				aTypeIt != mTypeDictionary.end(); 
				aTypeIt++) {
			aTypeIt->second->Process(*this);
		}

		for(ElementNodeIterator aElementIt = mElementDictionary.begin(); 
				aElementIt != mElementDictionary.end(); 
				aElementIt++) {
			aElementIt->second->Process(*this);
		}

	}
	catch(_com_error& e)  {
		mLogger.LogVarArgs(LOG_ERROR,"Caught error %X: %s",e.Error(),e.Description()); 
		throw e;
	}
	catch(ErrorObject& aError) {
		mLogger.LogErrorObject(LOG_ERROR,&aError);
		throw aError;
	}


}


/////////////////////////////////////////////////////////////////////////////
// Function name	:  MTschema::GetElement
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

const MTSchemaElement&  MTschema::GetElement(const string& aStr)
{
	ElementNodeIterator it = mElementDictionary.find(aStr);
	if(it != mElementDictionary.end()) {
		return *(it->second);
	}
	else {
		throw ErrorObject(false,ERROR_MODULE,ERROR_LINE,"GetElement");
	}
}


/////////////////////////////////////////////////////////////////////////////
// Function name	:  MTschema::GetType
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

const MTSchemaType&  MTschema::GetType(const string& aStr)
{
	TypeIterator it = mTypeDictionary.find(aStr);
	if(it !=  mTypeDictionary.end()) {
		return *(it->second);
	}
	else {
		throw ErrorObject(false,ERROR_MODULE,ERROR_LINE,"GetType");
	}
}



