/**************************************************************************
* Copyright 1997-2011 by MetraTech.SecurityFramework
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
using System.Text;
using System.IO;
using System.Reflection;

namespace MetraTech.SecurityFramework.Serialization
{
	/// <summary>
	/// Provides a wrapper for different type of serializers.
	/// </summary>
	internal static class SerializeWrapper
	{
		/// <summary>
		/// Checked serilizaer type and serializes from object received in "deserializeObject"-parameter.
		/// </summary>
		public static void Serialize(string serializerTypeName, object serializeObject, string pathToSource)
		{
			switch (serializerTypeName)
			{
				case "DotNetXmlSerializer":
					DotNetSerialize(serializeObject, pathToSource);
					break;
				case "MtSfXmlSerializer":
					Type serializerType = typeof(XmlSerializer);
					MtSfSerialize(serializerType, serializeObject, pathToSource);
					break;
				default: 
					string msg = string.Format("Serializer type {0} is not declared.", serializerTypeName);
					throw new SerializationException(msg);
			}
		}

		/// <summary>
		/// Checked serilizaer type and deserializes to object type received in "objectType"-parameter.
		/// </summary>
		public static object Deserialize(string serializerTypeName, string pathToSource, Type objectType)
		{
			object result = null;

			switch (serializerTypeName)
			{
				case "DotNetXmlSerializer":
					result = DotNetXmlDeserialize(pathToSource, objectType);
					break;
				case "MtSfXmlSerializer":
					result = MtSfDeserialize(typeof(XmlSerializer), pathToSource, objectType);
					break;
				default:
					string msg = string.Format("Serializer type {0} is not declared.", serializerTypeName);
					throw new SerializationException(msg);
			}

			return result;
		}

		private static void DotNetSerialize(object serializeObject, string pathToSource)
		{
			System.Xml.Serialization.XmlSerializer xmlSerializer = new System.Xml.Serialization.XmlSerializer(serializeObject.GetType());
			System.Xml.Serialization.XmlSerializerNamespaces nameSpaces = new System.Xml.Serialization.XmlSerializerNamespaces();
			nameSpaces.Add(string.Empty, string.Empty);
			using (Stream stream = File.Open(pathToSource, FileMode.Truncate, FileAccess.Write, FileShare.ReadWrite))
			{
				xmlSerializer.Serialize(stream, serializeObject, nameSpaces);
			}
		}

		private static void MtSfSerialize(Type serializerType, object serializeObject, string pathToSource)
		{
			ISerializer serializer = ((ISerializer)serializerType.InvokeMember(serializerType.FullName, BindingFlags.CreateInstance, null, null, null));
			serializer.Serialize(serializeObject, pathToSource);
		}

		private static object DotNetXmlDeserialize(string pathToSource, Type objectType)
		{
			object result = null;
			System.Xml.Serialization.XmlSerializer xmlSerializer = new System.Xml.Serialization.XmlSerializer(objectType);
			using (Stream stream = File.Open(pathToSource, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			{
				result = xmlSerializer.Deserialize(stream);
			}

			return result;
		}

		private static object MtSfDeserialize(Type serializerType, string pathToSource, Type objectType)
		{
			object result = null;
			ISerializer serializer = ((ISerializer)serializerType.InvokeMember(serializerType.FullName, BindingFlags.CreateInstance, null, null, null));
			result = serializer.Deserialize(objectType, null, pathToSource);
			return result;
		}
	}
}
