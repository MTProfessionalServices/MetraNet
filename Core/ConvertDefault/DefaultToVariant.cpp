/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#include <metra.h>
#include <DefaultToVariant.h>
#include <mtprogids.h>
#include <xmlconfig.h>
#include <DBConstants.h>
#include <MTDec.h>

#import <MTEnumConfig.tlb>
#import <NameID.tlb>

BOOL DefaultConversion::ConvertDefaultStrToVariant(const CMSIXProperties& arMSIXProp ,_variant_t& arDefaultVal)
{

	wstring defaultValStr = arMSIXProp.GetDefault();
	CMSIXProperties::PropertyType msixType = arMSIXProp.GetPropertyType();

	arDefaultVal.ChangeType(VT_EMPTY);
	
	//if no default is provided then leave the variant's type as VT_EMPTY
	//except in the case of enums since we don't want the join to fail later
	//when they get automatically localized
	if ((defaultValStr.length() == 0) && (msixType != CMSIXProperties::TYPE_ENUM))
		return TRUE;
	
	switch (msixType) {
		
	case CMSIXProperties::TYPE_INT32: {
		int intVal;
		if (!XMLConfigNameVal::ConvertToInteger(defaultValStr, &intVal))
			return FALSE;
		arDefaultVal = (long) intVal;
		break;
	}
	
	case CMSIXProperties::TYPE_INT64: {
		__int64 int64Val;
		if (!XMLConfigNameVal::ConvertToBigInteger(defaultValStr, &int64Val))
			return FALSE;
		arDefaultVal = int64Val;
		break;
	}
	
	case CMSIXProperties::TYPE_FLOAT:
	case CMSIXProperties::TYPE_DOUBLE: {
		double doubleVal;		
		if (!XMLConfigNameVal::ConvertToDouble(defaultValStr, &doubleVal)) 
			return FALSE;
		arDefaultVal = doubleVal;
		break;
	}
	case CMSIXProperties::TYPE_DECIMAL: {
		MTDecimalVal decimalVal;		
		if (!XMLConfigNameVal::ConvertToDecimal(defaultValStr.c_str(), &decimalVal)) 
			return FALSE;
		arDefaultVal = DECIMAL(MTDecimal(decimalVal));
		break;
	}
	
	case CMSIXProperties::TYPE_TIMESTAMP: {
		DATE dateVal;
		time_t dateValAnsi;
		
		if (!XMLConfigNameVal::ConvertToDateTime(defaultValStr, &dateValAnsi))
			return FALSE;
		
		//converts from time_t to OLE DATE object
		OleDateFromTimet(&dateVal, dateValAnsi);
		{
			_variant_t temp(dateVal, VT_DATE);
			arDefaultVal = temp;
		}
		break;		
	}
	
	case CMSIXProperties::TYPE_BOOLEAN: {
		BOOL boolVal;
		if (!XMLConfigNameVal::ConvertToBoolean(defaultValStr, &boolVal))
			return FALSE;
		if (boolVal)
			defaultValStr = DB_BOOLEAN_TRUE;  
		else
			defaultValStr = DB_BOOLEAN_FALSE;   
	}
	
	//CAUTION !!!!
	//case TYPE_BOOLEAN is meant to fall through to the TYPE_STRING case below
	//CAUTION !!!!
	
	case CMSIXProperties::TYPE_STRING:
	case CMSIXProperties::TYPE_WIDESTRING: {
		arDefaultVal = defaultValStr.c_str();
		break;
	}
	
	
	case CMSIXProperties::TYPE_ENUM: {
		_bstr_t enumSpace, enumType, enumVal, FQN;
		
		//if there was no default value, then use the special
		//blank description id (0) so that the GetProductView joins still work
		if (defaultValStr.length() == 0) {
			arDefaultVal = (long) 0;
			break;
		}
		
		enumSpace = arMSIXProp.GetEnumNamespace().c_str();
		enumType = arMSIXProp.GetEnumEnumeration().c_str();
		enumVal = defaultValStr.c_str();

		MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig(MTPROGID_ENUM_CONFIG);

		FQN = aEnumConfig->GetFQN(enumSpace, enumType, enumVal);
		
		if(FQN.length() == 0) {
			char buff[1024];
			sprintf(buff,"Enumeration %s/%s/%s not found in enum collection.",(const char*)enumSpace, (const char*)enumType, (const char*)enumVal);
			SetError(FALSE,"DefaultConversion",ERROR_LINE,"ConvertDefaultStrToVariant",buff);
			return FALSE;
		}
		NAMEIDLib::IMTNameIDPtr aNameID(MTPROGID_NAMEID);
		arDefaultVal = (long) aNameID->GetNameID((const wchar_t *)FQN);
		break;
	}
	
	default: 
		SetError(FALSE,"DefaultConversion",ERROR_LINE,"ConvertDefaultStrToVariant","Unsupported MSIX type for default value");
		return FALSE;
	}

	return TRUE;
}
