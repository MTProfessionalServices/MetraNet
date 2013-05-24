/**************************************************************************
 * @doc MSIXDefinitionObjectFactory
 * 
 * @module  
 * 
 * This class encapsulates the insertion or removal of Service Properties
 * from the database. All access to Service Properties should be done 
 * through this class.
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
 * $Header$
 *
 * @index | MSIXDefinitionObjectFactory
 ***************************************************************************/

#ifndef _MSIXDEFINITIONOBJECTFACTORY_H_
#define _MSIXDEFINITIONOBJECTFACTORY_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include <string>

class CCodeLookup;

// DY:  do i need both -- probably not
#include <XMLParser.h>	// to get parser definitions

#include <MSIXDefinition.h>



#undef DLL_EXPORT
#define DLL_EXPORT		__declspec (dllexport)

// class that can read service definitions

// need to inherit from XMLObjectFactory for purposes of extending
// the functionality
class CMSIXDefinitionObjectFactory : 
  public XMLObjectFactory
{
	public:

		// @cmember Constructor
		CMSIXDefinitionObjectFactory();
		  
		// @cmember Destructor
		virtual ~CMSIXDefinitionObjectFactory();

		// Constructors

		// Copy Constructor
		CMSIXDefinitionObjectFactory (const CMSIXDefinitionObjectFactory& C);	

		// Assignment operator
		const CMSIXDefinitionObjectFactory& CMSIXDefinitionObjectFactory::operator=(const CMSIXDefinitionObjectFactory& rhs);

		// @cmember,mfunc Hook to create an aggregate.
		//  @@parm tag name
		//  @@parm name -> value map of attributes
		//  @@parm contents of the aggregate
		//  @@rdesc object
		virtual XMLObject* CreateAggregate (
				const char * apName,
				XMLNameValueMap& apAttributes,
				XMLObjectVector& arContents);

		// ---
		XMLObject * CreateData(const char * apData, int aLen,BOOL bCdataSection);


	// method to parse
	virtual BOOL Parse (CMSIXDefinition & arDef, XMLObjectVector& arContents, XMLNameValueMap& apAttributes);

   virtual BOOL ParseUniqueKeys(CMSIXDefinition & arDef, 
                                XMLObjectVector& arContents, 
                                int position);

protected:
	// override to create an object of the appropriate type
	virtual CMSIXDefinition * CreateDefinition()
	{ return new CMSIXDefinition; }

private:
   UniqueKey *CreateUniqueKey(XMLObject *const * xml, 
                              int size, 
                              CMSIXDefinition & arDef,
                              std::string &errorMessage);

   // For Parse() method
   bool IsContainTag(XMLObject* xmlObj, const string &expectedTagName) const;
   void CheckForAggregateTag(const XMLObject::Type &xmlType) const;
   void CheckMandatoryTag(const string &gotTag, const string &expectedTag) const;
   bool CheckArraySize(const int currentSize, const int size) const;
   void CheckArraySize(const int currentSize, const int size, const string &expectedTag) const;
   wstring GetValueFromContent(XMLAggregate* parentAgg, const string &tagName) const;   
   wstring GetValueFromXmlContent(XMLObject* xmlObj, const string &expectedTagName) const;
   bool IsContainTrue(const XMLString &value) const;
   bool IsContainFalse(const XMLString &value) const;
   bool ParseBoolValue(const XMLString &value, const string &tagName) const;
   bool WParseBoolValue(const XMLString &value, const XMLString &wTagName) const;
   VARIANT_BOOL ConvertBoolToVariantBool(const bool value) const;   
};


#endif // _MSIXDEFINITIONOBJECTFACTORY_H_

