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
using System.Reflection;
using System.Linq;
using System.ComponentModel;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;
using System.Collections;
using System.Globalization;
using System.IO;

namespace MetraTech.SecurityFramework.Serialization
{
	/// <summary>
	/// This class includes common functionality for all kinds of serialization
	/// </summary>
	public abstract class SerializeSelector : ISerializer
	{
		#region Nested Classes

		/// <summary>
		/// This class to compare strings case insensitive
		/// </summary>
		public class CaseInsensitiveComparer : IComparer<string>
		{
			public int Compare(string x, string y)
			{
				return string.Compare(x, y, StringComparison.InvariantCultureIgnoreCase);
			}
		}

		public enum SerializePropertiesType
		{
			Composite,
			Collection,
			Value,
			NonValue,
			Nested,
			All
		}

		private static class Constants
		{
			public const string RealType = "RealType";
			public const string Value = "value";

			public const string SerializeParameterPathType = "PathType";
			public const string SerializeParameterPathToSource = "PathToSource";
			public const string SerializeParameterSerializerTypeName = "SerializerTypeName";
			public const string SerializeParameterNestedPath = "NestedPath";
		}

		#endregion

		#region Private fields

		private string _pathToSource = string.Empty;

		#endregion

		#region Public fields

		/// <summary>
		/// Path to source of serialization/deserialization
		/// </summary>
		public string PathToSource
		{
			private set
			{
				if (string.IsNullOrEmpty(value) == false)
				{
					_pathToSource = value;
				}
				else
				{
					ThrowException("Path to source file for deserialize is null or empty!", null, null);
				}
			}
			get
			{
				return _pathToSource;
			}
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Default constructor
		/// </summary>
		public SerializeSelector()
		{

		}

		#endregion

		#region Public methods

		/// <summary>
		/// Deserializes XML-document in object of a type T
		/// </summary>
		public T Deserialize<T>(ICollection<ISerializationError> exceptions, string pathToSource) where T : new()
		{
			Type parentType = typeof(T);
			T retObj = ((T)Deserialize(parentType, exceptions, pathToSource));
			return retObj;
		}

		/// <summary>
		/// Deserializes to object of a type baseType
		/// </summary>
		public object Deserialize(Type type, ICollection<ISerializationError> exceptions, string pathToSource)
		{
			if (type == null)
			{
				ThrowException("Not specify type for deserialization!", null, exceptions);
			}

			PathToSource = pathToSource;
			ObjectReflector reflector = null;

			try
			{
				Load();
				reflector = GetReflector(type.Name);
			}
			catch (Exception e)
			{
				ThrowException("Data source not available!", e, exceptions);
			}

			object retObj = CommonDeserialize(reflector, type, exceptions);
			return retObj;
		}

		/// <summary>
		/// Deserializes to object received in "deserializeObject"-parameter
		/// </summary>
		public void Deserialize(object deserializeObject, ICollection<ISerializationError> exceptions, string pathToSource)
		{
			if (deserializeObject == null)
			{
				ThrowException("Object for deserialization is null!", null, exceptions);
			}

			PathToSource = pathToSource;
			Type type = null;
			ObjectReflector reflector = null;

			try
			{
				Load();
				type = deserializeObject.GetType();
				reflector = GetReflector(type.Name);
			}
			catch (Exception e)
			{
				ThrowException("Data source not available!", e, exceptions);
			}

			DeserializeCompositeMembers(type, reflector, deserializeObject, exceptions);
		}

		/// <summary>
		/// Serializes object.
		/// </summary>
		public void Serialize(object serializeObject, string pathToSource)
		{
			if (serializeObject == null)
			{
				ThrowException("Object for serialization is null!", null, null);
			}

			PathToSource = pathToSource;
			ObjectReflector reflector = CreateReflector(serializeObject, serializeObject.GetType().Name, string.Empty);

			Save(reflector);
		}

		/// <summary>
		/// Gets PropertyInfo collection for deserialize
		/// </summary>
		public static IEnumerable<PropertyInfo> GetSerializeInfos(Type type, SerializePropertiesType choiceParameter)
		{
			IEnumerable<PropertyInfo> propertyArray = type.GetProperties(BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public).
						   Where(p => p.GetCustomAttributes(typeof(SerializeAttribute), true).Length > 0);

			switch (choiceParameter)
			{
				case SerializePropertiesType.Composite:
					propertyArray = propertyArray.
						Where(p => p.
							GetCustomAttributes(typeof(SerializePropertyAttribute), true).Length > 0 &&
							(p.PropertyType.IsValueType == false &&
							p.PropertyType != typeof(string)));
					break;
				case SerializePropertiesType.Collection:
					propertyArray = propertyArray.
						Where(p => p.
							GetCustomAttributes(typeof(SerializeCollectionAttribute), true).Length > 0);
					break;
				case SerializePropertiesType.Value:
					propertyArray = propertyArray.
						Where(p => p.
							GetCustomAttributes(typeof(SerializePropertyAttribute), true).Length > 0 &&
							(p.PropertyType.IsValueType || p.PropertyType == typeof(string)));
					break;
				case SerializePropertiesType.NonValue:
					propertyArray = propertyArray.
						Where(p => p.
							GetCustomAttributes(typeof(SerializeAttribute), true).Length > 0 &&
							(p.PropertyType.IsValueType == false &&
							p.PropertyType != typeof(string)));
					break;
				case SerializePropertiesType.Nested:
					propertyArray = propertyArray.
						Where(p => p.
							GetCustomAttributes(typeof(SerializeNestedAttribute), true).Length > 0);
					break;
			}

			return propertyArray;
		}

		#endregion

		#region Protected methods

		protected abstract void Load();

		protected abstract ObjectReflector GetReflector(string parentElementName);

		protected abstract void Save(ObjectReflector reflector);

		#endregion

		#region Private methods

		#region Deserialize private methods

		/// <summary>
		/// Mapped serialize object
		/// </summary>
		private object CommonDeserialize(ObjectReflector reflector, Type type, ICollection<ISerializationError> exceptions)
		{
			Type realType = type;
			if (reflector.ValueProps.Count > 0 && reflector.ValueProps.ContainsKey(Constants.RealType))
			{
				realType = Type.GetType(reflector.ValueProps[Constants.RealType]);
				if (realType == null)
				{
					string msg = string.Format("Cannot find type {0}. Please check {1} data source.", reflector.ValueProps[Constants.RealType], PathToSource);
					ThrowException(msg, null, exceptions);
				}
			}

			object retObj = null;

			CheckProperties(reflector, realType, exceptions);

			retObj = DeserializeObjectProperties(reflector.ValueProps, realType, exceptions);

			DeserializeCompositeMembers(realType, reflector, retObj, exceptions);

			return retObj;
		}

		private static void CheckProperties(ObjectReflector reflector, Type realType, ICollection<ISerializationError> exceptions)
		{
			IEnumerable<PropertyInfo> infos = GetSerializeInfos(realType, SerializePropertiesType.All);

			List<string> availableProps = new List<string>();
			availableProps.AddRange(reflector.ValueProps.Keys);
			availableProps.AddRange(reflector.CompositeProps.Select(p => p.Name));
			Dictionary<string, PropertyInfo> infosDictionary = new Dictionary<string, PropertyInfo>();

			foreach (PropertyInfo info in infos)
			{
				SerializeParams parameters = SerializeParams.GetParameters(info);
				string propsName = availableProps.FirstOrDefault(p => string.Compare(p, parameters.MappedName, StringComparison.InvariantCultureIgnoreCase) == 0);

				//Checked for required properties is available
				if (string.IsNullOrEmpty(propsName) && parameters.IsRequired)
				{
					ThrowException(string.Format("The required property {0} does not exist!", parameters.MappedName),
									null,
									exceptions);
				}
				//If property is missing and not required
				else if (string.IsNullOrEmpty(propsName))
				{
					continue;
				}

				infosDictionary.Add(propsName, info);
				availableProps.RemoveAt(availableProps.FindIndex(p => string.Compare(p, propsName, StringComparison.InvariantCultureIgnoreCase) == 0));
			}

			//Checked additional properties
			foreach (string propsName in availableProps)
			{
				if (!infosDictionary.ContainsKey(propsName))
				{
					if (string.Compare(propsName, Constants.RealType, StringComparison.InvariantCultureIgnoreCase) == 0 ||
						string.Compare(propsName, Constants.Value, StringComparison.InvariantCultureIgnoreCase) == 0)
					{
						infosDictionary.Add(propsName, null);
					}
					else
					{
						PropertyInfo property = infos.FirstOrDefault(p => string.Compare(p.Name, propsName, true) == 0);
						if (property == null)
						{
							ThrowException(string.Format("Type {0} not contains property with name {1}", realType.FullName, propsName),
											null,
											exceptions);
						}
					}
				}
				else
				{
					ThrowException(string.Format("{0} is a duplicate property name.", propsName), null, exceptions);
				}
			}
		}

		private void DeserializeCompositeMembers(Type realType, ObjectReflector reflector, object retObj, ICollection<ISerializationError> exceptions)
		{
			//Gets serialize properties in current type, if property type is not collection and is not value type
			IEnumerable<PropertyInfo> compositePropertyArray = GetSerializeInfos(realType, SerializePropertiesType.NonValue);

			//Deserialize composite properties
			foreach (PropertyInfo propertyInfo in compositePropertyArray)
			{
				SerializeParams parameters = SerializeParams.GetParameters(propertyInfo);

				ObjectReflector childReflector = reflector.CompositeProps.FirstOrDefault(p => string.Compare(p.Name, parameters.MappedName, StringComparison.InvariantCultureIgnoreCase) == 0);

				if (childReflector != null)
				{
					object propertyValue = null;
					if (parameters is SerializePropertyParams)
					{
						propertyValue = CommonDeserialize(childReflector, parameters.DefaultType, exceptions);
					}
					else if (parameters is SerializeCollectionParams)
					{
						propertyValue = DeserializeCollection(((SerializeCollectionParams)parameters), childReflector, parameters.DefaultType.IsArray, exceptions);
					}
					else if (parameters is SerializeNestedParams)
					{
						propertyValue = DeserializeNested(((SerializeNestedParams)parameters), childReflector);
					}

					try
					{
						propertyInfo.SetValue(retObj, propertyValue, null);
					}
					catch (Exception e)
					{
						string sb = string.Format("Error when deserialization prime configuration class. Fileld name: \"{0}\".", propertyInfo.Name);
						SerializationException exc = new SerializationException(sb, e);
						exc.Value = retObj;

						if (exceptions != null)
						{
							exceptions.Add(exc);
						}
						else
						{
							throw exc;
						}
					}
				}
			}
		}

		private IList DeserializeCollection(SerializeCollectionParams parameters, ObjectReflector reflector,
												  bool isArray, ICollection<ISerializationError> exceptions)
		{
			IList retCollection = !isArray ?
				((IList)parameters.DefaultType.InvokeMember(parameters.DefaultType.FullName, BindingFlags.CreateInstance, null, null, null)) :
				null;
			ArrayList tempList = new ArrayList();

			foreach (ObjectReflector child in reflector.CompositeProps)
			{
				//Deserialize special properties
				if (string.Compare(child.Name, parameters.ElementName, StringComparison.InvariantCultureIgnoreCase) != 0)
				{
					ISerializeEx ext = retCollection as ISerializeEx;
					if (ext != null)
					{
						ext.Deserialize(child);
					}
					else
					{
						ThrowException(string.Format("Invalid element name {0} in collection. Check {1} source!", child.Name, _pathToSource),
											null,
											exceptions);
					}
				}
				//Deserialize composite and value properties in element collection
				else
				{
					tempList.Add(
						CommonDeserialize(child, parameters.ElementType, exceptions));
				}
			}

			//Deserialize collection if collection is array
			if (isArray)
			{
				Array array = Array.CreateInstance(parameters.ElementType, tempList.Count);
				for (int i = 0; i < array.Length; i++)
				{
					array.SetValue(tempList[i], i);
				}
				retCollection = array;
			}
			//Deserialize collection if collection is not array
			else
			{
				foreach (object obj in tempList)
				{
					retCollection.Add(obj);
				}
			}

			return retCollection;
		}

		private object DeserializeNested(SerializeNestedParams parameters, ObjectReflector reflector)
		{
			object result = null;
			parameters.SetNestedParams(reflector);
			string pathToSource = GetPath(parameters);
			if (string.IsNullOrEmpty(parameters.PathToSource) || string.IsNullOrEmpty(parameters.SerializerTypeName))
			{
				string message = string.Format("One or more serialization parameters for property {0} in type {1} is not valid.",
													parameters.MappedName,
													parameters.DefaultType);
				ThrowException(message, null, null);
			}

			result = SerializeWrapper.Deserialize(parameters.SerializerTypeName, pathToSource, parameters.DefaultType);

			return result;
		}

		private string GetPath(SerializeNestedParams parameters)
		{
			string pathToSource = string.Empty;

			switch (parameters.PathType)
			{
				case PathType.Absolute:
					pathToSource = parameters.PathToSource;
					break;
				case PathType.Nested:
					pathToSource = Path.Combine(Path.GetDirectoryName(ExternalParameters.GetValue(parameters.NestedPath)), parameters.PathToSource);
					break;
				case PathType.Relative:
					pathToSource = Path.Combine(Path.GetDirectoryName(_pathToSource), parameters.PathToSource);
					break;
			}

			return pathToSource;
		}

		private object DeserializeObjectProperties(
			SortedList<string, string> propertyCollectoin,
			Type type,
			ICollection<ISerializationError> exceptions)
		{
			object retObj = null;
			//Creation element collection if collection type is string
			if (type == typeof(string))
			{
				if (propertyCollectoin.ContainsKey(Constants.Value))
					retObj = propertyCollectoin[Constants.Value];
				else
					retObj = string.Empty;
				return retObj;
			}
			else
			{
				//Creation deserialize object
				retObj = type.InvokeMember(type.Name, BindingFlags.CreateInstance, null, null, null);
			}

			Dictionary<string, object> errorProps = new Dictionary<string, object>();

			//Select serialize properties in current type 
			IEnumerable<PropertyInfo> propertyArray = GetSerializeInfos(type, SerializePropertiesType.Value);

			foreach (PropertyInfo info in propertyArray)
			{
				//Initialize property of object
				DeserializeSetObject(propertyCollectoin, info, ref retObj, exceptions, errorProps);
			}

			//Added exceptions to collection if deserialize process with errors
			if (errorProps.Count > 0)
			{
				StringBuilder sb = new StringBuilder();
				sb.AppendLine("Error when deserialization prime configuration class.");
				sb.AppendLine("Please correcting the following properties in " + PathToSource);
				foreach (KeyValuePair<string, object> pair in errorProps)
				{
					sb.AppendLine(string.Format("Fileld name: \"{0}\", value: \"{1}\"", pair.Key, pair.Value.ToString()));
				}
				SerializationException exc = new SerializationException(sb.ToString(), new InvalidCastException("Type mismatch during deserialization"));
				exc.PropertyCollectoin = propertyCollectoin;
				exc.ErrorPropertyCollectoin = errorProps;
				exc.Value = retObj;
				exceptions.Add(exc);
			}
			return retObj;
		}

		private void DeserializeSetObject(
			SortedList<string, string> propertyCollectoin,
			PropertyInfo info,
			ref object retObj,
			ICollection<ISerializationError> exceptions,
			Dictionary<string, object> errorProps)
		{
			SerializePropertyParams parameters = ((SerializePropertyParams)SerializeParams.GetParameters(info));

			//Sets property value
			if (propertyCollectoin.ContainsKey(parameters.MappedName))
			{
				TypeConverter converter = TypeDescriptor.GetConverter(parameters.DefaultType);
				string strValue = propertyCollectoin[parameters.MappedName];
				object value;

				try
				{
					value = strValue != null ? converter.ConvertFromInvariantString(strValue) : parameters.DefaultValue;

					info.SetValue(retObj, value, null);
				}
				catch (Exception e)
				{
					//Aborting serialization process
					if (exceptions == null)
					{
						string msg = string.Format(
							"Type mismatch during deserialization. Fileld name: \"{0}\", value: \"{1}\"" +
							"\n Please correcting this property in " + PathToSource,
							parameters.MappedName,
							propertyCollectoin[parameters.MappedName]);
						ThrowException(msg, e, exceptions);
					}

					errorProps.Add(info.Name, propertyCollectoin[info.Name]);
				}
			}
		}

		#endregion Deserialize private methods

		#region Serialize private methods

		private ObjectReflector CreateReflector(object serializeObject, string mappedName, string typeName)
		{
			ObjectReflector reflector = new ObjectReflector();
			Type type = serializeObject.GetType();
			reflector.Name = mappedName;

			reflector.ValueProps = SerializeObjectProperties(serializeObject, type);

			//Replacing object type
			if (!string.IsNullOrEmpty(typeName) && type.FullName != typeName)
			{
				reflector.ValueProps.Add(Constants.RealType, type.FullName + ", " + type.Assembly.FullName);
			}

			SerializeCompositeProperties(type, reflector, serializeObject);

			SerializeCollectionProperties(type, reflector, serializeObject);

			SerializeNestedProperties(serializeObject, reflector);

			return reflector;
		}

		private SortedList<string, string> SerializeObjectProperties(object serializeObject, Type type)
		{
			SortedList<string, string> retObj = new SortedList<string, string>();

			//Select serialize properties in current type 
			IEnumerable<PropertyInfo> propertyArray = GetSerializeInfos(type, SerializePropertiesType.Value);

			foreach (PropertyInfo info in propertyArray)
			{
				SerializePropertyParams propertyParams = ((SerializePropertyParams)SerializeParams.GetParameters(info));

				//Gets property value
				object obj = info.GetValue(serializeObject, null);

				if (obj == null)
				{
					CheckRequiredProperty(obj, propertyParams);
					obj = string.Empty;
				}
				retObj.Add(propertyParams.MappedName, obj.ToString());
			}

			return retObj;
		}

		private void SerializeCompositeProperties(Type type, ObjectReflector reflector, object parentObject)
		{
			//Gets serialize properties in current type, if property type is not collection and is not value type
			IEnumerable<PropertyInfo> compositePropertyArray = GetSerializeInfos(type, SerializePropertiesType.Composite);

			//Mapping composite properties
			foreach (PropertyInfo info in compositePropertyArray)
			{
				SerializePropertyParams childParamerers = ((SerializePropertyParams)SerializeParams.GetParameters(info));

				//Checked if required property is null
				CheckRequiredProperty(childParamerers.DefaultValue, childParamerers);

				object obj = info.GetValue(parentObject, null);
				ObjectReflector childReflector = CreateReflector(obj, childParamerers.MappedName, childParamerers.DefaultType.FullName);
				reflector.CompositeProps.Add(childReflector);
			}
		}

		private void SerializeCollectionProperties(Type type, ObjectReflector reflector, object parentObject)
		{
			//Gets serialize properties in current type, if property type collection
			IEnumerable<PropertyInfo> collectionPropertyArray = GetSerializeInfos(type, SerializePropertiesType.Collection);

			//Mapping collection properties
			foreach (PropertyInfo info in collectionPropertyArray)
			{
				SerializeCollectionParams parameters = ((SerializeCollectionParams)SerializeParams.GetParameters(info));
				ICollection collection = ((ICollection)info.GetValue(parentObject, null));

				//Checked if required property is null
				CheckRequiredProperty(collection, parameters);

				ObjectReflector childReflector = new ObjectReflector();
				childReflector.Name = parameters.MappedName;
				if (collection != null && collection.Count > 0)
				{
					foreach (object itemObj in collection)
					{
						childReflector.CompositeProps.Add(CreateReflector(itemObj, parameters.ElementName, parameters.ElementType.FullName));
					}
				}

				reflector.CompositeProps.Add(childReflector);
			}
		}

		private void SerializeNestedProperties(object serializeObject, ObjectReflector reflector)
		{
			Type serializeType = serializeObject.GetType();
			IEnumerable<PropertyInfo> nestedInfos = GetSerializeInfos(serializeType, SerializePropertiesType.Nested);

			foreach (PropertyInfo propertyInfo in nestedInfos)
			{
				SerializeNestedParams parameters = ((SerializeNestedParams)SerializeParams.GetParameters(propertyInfo));
				object propertyObject = propertyInfo.GetValue(serializeObject, null);

				ObjectReflector child = new ObjectReflector();
				child.Name = parameters.MappedName;

				reflector.CompositeProps.Add(child);
				string pathToSource = GetPath(parameters);

				if (string.IsNullOrEmpty(parameters.PathToSource) || parameters.SerializerTypeName == null)
				{
					string message = string.Format("One or more serialization parameters for property {0} in type {1} is not valid.",
														parameters.MappedName,
														parameters.DefaultType);
					ThrowException(message, null, null);
				}

				SerializeWrapper.Serialize(parameters.SerializerTypeName, propertyObject, pathToSource);
			}
		}

		private void CheckRequiredProperty(object value, SerializeParams parameters)
		{
			if (value == null && parameters.IsRequired)
			{
				ThrowException(string.Format("The required property {0} dous not exist!", parameters.MappedName), null, null);
			}
		}

		#endregion Serialize private methods

		private static void ThrowException(string message, Exception innerException, ICollection<ISerializationError> exceptions)
		{
			SerializationException exc = new SerializationException(message, innerException);
			if (exceptions != null)
			{
				exceptions.Add(exc);
				throw exc;
			}
			else
			{
				throw exc;
			}
		}

		#endregion
	}
}
