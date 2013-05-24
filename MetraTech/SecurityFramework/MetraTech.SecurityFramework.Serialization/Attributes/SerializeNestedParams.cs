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
* <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.ComponentModel;

namespace MetraTech.SecurityFramework.Serialization.Attributes
{
	/// <summary>
	/// Contains parameters of serialize attribute, if source data is external.
	/// </summary>
	public class SerializeNestedParams : SerializeParams
	{
		/// <summary>
		/// Path to external source
		/// </summary>
		public string PathToSource
		{
			get;
			set;
		}

		/// <summary>
		/// Serializer type for current property.
		/// </summary>
		public string SerializerTypeName
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets path type to source file
		/// </summary>
		public PathType PathType
		{
			get;
			set;
		}

		/// <summary>
		/// Gets path name to directory with source configuration.
		/// </summary>
		public string NestedPath
		{
			get;
			set;
		}

		/// <summary>
		/// Sets serialization parameters from reflector object.
		/// </summary>
		public void SetNestedParams(ObjectReflector reflector)
		{
      if (reflector == null)
      {
        throw new ArgumentNullException("reflector");
      }

      try
      {
        PropertyInfo[] infos = this.GetType().GetProperties();

        foreach (KeyValuePair<string, string> pair in reflector.ValueProps)
        {
          PropertyInfo info = infos.
                      Where(p =>
                      string.Compare(p != null ? p.Name : null, pair.Key, true, System.Globalization.CultureInfo.InvariantCulture) == 0)
                      .FirstOrDefault();

          if (info == null)
          {
            throw new SerializationException(string.Format("Type \"{0}\" does not contain a property with name \"{1}\"", this.GetType().FullName, pair.Key));
          }

          TypeConverter converter = TypeDescriptor.GetConverter(info.PropertyType);

          object value = converter.ConvertFromInvariantString(pair.Value);

          if (value == null)
          {
            throw new SerializationException(string.Format("Serializtion parameter {0} is null!", pair.Key));
          }

          info.SetValue(this, value, null);
        }
      }
      catch (Exception)
      {
        throw;
      }
		}
	}
}
