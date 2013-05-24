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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Represents a configuration for CSV file recorder.
    /// </summary>
    public class CsvFileRecorderDefinitionProperties : EventRecorderDefinitionProperties
    {
        /// <summary>
        /// Gets or sets a name of the log file.
        /// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string LogFileName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a value indicating that a log file will be copied with another name each day.
		/// </summary>
		[SerializePropertyAttribute]
        public bool RollFileName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a list of column definitions.
		/// </summary>
		[SerializeCollectionAttribute(IsRequired = true)]
		public TableColumn[] Columns
        {
            get;
            set;
        }

        /// <summary>
        /// Creates an instance of the <see cref="SecurityEventWriter"/>.
        /// </summary>
        /// <returns>An instance of the <see cref="CsvFileWriter"/> class.</returns>
        public override SecurityEventWriter CreateWriter()
        {
            SecurityEventWriter result = new CsvFileWriter(LogFileName, Columns, RollFileName);

            return result;
        }
    }
}
