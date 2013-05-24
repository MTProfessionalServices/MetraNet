/**************************************************************************
* Copyright 1997-2010 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* Your Name <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System;
using System.ComponentModel;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Common.Configuration
{
    /// <summary>
    /// This class for initialising of subsystem
    /// </summary>
	public class LoadItem
    {
		public LoadItem()
		{ }

        private bool _isService = false;
		
        /// <summary>
        /// Gets or sets name of subsystem
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, DefaultType = typeof(string), MappedName = "Name")]
		internal string Name
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets ID of subsystem
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, DefaultType = typeof(Guid), MappedName = "Id")]
		public Guid Id
		{
			get;
			set;
		}

        /// <summary>
        /// Gets or sets path to configuration-file of subsystem
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, DefaultType = typeof(string), MappedName = "Path")]
		public string Path { get; set; }

        /// <summary>
        /// Gets or sets Type of subsystem propertie class
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, DefaultType = typeof(string), MappedName = "Type")]
        public string Type { get; set; }

        /// <summary>
        /// Gets or sets Type of subsystem
		/// </summary>
		[SerializePropertyAttribute(IsRequired = false, DefaultType = typeof(string), MappedName = "SubsystemType")]
        public string SubsystemType { get; set; }

        /// <summary>
        /// Gets or sets availability of subsystem
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, DefaultType = typeof(bool), MappedName = "IsEnabled")]
        public bool IsEnabled { get; set; } 

        /// <summary>
        /// Gets or sets priority subsystem
		/// </summary>
		[SerializePropertyAttribute(IsRequired = false, DefaultType = typeof(bool), MappedName = "IsServiceSubsystem")]
		public bool IsServiceSubsystem
        {
            get { return _isService; }
            set { _isService = value; }
        }
    }
}
