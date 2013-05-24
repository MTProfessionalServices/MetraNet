/**************************************************************************
* Copyright 1997-2010 by MetraTech
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
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor.SQLite
{
	/// <summary>
	/// Provides utility methods to work with SQLite database.
	/// </summary>
	public static class SQLiteHelper
	{
		private const string ConnectionStringFormat = "data source=\"{0}\";FailIfMissing=False;Legacy Format=False;Cache Size=65536;";

		public static string CreateConnectionString(string databaseFileName)
		{
			string physicalPath = ExecutionContextFactory.Context.MapPath(databaseFileName);
			string result = string.Format(ConnectionStringFormat, physicalPath);

			return result;
		}
	}
}