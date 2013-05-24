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
    [XmlRoot("SecurityFramework")]
    public sealed class SecurityKernelProps
    {
        #region Nested Classes
        public sealed class SubsystemProps
        {
            [XmlElement("Name")]
            public string mName;

            [XmlElement("IsEnabled")]
            public bool mIsEnabled;

            [XmlElement("PropsStoreLocation")]
            public string mPropsStoreLocation;

            public SubsystemProps()
            {}

            public SubsystemProps(string name, string propsStoreLocation)
            {
                mName = name;
                mPropsStoreLocation = propsStoreLocation;
            }
        }
        #endregion

        #region Public Fields
        [XmlElement("Id")]
        public string mId;

        [XmlElement("Signature")]
        public string mSignature;

        [XmlArray("Subsystems")]
        [XmlArrayItem("Subsystem")]
        public SubsystemProps[] mSubsystems;
        #endregion

        #region Public Methods

        public SecurityKernelProps()
        {
            mPropsStoreLocation = "MtSecurityFramework.xml";
        }

        private SecurityKernelProps(string propsStoreLocation)
        {
            if(string.IsNullOrEmpty(propsStoreLocation))
                mPropsStoreLocation = "MtSecurityFramework.xml";
            else
                mPropsStoreLocation = propsStoreLocation;
        }

        internal static SecurityKernelProps Get(string location)
        {
            if (mInstance == null)
            {
                lock (mLocker)
                {
                    if (null == mInstance)
                    {
                        mInstance = new SecurityKernelProps(location);
                        mInstance.Load();
                    }

                }
            }

            return mInstance;
        }
        #endregion

        #region Private Methods
        private void Load()
        {
            if (string.IsNullOrEmpty(mPropsStoreLocation))
                throw new SecurityFrameworkException("Missing SF store location");

            SecurityKernelProps props = null;
            if (File.Exists(mPropsStoreLocation))
            {
                using (FileStream fileStream =
                    File.Open(mPropsStoreLocation, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                {
                    XmlSerializer serializer = new XmlSerializer(typeof(SecurityKernelProps));
                    props = (SecurityKernelProps)serializer.Deserialize(fileStream);

                    mId = props.mId;
                    mSignature = props.mSignature;
                    mSubsystems = props.mSubsystems;
                }
            }
            else
            {
				throw new SecurityFrameworkException(
                    String.Format("Could not find Security Framework properties '{0}'", mPropsStoreLocation));
            }
        }
        #endregion

        #region Private Fields
        [NonSerialized]
        private string mPropsStoreLocation;
        [NonSerialized]
        private static volatile SecurityKernelProps mInstance;
        [NonSerialized]
        private static readonly object mLocker = new object();
        #endregion
    }
}
