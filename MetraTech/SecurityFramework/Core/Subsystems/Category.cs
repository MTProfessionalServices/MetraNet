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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using System;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Subsystem's category
    /// </summary>
    internal class Category
    {
        public Category(string categoryName)
        {
            CategoryName = categoryName;
            DefaultEngine = null;
        }

        /// <summary>
        /// Category Name
        /// </summary>
        public string CategoryName { get; private set; }

        private IEngine _defaultEngine = null;

        /// <summary>
        /// Gets default engine for this category.
        /// </summary>
        public IEngine DefaultEngine
        {
            get { return _defaultEngine; }
            set
            {
                if (value != null && value.CategoryName != CategoryName)
                    throw new SubsystemInputParamException(String.Format("Can't set an engine as default for \"{0}\" category. Engine wich tried to set as default has category name is \"{1}\" and Id is {2}.",
                            CategoryName, value.CategoryName, value.Id));

                _defaultEngine = value;
            }
        }
    }
}
