/**************************************************************************
 * @doc MSIXDefinition
 *
 * @module	Encapsulation for Database MSIXDefinition Property |
 *
 * This class encapsulates the insertion or removal of MSIXDefinition Properties
 * from the database. All access to MSIXDefinition should be done through this
 * class.
 *
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Raju Matta
 * $Header: s:\Core\msix\MSIXDefinition.cpp, 45, 10/15/2002 7:46:32 PM, Boris$
 *
 * @index | MSIXDefinition
 ***************************************************************************/

#include <metra.h>

// includes
#include <MSIXDefinitionObjectFactory.h>
#include <loggerconfig.h>

#include <NTLogMacros.h>

#include <mtglobal_msg.h>

#include <tchar.h>
#include <mtprogids.h>
#include <DataAccessDefs.h>

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace
#import <MetraTech.DataAccess.tlb> //inject_statement("using namespace mscorlib;")

//
// string constants
//
const wchar_t W_PTYPE_DECIMAL_STR[] = L"decimal";



const int CMSIXDefinition::msTypeId = XMLObjectFactory::GetUserObjectId();


//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
CMSIXDefinitionObjectFactory::CMSIXDefinitionObjectFactory()
{	
}

//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
CMSIXDefinitionObjectFactory::~CMSIXDefinitionObjectFactory()
{ }


// @cmember,mfunc Hook to create an aggregate.
//	@@parm tag name
//	@@parm name -> value map of attributes
//	@@parm contents of the aggregate
//	@@rdesc object
XMLObject*
CMSIXDefinitionObjectFactory::CreateAggregate(
		const char * apName,
		XMLNameValueMap& apAttributes,
		XMLObjectVector & arContents)
{
	if (0 == strcmp(apName, DEFINESERVICE_STR))
	{
		CMSIXDefinition * pDef = CreateDefinition();
		ASSERT(pDef);
		if (Parse(*pDef, arContents, apAttributes))
		{
			return pDef;
		}
		else
		{
			if((*pDef).GetLastError() != NULL)
			{
				SetError(*pDef);
			}
			else
				ASSERT(0);
			delete pDef;
			return NULL;
		}
	}
	else
	{
		return XMLObjectFactory::CreateAggregate(apName, apAttributes, arContents);
	}
}



//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
CMSIXDefinition::CMSIXDefinition()
	: mpAttributes(NULL), 
    mbHasPartition(FALSE),
    mCanResubmitFrom(false)
{	

}

// @mfunc CMSIXDefinition copy constructor
// @parm CMSIXDefinition&
// @rdesc This implementations is for the copy constructor of the
// MSIXDefinition class
CMSIXDefinition::CMSIXDefinition(const CMSIXDefinition &c)
	: mpAttributes(NULL)
{
	*this = c;
}

// @mfunc CMSIXDefinition assignment operator
// @parm
// @rdesc This implementations is for the assignment operator of the
// MSIXDefinition class
const CMSIXDefinition&
CMSIXDefinition::operator=(const CMSIXDefinition& rhs)
{
	// set the member attributes here
	mID = rhs.mID;
	mName = rhs.mName;
  mCanResubmitFrom = rhs.mCanResubmitFrom;
  mbHasPartition = rhs.mbHasPartition;

	return ( *this );
}

//	@mfunc
//	Destructor
//	@rdesc
//	No return value
CMSIXDefinition::~CMSIXDefinition()
{
	MSIXPropertiesList::iterator it;
	for (it = mPropertiesList.begin(); it != mPropertiesList.end(); ++it)
	{
		CMSIXProperties * prop = *it;
		delete prop;
	}
	mPropertiesList.clear();
}

void CMSIXDefinition::AddAttribute(const wchar_t * apName, const wchar_t * apValue)
{
	if (!mpAttributes)
		mpAttributes = new XMLNameValueMapDictionary;

	(*mpAttributes)[apName] = apValue;
}

const std::string & CMSIXDefinition::GetChecksum() const
{
	// make sure it's been set
	ASSERT(mChecksum.length() > 0);

	return mChecksum;
}



//	@mfunc Output
//	This function writes all the properties of a MSIXDefinition to XML
//	@rdesc
//	Returns TRUE on success. Otherwise, FALSE is returned and the error code
//	is saved in the mLastError data member.
void
CMSIXDefinition::Output (XMLWriter& arWriter) const
{
	// local variables
	BOOL bOK = TRUE;

	// open with "4" string
	arWriter.OutputOpeningTag(DEFINESERVICE_STR);

	// output the service name
	const wchar_t* pName = mName.c_str();
	arWriter.OutputSimpleAggregate(NAME_STR, pName);

	// output the table name
//	const wchar_t* pTableName = mTableName;
//	arWriter.OutputSimpleAggregate(TABLE_NAME_STR, pTableName);

	MSIXPropertiesList::const_iterator it;
	for (it = mPropertiesList.begin(); it != mPropertiesList.end(); ++it)
	{
		const CMSIXProperties * prop = *it;

		wchar_t tempNum[50];

		// start getting values from the table
		// cast it const wchar_t* -- more efficient

		// get the distinguished name
		const wchar_t* pDN = prop->GetDN().c_str();

		// get the type
		const wchar_t* pType = prop->GetDataType().c_str();

		// get the length
		const wchar_t* pLength = _itow(prop->GetLength(), tempNum, 10);

		// get the required field
		const wchar_t* pRequired = prop->GetRequiredConstraint();

		// get the default value
		const wchar_t* pDefault = prop->GetDefault().c_str();

		// output the opening ptype tag
		arWriter.OutputOpeningTag (PTYPE_STR);

		// output the distinguished name
		arWriter.OutputSimpleAggregate (DISTINGUISHED_NAME_STR, pDN);

		// output the type
		arWriter.OutputSimpleAggregate (TYPE_STR, pType);

		// output the length
		arWriter.OutputSimpleAggregate (LENGTH_STR, pLength);

		// output if its a required field or not
		arWriter.OutputSimpleAggregate (REQUIRED_STR, pRequired);

		// output the default value
		arWriter.OutputSimpleAggregate (DEFAULTVALUE_STR, pDefault);

		// close with "ptype" string
		arWriter.OutputClosingTag (PTYPE_STR);
	}

	// close with "servicedef" string
	arWriter.OutputClosingTag(DEFINESERVICE_STR);

	return;
}

// derive tablename from msix def name
// oracle compatible
wstring CMSIXDefinition::GenerateTableName(const wchar_t * apPrefix)
{
	// setup table name
	// table name is a string manipulation of the name
	// for example: if name is metratech.com/audioconfcall, the
	// table name gets translated to <prefix>_audioconfcall
  // also, for oracle, the resulting tablename is hashed.
	std::wstring tableName = GetName();
	unsigned int pos = tableName.find_first_of (L"/", 0) ;
	if (pos == string::npos)
	{
		pos = tableName.find_first_of (L"\\", 0) ;
	}
	tableName.erase (0, pos+1) ;
	
  /* No more special treatment for aggregate-rated priceable item types.  They're 
    just going to have to deal with it like everyone else.
  */

  // insert the requested prefix
  tableName.insert(0,apPrefix);

	//while ((tableName.contains (L"/") == TRUE) || 
	//	(tableName.contains (L"\\") == TRUE))
	while((tableName.find(L"/", 0) != string::npos) ||
		(tableName.find(L"\\", 0) != string::npos))
	{
	 // tableName.subString(L"/") = L"_";
		unsigned int charpos = tableName.find_first_of(L"/", 0);
		if (charpos != string::npos)
			tableName.replace(charpos, 1, L"_");
		charpos = tableName.find_first_of(L"\\", 0);
		if (charpos != string::npos)
			tableName.replace(charpos, 1, L"_");
	
	  //tableName.subString(L"\\") = L"_";
	}

  // hash the tablename to comply with 30 char limit
  // this is a no-op if the db type is sqlserver
  // Unfortunately there is a bug in W2K3 that causes leaks when calling COM+.  This has come up with 
  // MetraFlow at Microsoft.  Here we break the abstraction of the DBNameHash and skip
  // calling it if we know we are on SQL (where this is a no-op).
  // See ESR-3240 and http://support.microsoft.com/kb/918326 for background.
  std::wstring hashedTab;
  IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
  queryAdapter->Init("Queries\\invoice");
  _bstr_t dbtype = queryAdapter->GetDBType() ;
	// oracle database?
  if(mtwcscasecmp(dbtype, ORACLE_DATABASE_TYPE) == 0)
  {
    MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
    hashedTab = nameHash->GetDBNameHash(tableName.c_str());
  }
  else
  {
    hashedTab = tableName;
  }
	return hashedTab;
}

// generates a full-length table name, non-truncated
// NOTE: not Oracle compatible
wstring CMSIXDefinition::GenerateLongTableName(const wchar_t * apPrefix)
{
	// table name is a string manipulation of the name
	// for example: if name is metratech.com/audioconfcall, the
	// table name gets translated to <prefix>_audioconfcall
	std::wstring tableName = GetName();
	unsigned int pos = tableName.find_first_of (L"/", 0) ;
	if (pos == string::npos)
	{
		pos = tableName.find_first_of (L"\\", 0) ;
	}
	tableName.erase (0, pos+1) ;

	tableName.insert(0,apPrefix);

	while((tableName.find(L"/", 0) != string::npos) ||
		(tableName.find(L"\\", 0) != string::npos))
	{
		unsigned int charpos = tableName.find_first_of(L"/", 0);
		if (charpos != string::npos)
			tableName.replace(charpos, 1, L"_");
		charpos = tableName.find_first_of(L"\\", 0);
		if (charpos != string::npos)
			tableName.replace(charpos, 1, L"_");
	}

	return tableName;
}

void CMSIXDefinition::CalculateTableName(const wchar_t * apPrefix)
{
	SetTableName(GenerateTableName(apPrefix).c_str());
}

void CMSIXDefinition::CalculateBackupTableName(const wchar_t * apPrefix)
{
	SetBackupTableName(GenerateTableName(apPrefix).c_str());
}

// find a property based on name
BOOL CMSIXDefinition::FindProperty(const std::wstring &arPropertyName,
																	 CMSIXProperties * & arpProperty)
{
  // null out the service ptr ...
  arpProperty = NULL ;

	ASSERT(!arPropertyName.empty());

	std::wstring name(arPropertyName);
	_wcslwr((wchar_t *)name.c_str());

	MSIXPropertyMap::iterator it = mMap.find((const wchar_t *) name.c_str());
	if (it == mMap.end())
		// TODO: should this be marked as an error?
		return FALSE;
		
	arpProperty = it->second;
	return TRUE;
}


//
//
XMLObject*
CMSIXDefinitionObjectFactory::CreateData(const char * apData, int aLen,BOOL bCdataSection)
{
	// ignore whitespace - return NULL if the string is made up
	// of whitespace only
	BOOL allspace = TRUE;
	for (int i = 0; i < aLen; i++)
	{
		if (!isspace(apData[i]))
		{
			allspace = FALSE;
			break;
		}
	}
	if (allspace)
		return NULL;

	// FALSE argument indicates no CDATA section.
	return XMLObjectFactory::CreateData(apData, aLen,bCdataSection);
}

//
//
//
void
CMSIXDefinition::PrintDefinitionContents ()
{
	MSIXPropertiesList::iterator it;
	for (it = mPropertiesList.begin(); it != mPropertiesList.end(); ++it)
	{
		CMSIXProperties * prop = *it;
	    wstring msgbuf;
		msgbuf = _T("--------------------------------------------");
		msgbuf += _T("\n");
		msgbuf += _T("\t DN = ");
		msgbuf += prop->GetDN();
		msgbuf += _T("\n");
		msgbuf += _T("\t Type = ");
		msgbuf += prop->GetDataType();
		msgbuf += _T("\n");
		msgbuf += _T("\t Length = ");
		msgbuf += MTMiscUtil::IntToWString(prop->GetLength()); 
		msgbuf += _T("\n");
		msgbuf += _T("\t IsRequired = ");
		msgbuf += prop->GetRequiredConstraint();
		msgbuf += _T("\n");
		msgbuf += _T("\t Default = ");
		msgbuf += prop->GetDefault();

		MT_LOG_TRACE_WSTRING (CORE_STR, CORE_TAG, msgbuf);
	}

	return;
}

//
//
//
void
CMSIXDefinition::AddProperty(const wchar_t* dn,
							 const wchar_t* type,
							 const wchar_t* length,
							 const wchar_t* required,
							 const wchar_t* defaultval)
{
	// create a new
	CMSIXProperties* pProperties = new CMSIXProperties;

	// make sure it is a valid pointer
	ASSERT (pProperties);

	wstring RWDN(dn);
	pProperties->SetDN(RWDN.c_str());
	MT_LOG_TRACE_WSTRING (CORE_STR, CORE_TAG, RWDN);

	wstring RWtype(type);
	pProperties->SetDataType(RWtype.c_str());
	MT_LOG_TRACE_WSTRING (CORE_STR, CORE_TAG, RWtype);

	// convert the string to integer
	int iLength = MTMiscUtil::WStringToInt(length);
	pProperties->SetLength(iLength);

	wstring RWrequired(required);
	pProperties->SetDN(RWrequired.c_str());
	MT_LOG_TRACE_WSTRING (CORE_STR, CORE_TAG, RWrequired);

	wstring RWdefaultval(defaultval);
	pProperties->SetDefault(RWdefaultval.c_str());
	MT_LOG_TRACE_WSTRING (CORE_STR, CORE_TAG, RWdefaultval);

	mPropertiesList.push_back(pProperties);
}

void CMSIXDefinition::AddPropertyToList (CMSIXProperties* p)
{
	mPropertiesList.push_back(p);

	std::wstring name = p->GetDN();
	_wcslwr((wchar_t *)name.c_str());

	mMap[(const wchar_t *) name.c_str()] = p;
}




//	@mfunc Parse
//	@parm
//	@rdesc
const char* gParseFuncName = "CMSIXDefinitionObjectFactory::Parse";

BOOL
CMSIXDefinitionObjectFactory::Parse (	CMSIXDefinition & arDef,
					XMLObjectVector& arContents,
					XMLNameValueMap& arAttributes)
{
	const char * functionName = "CMSIXDefinitionObjectFactory::Parse";

	// local variables
	BOOL bOK = TRUE;

	// loop through the contents
	int outerit = 0;
	int outerSize = arContents.GetEntries();
	
	// get the initial 3 values first i.e: service name, major version,
	// and minor version
	XMLString xName;
    try
    {
      // ----------- service name -------------- can has only one <name> tag
	    CheckArraySize(outerit, outerSize, "defineservice");
		XMLObject* obj = arContents[outerit++];
		arDef.SetName(GetValueFromXmlContent(obj, NAME_STR).c_str());

	    // set attributes if any
		XMLNameValueMapDictionary * myDict = (XMLNameValueMapDictionary *)((XMLAggregate *)obj)->GetAttributes();
		if (myDict != NULL)
		{	
			XMLNameValueMapDictionary::const_iterator it;
			for (it = myDict->begin(); it != myDict->end(); it++)
			{
				const XMLString & name = it->first;
				XMLString attrib = it->second;
				// add to the attribute map
				arDef.AddAttribute(name.c_str(), attrib.c_str());
			}
		}

        // optional <resubmit> tag
	    if (CheckArraySize(outerit, outerSize))
		{
		  obj = arContents[outerit];      
		  if (IsContainTag(obj, "can_resubmit_from"))
		  {
			  XMLString & xmlValue = GetValueFromXmlContent(obj, "can_resubmit_from");
			  arDef.SetCanResubmitFrom(ParseBoolValue(xmlValue, "can_resubmit_from"));
			  outerit++;
		  }
		}
	
        // optional <partition> tag - increment outerit only if <partition> tag is found
        if (CheckArraySize(outerit, outerSize))
	    {
		  obj = arContents[outerit]; 
		  if (IsContainTag(obj, PARTITION_STR))
		  {
			  XMLString & xmlValue = GetValueFromXmlContent(obj, PARTITION_STR);
			  arDef.SetPartition(ParseBoolValue(xmlValue, PARTITION_STR));
			  outerit++;
		  }
	    }      

	    // map of property names to their count
	    std::map<std::wstring, int> propertyNames;   
	    // -------------- ptype  ------------
	    // move to next
        BOOL foundPtypeTag = FALSE;

	    while (outerit < outerSize)
	    {
		      obj = arContents[outerit++];

		      CheckForAggregateTag(obj->GetType());

		      // TODO: use static cast
		      // allows things that are only derived from each
		      // other
		      XMLAggregate* parentAgg = static_cast<XMLAggregate *>(obj);

		      // should contain only aggregates now
		      std::string tagName(parentAgg->GetName());
      
		      // ignore description tags
		      if (tagName == DESCRIPTION_STR)
			  {
				  arDef.SetDescription(GetValueFromContent(parentAgg, tagName).c_str());
				  continue;
			  }
		      else if (tagName != "ptype")
		      {
               // If we haven't found any <ptype> tag, then error
               if (foundPtypeTag == FALSE) {
                  arDef.SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
										         functionName,
										         "expecting tag ptype");

                  return FALSE;
               }
               // we've found <ptype> tag, expecting <uniquekey> tag
               else if (tagName == UNIQUEKEY_STR) 
               {
			         // Parse the <uniquekey> items - if any
                  bOK = ParseUniqueKeys(arDef, arContents, outerit - 1);
                  break;
               }
               // found unknown tag
               else 
               {
                  arDef.SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
										         functionName,
                                       ("found unknown tag " + tagName).c_str());

                  return FALSE;
               }
			
		      }

		      // it is an aggregate (ptype), so loop once again
		      int innerSize;
		      XMLObject *const * inner = parentAgg->GetContents(innerSize);
		      int innerit = 0;
			    foundPtypeTag = TRUE;

		      // put it in a diff. function.


			    // ============ todo: make sure we don't leak on failure
				    // create a new
			    CMSIXProperties* pProperties = new CMSIXProperties();

			    // make sure it is a valid pointer
			    ASSERT (pProperties);
				
			    obj = inner[innerit++];

			    XMLString xDN;
			    XMLString xType;
			    XMLString xRequired;
			    XMLString xLength;
			    XMLString xDefault;
			    XMLString xDescID;

			    XMLString xAttrib;

			    // set attributes if any
			    XMLNameValueMapDictionary * myDict = (XMLNameValueMapDictionary *)parentAgg->GetAttributes();
			    if (myDict != NULL)
			    {	
				    XMLNameValueMapDictionary::const_iterator it;
				    for (it = myDict->begin(); it != myDict->end(); it++)
				    {
					    const XMLString & name = it->first;
					    if (0 == mtwcscasecmp(name.c_str(), _TEXT("UserVisible")))
					    {
						    xAttrib = it->second;
							pProperties->SetUserVisible(ConvertBoolToVariantBool(WParseBoolValue(xAttrib, name)));	

					    }
					    else if (0 == mtwcscasecmp(name.c_str(), _TEXT("Filterable")))
					    {
						    xAttrib = it->second;
							pProperties->SetFilterable(ConvertBoolToVariantBool(WParseBoolValue(xAttrib, name)));							
					    }
					    else if (0 == mtwcscasecmp(name.c_str(), _TEXT("Exportable")))
					    {
						    xAttrib = it->second;
							pProperties->SetExportable(ConvertBoolToVariantBool(WParseBoolValue(xAttrib, name)));						
						
					    }
					    else if (0 == mtwcscasecmp(name.c_str(), _TEXT("PartOfKey")))
					    {
						    xAttrib = it->second;
							pProperties->SetPartOfKey(ConvertBoolToVariantBool(WParseBoolValue(xAttrib, name)));					
						
					    }
					    else if (0 == mtwcscasecmp(name.c_str(), _TEXT("Index")))
					    {
						    xAttrib = it->second;
						    if (0 == mtwcscasecmp(xAttrib.c_str(), _TEXT("single")))
							    pProperties->SetSingleIndex(VARIANT_TRUE);
						    else if (0 == mtwcscasecmp(xAttrib.c_str(), _TEXT("composite")))
							    pProperties->SetCompositeIndex(VARIANT_TRUE);
						    else if (0 == mtwcscasecmp(xAttrib.c_str(), _TEXT("singlecomposite")))
							    pProperties->SetSingleCompositeIndex(VARIANT_TRUE);
						    else
						    {
							    char buf[255];
							    sprintf("\"Index\" field has an invalid value of <%s>", ascii(xAttrib).c_str());
							    arDef.SetError(FALSE, ERROR_MODULE, ERROR_LINE, gParseFuncName, buf);
							    return FALSE;
						    }
					    }
					    else if(0 ==  mtwcscasecmp(name.c_str(), _TEXT("reference"))) {
						    pProperties->SetReferenceTable(it->second.c_str());
					    }
					    else if(0 ==  mtwcscasecmp(name.c_str(), _TEXT("ref_column"))) {
						    pProperties->SetRefColumn(it->second.c_str());
					    }
						else if (0 == mtwcscasecmp(name.c_str(), _TEXT("AccountIdentifier")))
					    {
						    xAttrib = it->second;
							pProperties->SetAccountIdentifier(ConvertBoolToVariantBool(WParseBoolValue(xAttrib, name)));				
						
					    }
					    else
					    {
						    // unknown extra attribute
						    // add it to the map
						    pProperties->AddAttribute(name.c_str(), it->second.c_str());
					    }
				    }
			    }
				
			    // -------------------------------------
			    // get distinguished name			   
				  pProperties->SetDN(GetValueFromXmlContent(obj, DISTINGUISHED_NAME_STR).c_str());	

			    // have we seen this property before?  If so, attach a unique suffix
			    int & theCount = propertyNames[pProperties->GetDN()];
			    int count = theCount++;
			    if (count > 0)
			    {
				    // we've seen this property before - give it a unique suffix
				    pProperties->SetUniqueSuffix(count + 1);
			    }

			    MT_LOG_TRACE_WSTRING (CORE_STR, CORE_TAG, pProperties->GetDN());

			    // -------------------------------------
			    // move to next			    
				CheckArraySize(innerit, innerSize, TYPE_STR);
				obj = inner[innerit++];
				wstring RWType(GetValueFromXmlContent(obj, TYPE_STR));			             

			    // need to do this, since the table is a <wstring, wstring>
			    // hash dictionary, and data is in std::wstring format.
			    // convert string to varchar
			    // convert int32 to int
			    // convert timestamp to datetime
			    CMSIXProperties::PropertyType propType;			    
			    if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_STRING_STR))
			    {
				    RWType = W_DB_VARCHAR_STR;
				    propType = CMSIXProperties::TYPE_STRING;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_WSTRING_STR))
			    {
				    RWType = W_DB_NVARCHAR_STR;
				    propType = CMSIXProperties::TYPE_WIDESTRING;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_INT32_STR))
			    {
				    RWType = W_DB_INT_STR;
				    propType = CMSIXProperties::TYPE_INT32;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_INT64_STR))
			    {
				    RWType = W_DB_BIGINT_STR;
				    propType = CMSIXProperties::TYPE_INT64;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_TIMESTAMP_STR))
			    {
				    RWType = W_DB_DATETIME_STR;
				    propType = CMSIXProperties::TYPE_TIMESTAMP;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_FLOAT_STR))
			    {
				    RWType = W_DB_NUMERIC_STR;
				    propType = CMSIXProperties::TYPE_DOUBLE;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_DOUBLE_STR))
			    {
				    RWType = W_DB_DOUBLE_STR;
				    propType = CMSIXProperties::TYPE_DOUBLE;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(),W_PTYPE_BOOLEAN_STR)) 
			    {
				    RWType = W_DB_CHAR_STR;
				    propType = CMSIXProperties::TYPE_BOOLEAN;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(),W_PTYPE_TIME_STR)) 
			    {
				    RWType = W_DB_INT_STR;
				    propType = CMSIXProperties::TYPE_TIME;
			    }
			    else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_ENUM_STR))
			    {
				    XMLString xEnum = xDN;
				    XMLString xNamespace = xName;

				    // set attributes if any
				    XMLNameValueMapDictionary * myDict
						= (XMLNameValueMapDictionary *)((XMLAggregate *) obj)->GetAttributes();
				    if (myDict != NULL)
				    {
					
					    XMLNameValueMapDictionary::const_iterator it;
					    for (it = myDict->begin(); it != myDict->end(); it++)
					    {
						    // TODO: this iterator is not very efficient - it returns the keys by value
						    const XMLString & name = it->first;
						    if (!mtwcscasecmp(name.c_str(), _TEXT("EnumSpace")))
						    {
							    xNamespace = it->second;
						    }
						    else if (!mtwcscasecmp(name.c_str(), _TEXT("EnumType")))
						    {
							    xEnum = it->second;
						    }
					    }
				    }

					RWType = W_DB_ENUM_STR;
					propType = CMSIXProperties::TYPE_ENUM;
					pProperties->SetEnumNamespace(xNamespace.c_str());
					pProperties->SetEnumEnumeration(xEnum.c_str());
				}
				else if (0 == mtwcscasecmp(RWType.c_str(), W_PTYPE_DECIMAL_STR))
				{
					RWType = W_DB_NUMERIC_STR;
					propType = CMSIXProperties::TYPE_DECIMAL;
				}
				else
				{
					char buf[255];
					sprintf(buf, "Unknown data type in MSIX definition file: %s", ascii(RWType).c_str());
					arDef.SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
												 gParseFuncName, buf);
					return FALSE;
				}	
			   
			  MT_LOG_TRACE_WSTRING (SERVICE_STR, SERVICES_TAG, "!DataTypy and PropertyType!".c_str());
			  pProperties->SetDataType(RWType.c_str());
			  MT_LOG_TRACE_WSTRING (SERVICE_STR, SERVICES_TAG, RWType.c_str());
			  pProperties->SetPropertyType(propType);
			  MT_LOG_TRACE_WSTRING (SERVICE_STR, SERVICES_TAG, propType.c_str());

			  // -------------------------------------
			  // move to next
			  CheckArraySize(innerit, innerSize, LENGTH_STR);
			  long lLength = MTMiscUtil::WStringToInt(GetValueFromXmlContent(inner[innerit++], LENGTH_STR).c_str());
			  
			  //booleans always have a length of 1
			  if(propType == CMSIXProperties::TYPE_BOOLEAN)
				  lLength = 1;

			  pProperties->SetLength(lLength);

			// -------------------------------------
			// check to make sure that if the datatype
			// is varchar, there is a length associated
			// with it.
			if (0 == mtwcscasecmp(RWType.c_str(), W_DB_VARCHAR_STR))
			{
				if (lLength == 0)
				{
					arDef.SetError(FALSE, ERROR_MODULE, ERROR_LINE,gParseFuncName,"Length is 0 for varchar datatype");
				}
			}
			
			// -------------------------------------
			// move to next			
		    CheckArraySize(innerit, innerSize, REQUIRED_STR);
		    wstring requiredValue = GetValueFromXmlContent(inner[innerit++], REQUIRED_STR);			
			pProperties->SetIsRequired(ConvertBoolToVariantBool(IsContainTrue(requiredValue)));
			
			// -------------------------------------
			// move to next
			CheckArraySize(innerit, innerSize, DEFAULTVALUE_STR);
			pProperties->SetDefault(GetValueFromXmlContent(inner[innerit++], DEFAULTVALUE_STR).c_str()); 

			// -------------------------------------
			// move to next optional <description> tag
			if (CheckArraySize(innerit, innerSize))
			{
				pProperties->SetDescription(GetValueFromXmlContent(inner[innerit], DESCRIPTION_STR).c_str()); 
			}
			
			// -------------------------------------
			// move to next
			// -------------------------------------
			arDef.AddPropertyToList(pProperties);
		
			// NOTE: any extra tags are ignored! (by design)

	  } // while outerit()
  }
  catch(std::invalid_argument &e)
  {
    arDef.SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, 
		ERROR_LINE, functionName, e.what());    
    bOK = false;
  }

	if (bOK)
	{
		// do any optional setup
		bOK = arDef.Setup();
		if (!bOK)
			SetError(arDef);
	}

	return bOK;
}

//=== [BIGIN] Methods which are used in Parse() ===//
wstring CMSIXDefinitionObjectFactory::GetValueFromContent(XMLAggregate* parentAgg, const string &tagName) const
{
    XMLString xmlValue;
    if (!parentAgg->GetDataContents(xmlValue))
		{
			throw std::invalid_argument("Invalid getting content from '" + tagName + "' tag");
		}

	wstring wValue(xmlValue);
    return wValue;
}

bool CMSIXDefinitionObjectFactory::IsContainTag(XMLObject* xmlObj, const string &expectedTagName) const
{
    CheckForAggregateTag(xmlObj->GetType());
	XMLAggregate*  agg = (XMLAggregate *) xmlObj;
	return agg->GetName() == expectedTagName;
}

wstring CMSIXDefinitionObjectFactory::GetValueFromXmlContent(XMLObject* xmlObj, const string &expectedTagName) const
{
    CheckForAggregateTag(xmlObj->GetType());
	XMLAggregate*  agg = (XMLAggregate *) xmlObj;
	string tagName (agg->GetName());
    CheckMandatoryTag(tagName, expectedTagName);
    return GetValueFromContent(agg, tagName);
}

bool CMSIXDefinitionObjectFactory::IsContainTrue(const XMLString &value) const
{
  return 0 == mtwcscasecmp(value.c_str(), _TEXT("yes")) ||
          0 == mtwcscasecmp(value.c_str(), _TEXT("y")) ||
          0 == mtwcscasecmp(value.c_str(), _TEXT("true")) ||
          0 == mtwcscasecmp(value.c_str(), _TEXT("t"));
}

bool CMSIXDefinitionObjectFactory::IsContainFalse(const XMLString &value) const
{
  return 0 == mtwcscasecmp(value.c_str(), _TEXT("no")) ||
               0 == mtwcscasecmp(value.c_str(), _TEXT("n")) ||
               0 == mtwcscasecmp(value.c_str(), _TEXT("false")) ||
               0 == mtwcscasecmp(value.c_str(), _TEXT("f"));
}

bool CMSIXDefinitionObjectFactory::ParseBoolValue(const XMLString &value, const string &tagName) const
{
  if (IsContainTrue(value)) return true;
  else if (IsContainFalse(value)) return false;
  else throw std::invalid_argument("Invalid content: '" + ascii(value) + "' in '" + tagName + "' tag");  
}

bool CMSIXDefinitionObjectFactory::WParseBoolValue(const XMLString &value, const XMLString &wTagName) const
{
    BSTR bstr = SysAllocString(wTagName.c_str());
    _bstr_t bstr1(bstr);
    std::string tagName(bstr1);
    SysFreeString(bstr);

  return ParseBoolValue(value, tagName);
}

VARIANT_BOOL CMSIXDefinitionObjectFactory::ConvertBoolToVariantBool(const bool value) const
{
  return value ? VARIANT_TRUE : VARIANT_FALSE;
}

void CMSIXDefinitionObjectFactory::CheckMandatoryTag(const string &gotTag, const string &expectedTag) const
{
  if (gotTag != expectedTag) 
  {
    throw std::invalid_argument("Expected mandatory '" + expectedTag + "' tag, but actualy '" + gotTag + "' tag");
  }	
}

void CMSIXDefinitionObjectFactory::CheckForAggregateTag(const XMLObject::Type &xmlType) const
{
  if (xmlType != XMLObject::AGGREGATE) 
  {
    throw std::invalid_argument("Tag has invalid contents");
  }	
}

bool CMSIXDefinitionObjectFactory::CheckArraySize(const int currentSize, const int size) const
{
	return currentSize < size;
}

void CMSIXDefinitionObjectFactory::CheckArraySize(const int currentSize, const int size, const string &expectedTag) const
{
  if (currentSize  >= size)
  {
    throw std::invalid_argument("Out of array size, but '" + expectedTag + "' tag is expected");
  }		    
}

//=== [END] Methods which are used in Parse() ===//

BOOL CMSIXDefinitionObjectFactory::ParseUniqueKeys(CMSIXDefinition & arDef, 
                                                   XMLObjectVector& arContents, 
                                                   int position)
{
   const char * functionName = "CMSIXDefinitionObjectFactory::ParseUniqueKeys";

   BOOL bOK = TRUE;

   int outerSize = arContents.GetEntries();

   while (position < outerSize) 
   {
      XMLObject* obj = arContents[position++];
      ASSERT(obj != NULL);

      if (obj->GetType() == XMLObject::AGGREGATE)
	   {
         XMLAggregate* parentAgg = static_cast<XMLAggregate *>(obj);
         std::string name(parentAgg->GetName());
      
         if (name == UNIQUEKEY_STR) 
         {
            int innerSize;
		      XMLObject *const * inner = parentAgg->GetContents(innerSize);
            ASSERT(inner != NULL);

            if (innerSize == 0) 
            {
               arDef.SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
										functionName,
										"<uniquekey> tag has zero elements");
               return FALSE;
            }
            
            std::string errorMessage;
            UniqueKey *uniqueKey = CreateUniqueKey(inner, innerSize, arDef, errorMessage);

            if (uniqueKey == NULL) 
            {
               arDef.SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
										functionName,
										errorMessage.c_str());
               return FALSE;
            }

            arDef.AddUniqueKeyToList(uniqueKey);
         }
	   }
   }

   return bOK;
}

UniqueKey* CMSIXDefinitionObjectFactory::CreateUniqueKey(XMLObject *const * xml, 
                                                         int size, 
                                                         CMSIXDefinition & arDef,
                                                         std::string &errorMessage) 
{
   UniqueKey* uniqueKey = NULL;
   int position = 0;
   vector<CMSIXProperties *> properties;
   CMSIXProperties *cMSIXProperties = NULL;
   XMLString uniqueKeyName;

   XMLObject *obj = xml[position++];
   ASSERT(obj != NULL);

   if (obj->GetType() != XMLObject::AGGREGATE)
   {
      errorMessage = "Invalid <" + std::string(UNIQUEKEY_STR) + "> tags";
      return uniqueKey;
   }

   // Must find <name> tag
   XMLAggregate* nameAgg = (XMLAggregate *) obj;
   std::string name(nameAgg->GetName());
   if (name != NAME_STR) 
   {
      errorMessage = "unrecognized tag <" + name + "> after <" + 
                     std::string(UNIQUEKEY_STR) + "> tag";

      return uniqueKey;
   }

   // Get the contents of <uniquekey>
   if (!nameAgg->GetDataContents(uniqueKeyName))
	{
		errorMessage = "tag <" + name + "> has invalid contents";
		return uniqueKey;
	}

   while (position < size) 
   {
      obj = xml[position++];
      ASSERT(obj != NULL);

      // Error if not an aggregate
      if (obj->GetType() != XMLObject::AGGREGATE)
      {
         errorMessage = "Invalid col tags";
         return uniqueKey;
      }

      // Can only be <col> tag
      XMLAggregate* columnAgg = (XMLAggregate *) obj;
      std::string name(columnAgg->GetName());
      if (name != COL_STR) 
      {
         errorMessage = "unrecognized tag <" + name + "> tag after " + 
                        std::string(UNIQUEKEY_STR) + " tag";

         return uniqueKey;
      }

      XMLString propertyName;
      // Error if <col></col> contents can't be retrieved
      if (!columnAgg->GetDataContents(propertyName))
		{
			errorMessage = "tag <" + name + "> has invalid contents";
			return uniqueKey;
		}

      // Error if no property matching propertyName is found
      BOOL foundProperty = 
         arDef.FindProperty(propertyName, cMSIXProperties);

      if (!foundProperty) 
      {
         errorMessage = "no ptype found for <col> '" + 
                        ascii(propertyName) + "' for unique key '" +
								ascii(uniqueKeyName) + "'";
			return uniqueKey;
      }

      // Error if this <col> data is not unique for this <uniquekey>
      for (int i = 0; i < (int)properties.size(); ++i) 
      {
         CMSIXProperties *tempCMSIXProperties = properties[i];
         ASSERT(tempCMSIXProperties != NULL);

         if (tempCMSIXProperties->GetDN() == propertyName) 
         {
            errorMessage = "duplicate col name '" + ascii(propertyName) + "' found";
			   return uniqueKey;
         }
      }

      // Collect CMSIXProperties
      properties.push_back(cMSIXProperties);
   }

   // Must have atleast one <col>
   if (properties.size() == 0) 
   {
      errorMessage = "no col names found";
	   return uniqueKey;
   }

   // Create and initialize UniqueKey
   uniqueKey = new UniqueKey();
   uniqueKey->SetName(uniqueKeyName.c_str());

   for (int i = 0; i < (int)properties.size(); ++i) 
   {
      CMSIXProperties *tempCMSIXProperties = properties[i];
      ASSERT(tempCMSIXProperties != NULL);

      uniqueKey->AddColumnProperty(tempCMSIXProperties);
   }

   return uniqueKey;
}

