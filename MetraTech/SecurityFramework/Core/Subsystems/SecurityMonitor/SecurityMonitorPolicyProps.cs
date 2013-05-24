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
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Xml;
using System.IO;


namespace MetraTech.SecurityFramework
{
    public sealed class SecurityMonitorPolicyProps
    {
        #region Nested Classes
        public sealed class PolicyProperty
        {
            public string Name
            {
                get;
                set;
            }

            public string Value
            {
                get;
                set;
            }
        }
        #endregion

        #region Public Fields
        public string mId
        {
            get;
            set;
        }

        public PolicyProperty[] Properties
        {
            get { return _properties; }
            set { _properties = value; }
        }
        #endregion

        #region Private Fields

        private PolicyProperty[] _properties;

        #endregion
    }
}
