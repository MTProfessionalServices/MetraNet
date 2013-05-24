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
* Viktor Grytsay <VGrytsay@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.Security;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
	public class DefaultObjectReferenceMapperEngine : ObjectReferenceMapperEngineBase
	{
        private object _syncRoot = new object();
        private ConfigurationParameters rcd = new ConfigurationParameters();

        /// <summary>
        /// Gets or internally sets a list of HTML named entities.
        /// </summary>
        [SerializeCollectionAttribute(ElementType = typeof(MetraTech_KeyValuePair<string, string>), ElementName = "Reference", IsRequired = true)]
        public MetraTech_KeyValuePair<string, string>[] References
        {
            get
            {
                return Id2ObjectMap.Select(p => new MetraTech_KeyValuePair<string, string>(p.Key, Convert.ToString(p.Value))).ToArray();
            }
            private set
            {
                lock (_syncRoot)
                {
                    this.Object2IdMap.Clear();
                    this.Id2ObjectMap.Clear();

                    if (value != null)
                    {
                        foreach (MetraTech_KeyValuePair<string, string> mapping in value)
                        {
                            // Replace predefined placeholders with configured values.
                            string mappedValue =
                                mapping.Pair.Value.Replace("/%InstDir/%", rcd.InstallDirectory).
                                Replace("/%ExtDir%/", rcd.ExtensionDirectory).
                                Replace("/%ConfigDir%/", rcd.ConfigurationDirectory);

                            this.AddRecord(mapping.Pair.Key, mappedValue);
                        }
                    }
                }
            }
        }

		public DefaultObjectReferenceMapperEngine()
			: base(ObjectReferenceMapperEngineCategory.Str)
		{ }

		protected override ApiOutput ProtectInternal(ApiInput input)
		{
            lock (_syncRoot)
            {
                string strInput = input.ToString();
                string result = HasRecordWithId(strInput) ? Convert.ToString(GetObject(strInput)) : string.Empty;

                return new ApiOutput(result);
            }			
		}
	}
}
