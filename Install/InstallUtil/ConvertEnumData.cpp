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
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Travis Gebhardt
 *
 * $Date$
 * $Author$
 * $Revision$
 */


#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <autoinstance.h>
#include <MTUtil.h>
#include <SharedDefs.h>
#include <mtprogids.h>
#include <DBConstants.h>

extern MTAutoInstance<InstallLogger> g_Logger;

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 


BOOL InstCallConvention ConvertEnumData() 
{
	try 
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("upgrade\\V13to20");

		g_Logger->LogVarArgs(LOG_DEBUG, "ConvertEnumData: insert t_enum_data IDs into t_mt_id table");

		rowset->SetQueryTag("__CONVERT_T_ENUM_DATA_TABLE__");
		rowset->Execute();

		g_Logger->LogVarArgs(LOG_DEBUG, "ConvertEnumData: SUCCESS!!!");

	} catch (_com_error& e) {
		g_Logger->LogVarArgs(LOG_ERROR, "A COM exception occured in ConvertEnumData! error %x", e.Error());
		return FALSE;
	}

	return TRUE;
}
