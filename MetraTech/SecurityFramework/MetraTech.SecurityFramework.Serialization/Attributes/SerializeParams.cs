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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;

namespace MetraTech.SecurityFramework.Serialization.Attributes
{
	/// <summary>
	/// Contains parameters of serialize attribute
	/// </summary>
	public abstract class SerializeParams
	{
		/// <summary>
		/// Gets or sets name of property in xml document
		/// </summary>
		public string MappedName
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets required of property
		/// </summary>
		public bool IsRequired
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets default type of property
		/// </summary>
		public Type DefaultType
		{
			get;
			set;
		}

		/// <summary>
		/// Gets parameters from SerializeAttribute in property info
		/// </summary>
		public static SerializeParams GetParameters(PropertyInfo info)
		{
			SerializeAttribute attribute = ((SerializeAttribute)info.GetCustomAttributes(typeof(SerializeAttribute), true)[0]);
			SerializeParams parameters = null;
			if (attribute is SerializePropertyAttribute)
			{
				parameters = new SerializePropertyParams();
				((SerializePropertyParams)parameters).DefaultValue = ((SerializePropertyAttribute)attribute).DefaultValue;
			}

			SerializeCollectionAttribute collectionAttribute;
			if((collectionAttribute = attribute as SerializeCollectionAttribute) != null)
			{
				SerializeCollectionParams collectionParameters = new SerializeCollectionParams();

				//Sets params to parameter-object if attribute type is SerializeCollectionAttribute

				if (string.IsNullOrEmpty(collectionAttribute.ElementName))
				{
					collectionParameters.ElementName = "item";
				}
				else
				{
					collectionParameters.ElementName = collectionAttribute.ElementName;
				}

				if (collectionAttribute.ElementType == null)
				{
					collectionParameters.ElementType = info.PropertyType.GetElementType();
				}
				else
				{
					collectionParameters.ElementType = collectionAttribute.ElementType;
				}

				parameters = collectionParameters;
			}

			SerializeNestedAttribute nestedAttribute;
			if ((nestedAttribute = attribute as SerializeNestedAttribute) != null)
			{
				SerializeNestedParams nestedParameters = new SerializeNestedParams();
				nestedParameters.PathToSource = nestedAttribute.PathToSource;
				nestedParameters.SerializerTypeName = nestedAttribute.SerializerTypeName;
				nestedParameters.PathType = nestedAttribute.PathType;
				nestedParameters.NestedPath = nestedAttribute.NestedPath;
				parameters = nestedParameters;
			}

			//Sets common params to parameter-object

			parameters.IsRequired = attribute.IsRequired;

			if (string.IsNullOrEmpty(attribute.MappedName))
			{
				parameters.MappedName = info.Name;
			}
			else
			{
				parameters.MappedName = attribute.MappedName;
			}

			if (attribute.DefaultType == null)
			{
				parameters.DefaultType = info.PropertyType;
			}
			else
			{
				parameters.DefaultType = attribute.DefaultType;
			}

			return parameters;
		}
	}
}
