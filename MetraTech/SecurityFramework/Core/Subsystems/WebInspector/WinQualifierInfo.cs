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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinQualifierInfo
    {
        #region Public properties

        [SerializeProperty]
        public string AppPath { get; set; }

        [SerializeProperty]
        public bool UseResourceQualifiers { get; set; }

        [SerializeProperty]
        public bool ExcludeResourceMode { get; set; }

        [SerializeCollection(ElementName = "item", ElementType = typeof (string))]
        public List<string> Resources { get; set; }

        [SerializeCollection(ElementName = "item", ElementType = typeof (string))]
        public List<string> Extensions { get; set; }

        #endregion

        #region Constructors

        public WinQualifierInfo()
        {
            AppPath = "/";
            UseResourceQualifiers = false;
            ExcludeResourceMode = true;
            Resources = new List<string>();
            Extensions = new List<string>();
        }

        #endregion
    }
}