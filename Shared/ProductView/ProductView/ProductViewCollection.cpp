/**************************************************************************
 * @doc ProductViewCollection
 * 
 * @module  Encapsulation for Database Product Property |
 * 
 * This class encapsulates the insertion or removal of Product Properties
 * from the database. All access to ProductViewCollection should be done through this 
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
 * $Header$
 *
 * @index | ProductViewCollection
 ***************************************************************************/


// includes
#include <metra.h>
#include <ProductViewCollection.h>
#include <MTUtil.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <reservedproperties.h>

#include <mtglobal_msg.h>
#include <string>

#import <MTConfigLib.tlb>
#import <MTProductView.tlb> rename ("EOF", "RowsetEOF")  no_function_mapping
#import <MTProductViewExec.tlb> rename ("EOF", "RowsetEOF")  no_function_mapping
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset; using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr; using MTProductCatalogInterfacesLib::IMTPropertyMetaData;") no_function_mapping

using std::string;
using std::wstring;

using namespace std;

static const wchar_t * PVReservedProps[] = 
{
	MT_PVVIEWID,
	MT_PVSESSIONID,
	MT_PVAMOUNT,
	MT_PVDISPLAYAMOUNT,
	MT_PVPREBILLADJUSTMENTAMOUNT,
	MT_PVPOSTBILLADJUSTMENTAMOUNT,
	MT_PVTAXAMOUNT,
	MT_PVAMOUNTWITHTAX,
	MT_PVCURRENCY,
	MT_PVACCOUNTID,
	MT_PVPAYEEDISPLAYNAME,
	MT_PVTIMESTAMP,
	MT_PVSEDISPLAYNAME,
	NULL
};

//	@mfunc Constructor. Initialize the data members.
//  @rdesc 
//  No return value
CProductViewCollection::CProductViewCollection()
{
	SetPath(PRODUCT_VIEW_CONFIG_PATH);
	SetIndexFile(PRODUCT_VIEW_XML_FILE);
}

BOOL CProductViewCollection::Initialize(const wchar_t* xmlfilename /* = NULL */)
{
	const char * functionName = "CProductViewCollection::Initialize";
	const wchar_t* pProductViewDir = L"productview";
	BOOL bRetVal;

	if (xmlfilename)
  {
		wstring szTemp(pProductViewDir);
		szTemp += L"\\";
		szTemp += xmlfilename;
		// FAlSE indicates we are looking for a specific file
		bRetVal	= MSIXDefCollection::Initialize(szTemp.c_str(), FALSE);
	}
	else
		bRetVal	= MSIXDefCollection::Initialize(pProductViewDir);

	if(!bRetVal) return FALSE;

	// post initialization
	if (!mCreator.Initialize())
	{
		SetError(mCreator);
		return FALSE;
	}

	MSIXDefCollection::MSIXDefinitionList & lst = GetDefList(); 
	list<CMSIXDefinition *>::iterator it;
	for (it = lst.begin(); it != lst.end(); it++)
	{
		CMSIXDefinition * def = *it;
		if (!(Validate(def) && ValidatePVReservedProps(def)))
			return FALSE;
		def->CalculateTableName(PV_TABLE_PREFIX);

		// compute the checksum by running MD5 on the SQL statement to create the table.
		// this doesn't change if things like whitespace change in the config file
    // We set the last param to "false" because we want to preserve internal types like
    // enum and bool when computing our checksum.
		wstring query;
		if (!mCreator.GenerateCreateTableQuery(*def, query, false /* Do not convertert internal types*/))
		{
			SetError(mCreator);
			return FALSE;
		}
	
		string checksum;
		if (!MTMiscUtil::ConvertStringToMD5(ascii(query).c_str(), checksum))
		{
			// should never fail
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,
							 "Unable to compute MD5 checksum");
			return FALSE;
		}

		// finally set the checksum
		def->SetChecksum(checksum.c_str());

		
  }
	return TRUE;
}


static const wchar_t * gReservedNames[] =
{
	MT_ACCOUNTID_PROP,
	MT_CURRENCY_PROP,
	MT_AMOUNT_PROP,
	MT_TIMESTAMP_PROP,
	MT_METEREDTIMESTAMP_PROP,
	MT_PRODUCTVIEWID_PROP,
	MT_PRODUCTID_PROP,
	MT_SERVICEID_PROP,
	MT_FEEDBACKMETERID_PROP,
	MT_IPADDRESS_PROP,
	MT_FEDTAX_PROP,
	MT_STATETAX_PROP,
	MT_COUNTYTAX_PROP,
	MT_LOCALTAX_PROP,
	MT_OTHERTAX_PROP,
	MT_PROFILESTAGE_PROP,
	MT_INTERVALID_PROP,
	MT_NEWPARENTID_PROP,
	MT_NEWPARENTINTERNALID_PROP,
	MT_COLLECTIONID_PROP,
	NULL
};

BOOL CProductViewCollection::Validate(CMSIXDefinition * apDef)
{
	const char * functionName = "CMSIXDefinition::Setup";

	// TODO: should move call to calculatetablename in here.

	// return failure if this product view has any reserved properties 
	MSIXPropertiesList & props = apDef->GetMSIXPropertiesList();

	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * serviceProp = *it;

		const wstring & name = serviceProp->GetDN();

		for (int i = 0; gReservedNames[i]; i++)
		{
			wstring temp = gReservedNames[i];
			if (_stricmp(ascii(name).c_str(),ascii(temp).c_str()) == 0)
			{
				string buffer("Product view ");
				buffer += ascii(apDef->GetName());
				buffer += " contains reserved property ";
				buffer += ascii(name);
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, buffer.c_str());
				return FALSE;
			}
		}
	}
	return TRUE;
}



BOOL CProductViewCollection::ValidatePVReservedProps(CMSIXDefinition * apDef)
{
	const char * functionName = "CMSIXDefinition::Setup";

	// TODO: ultimately the product view reserved properties would move in an xml file and a com object would give an interface for these reserved
	// properties which would also be used by MetraConfig.

	// return failure if this product view has any reserved properties 
	MSIXPropertiesList & props = apDef->GetMSIXPropertiesList();

	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * serviceProp = *it;

		const wstring & name = serviceProp->GetDN();
		string temp = ascii(name);
		const char *temp1 = temp.c_str();

		for (int i = 0; PVReservedProps[i]; i++)
		{
			wstring temp = PVReservedProps[i];
			if (_stricmp(ascii(name).c_str(),ascii(temp).c_str()) == 0)
			{
				string buffer("Product view ");
				buffer += ascii(apDef->GetName());
				buffer += " contains reserved property ";
				buffer += ascii(name);
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, buffer.c_str());
				return FALSE;
			}
		}
	}
	return TRUE;
}

//
//
//
BOOL
CProductViewCollection::CreateTables()
{
	mCreator.Initialize();

	MSIXDefCollection::MSIXDefinitionList & lst = GetDefList(); 
	list<CMSIXDefinition *>::iterator it;
	for (it = lst.begin(); it != lst.end(); it++)
	{
		// create the table
		if (!mCreator.SetupDatabase(**it))
		{
			SetError(mCreator);
			return (FALSE);
		}

    // create instance of new productview objects
    try {
      MTPRODUCTVIEWLib::IProductViewPtr pvPtr(__uuidof(MTPRODUCTVIEWLib::ProductView));
      pvPtr->Init((*it)->GetName().c_str(), VARIANT_FALSE);
      pvPtr->Save();
    }
    catch(_com_error& err) {
      SetError(CreateErrorFromComError(err));
      return FALSE;
    }
	}

	return (TRUE);
}

//
//
//
BOOL
CProductViewCollection::DropTables()
{
	mCreator.Initialize();

	MSIXDefCollection::MSIXDefinitionList & lst = GetDefList(); 
	list<CMSIXDefinition *>::iterator it;
	for (it = lst.begin(); it != lst.end(); it++ )
	{
		// drop the table
		if (!mCreator.CleanupDatabase(**it))
		{
			SetError(mCreator);
			return (FALSE);
		}
    try {
      MTPRODUCTVIEWLib::IProductViewCatalogPtr pvCatPtr(__uuidof(MTPRODUCTVIEWLib::ProductViewCatalog));
			MTPRODUCTVIEWLib::IProductViewPtr pvPtr = pvCatPtr->GetProductViewByName((*it)->GetName().c_str());
			if (NULL != pvPtr.GetInterfacePtr())
			{
				pvCatPtr->RemoveProductView(pvPtr->GetID());
			}
    }
    catch(_com_error& err) {
      SetError(CreateErrorFromComError(err));
      return FALSE;
    }
	}

	return (TRUE);
}

//
//
//
BOOL
CProductViewCollection::InsertIntoPVLog()
{
	mCreator.Initialize();

	MSIXDefCollection::MSIXDefinitionList & lst = GetDefList(); 
	list<CMSIXDefinition *>::iterator it;
	for (it = lst.begin(); it != lst.end(); it++)
	{
		// insert into log 
		if (!mCreator.InsertIntoPVLog(**it))
		{
			SetError(mCreator);
			return (FALSE);
		}
	}

	return (TRUE);
}

//
//
//
BOOL
CProductViewCollection::UpdatePVLog(const char* arProductViewName,
																		const char* arChecksum)
{
	mCreator.Initialize();

	// insert into log 
	if (!mCreator.UpdatePVLog(arProductViewName, arChecksum))
	{
		SetError(mCreator);
		return (FALSE);
	}

	return (TRUE);
}

//
//
//
BOOL
CProductViewCollection::DeleteFromPVLog()
{
	mCreator.Initialize();

	MSIXDefCollection::MSIXDefinitionList & lst = GetDefList(); 
	list<CMSIXDefinition *>::iterator it;
	for (it = lst.begin(); it != lst.end(); it++ )
	{
		// delete from log
		if (!mCreator.DeleteFromPVLog(**it))
		{
			SetError(mCreator);
			return (FALSE);
		}
	}

	return (TRUE);
}



// TODO: this is only here because Usage server code calls it.  should try to
// eliminate it.
BOOL CProductViewCollection::GenerateCreateTableQuery(CMSIXDefinition & arDef,
																											wstring & langRequest)
{
	mCreator.Initialize();

	if (!mCreator.GenerateCreateTableQuery(arDef, langRequest))
	{
		SetError(mCreator);
		return FALSE;
	}

	return TRUE;
}


// TODO: this is only here because Usage server code calls it.  should try to
// eliminate it.
BOOL CProductViewCollection::GenerateInsertIntoPVLogQuery(CMSIXDefinition & arDef,
																													wstring & langRequest)
{
	mCreator.Initialize();

	if (!mCreator.GenerateInsertIntoPVLogQuery(arDef.GetName(), 
    arDef.GetChecksum(), langRequest))
	{
		SetError(mCreator);
		return FALSE;
	}

	return TRUE;
}





BOOL 
CProductViewCollection::FindProductView (const wstring &arName,
																				 CMSIXDefinition * & arpDef)
{
	return FindDefinition(arName, arpDef);
}

//
//
//
BOOL
CProductViewCollection::UpdateTables()
{
	mCreator.Initialize();

	MSIXDefCollection::MSIXDefinitionList & lst = GetDefList(); 
	list<CMSIXDefinition *>::iterator it;
	for (it = lst.begin(); it != lst.end(); it++ )
	{
		// drop the table
		if (!mCreator.CleanupDatabase(**it))
		{
			SetError(mCreator);
			return (FALSE);
		}
		// recreate the table
		if (!mCreator.SetupDatabase(**it))
		{
			SetError(mCreator);
			return (FALSE);
		}
		// update the corresponding product view image metadata in the database.  Do this by taking
		// the "before" image from the database and the "after" image from the .msixdef, comparing
		// them and generating a diff.
    try {
      MTPRODUCTVIEWLib::IProductViewCatalogPtr pvCatPtr(__uuidof(MTPRODUCTVIEWLib::ProductViewCatalog));
			MTPRODUCTVIEWLib::IProductViewPtr newPtr(__uuidof(MTPRODUCTVIEWLib::ProductView));
			newPtr->Init((*it)->GetName().c_str(), VARIANT_FALSE);
			MTPRODUCTVIEWLib::IProductViewPtr oldPtr = pvCatPtr->GetProductViewByName((*it)->GetName().c_str());
			if (NULL != oldPtr.GetInterfacePtr() && NULL != newPtr.GetInterfacePtr())
			{
				MetraTech_Pipeline::IProductViewUpdatePtr writer(__uuidof(MetraTech_Pipeline::ProductViewUpdate));
				writer->DiffAndUpdate(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(oldPtr->GetSessionContext().GetInterfacePtr()), 
															reinterpret_cast<MTPRODUCTVIEWEXECLib::IProductView*>(oldPtr.GetInterfacePtr()), 
															reinterpret_cast<MTPRODUCTVIEWEXECLib::IProductView*>(newPtr.GetInterfacePtr()));
			}
    }
    catch(_com_error& err) {
      SetError(CreateErrorFromComError(err));
      return FALSE;
    }
	}

	return (TRUE);
}

