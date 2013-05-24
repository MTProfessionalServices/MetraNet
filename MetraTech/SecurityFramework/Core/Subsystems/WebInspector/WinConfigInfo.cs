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
using System.Configuration;
using System.IO;
//using System.Web.Script.Serialization;


namespace MetraTech.SecurityFramework.WebInspector
{
    internal class WinConfigInfo : ConfigurationSection
    {
        private const string SfWinSection = "SfWinSettings";
        private const string winPropsLocationProperty = "WinPropsLocation";
        private const string sfPropsLocationProperty = "SfPropsLocation";

        private static volatile WinPropertiesInfo _properties = null;
        private static readonly object _locker = new object();

        private static WinConfigInfo _instance =
                    ConfigurationManager.GetSection(SfWinSection) as WinConfigInfo;

        public static WinConfigInfo Instance
        {
            get {return _instance;}
        }

        [ConfigurationProperty(winPropsLocationProperty, IsRequired = true)]
        public string WinPropsLocation
        {
            get
            {
                return (string)this[winPropsLocationProperty];
            }
        }

        [ConfigurationProperty(sfPropsLocationProperty, IsRequired = true)]
        public string SfPropsLocation
        {
            get
            {
                return (string)this[sfPropsLocationProperty];
            }
        }

        public static WinPropertiesInfo GetProperties(string winPropsLocation)
        {
            if (_properties == null)
            {
                lock (_locker)
                {
                    if (null == _properties)
                    {
                        _properties = LoadProperties(winPropsLocation);
                    }

                }
            }

            return _properties;
        }

        private static WinPropertiesInfo LoadProperties(string winPropsLocation)
        {
            WinPropertiesInfo props = null;
          //SECENG  
					/*if (string.IsNullOrEmpty(winPropsLocation))
                throw new ApplicationException("Missing SF WIN properties store location");

            if (File.Exists(winPropsLocation))
            {
                List<string> parseErrors = new List<string>();

                try
                {
                    using (StreamReader textStream = File.OpenText(winPropsLocation))
                    {
                        string propsData = textStream.ReadToEnd();
                        if (string.IsNullOrEmpty(propsData))
                            throw new ApplicationException(String.Format("Empty SF WIN properties '{0}'", winPropsLocation));

                        JavaScriptSerializer jsonLoader = new JavaScriptSerializer();
                        props = jsonLoader.Deserialize<WinPropertiesInfo>(propsData);

                        if (null == props)
                            throw new ApplicationException(String.Format("Could not load SF WIN properties '{0}'", winPropsLocation));
                    }
                }
                catch (Exception x)
                {
                    string report = "Could not load SF WIN properties = " + winPropsLocation + " \n" + x.Message; 
                    if (parseErrors.Count > 0)
                    {
                        foreach (string pe in parseErrors)
                        {
                            report += "\n" + pe;
                        }
                    }

                    throw new ApplicationException(report);
                }
            }
            else
            {
                throw new ApplicationException(
                    String.Format("Could not find SF WIN properties '{0}'", winPropsLocation));
            }*/
            return props;
        }
    }
}
