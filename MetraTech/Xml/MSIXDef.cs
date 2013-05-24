
namespace MetraTech.Xml
{
	using MetraTech.Interop.MTProductCatalog;
	using NameID = MetraTech.Interop.NameID;

	using System;
  using System.Reflection;
  using System.Xml;
	using System.Text.RegularExpressions;
	using System.Collections;
	using System.Diagnostics;
	using System.Runtime.InteropServices;


	[ComVisible(false)]
	public interface IPropertyMetaDataSet : IDictionary
	{
		string Name
		{ get; set; }

		// database ID for the given name (nameID)
		int NameID
		{ get; set; }

		string TableName
		{ get; set; }

		string LongTableName
		{ get; set; }

		string Description
		{ get; set; }

		bool CanResubmitFrom
		{ get; set; }

		IMTAttributes Attributes
		{ get; }
	}

	// we implement this so that Current returns the value, not a DictionaryEntry
	// like Hashtable's IDictionaryEnumerator
	[ComVisible(false)]
	class PropertyMetaDataIterator : System.Collections.IDictionaryEnumerator
	{
    public PropertyMetaDataIterator(IDictionaryEnumerator dictionaryEnum)
		{ mEnum = dictionaryEnum; }

    public object Current
		{
			get
			{ return mEnum.Value; }
		}

    public bool MoveNext()
		{ return mEnum.MoveNext(); }

    public void Reset()
		{ mEnum.Reset(); }

		public DictionaryEntry Entry
		{
			get
			{ return mEnum.Entry; }
		}

		public object Key
		{
			get
			{ return mEnum.Key; }
		}

		public object Value
		{
			get
			{ return mEnum.Value; }
		}

    private IDictionaryEnumerator mEnum;
	}


	[ComVisible(false)]
	public class PropertyMetaDataSet : Hashtable, IPropertyMetaDataSet
	{
		public PropertyMetaDataSet()
			: base(CaseInsensitiveHashCodeProvider.Default,
						 CaseInsensitiveComparer.Default)
		{ }

		public override void Add(object key, object value)
		{
			base.Add(key,value);

			// preserve the ordering that properties were added
			// this is important for generating column names for use in select lists 
			mOrderedProperties.Add(value);
		}

		public string Name
		{
			get
			{ return mName; }
			set
			{ mName = value; }
		}

		public int NameID
		{
			get
			{ return mNameID; }
			set
			{ mNameID = value; }
		}

		public string TableName
		{
			get
			{ return mTableName; }
			set
			{ mTableName = value; }
		}

		public string LongTableName
		{
			get
			{ return mLongTableName; }
			set
			{ mLongTableName = value; }
		}

		public string Description
		{
			get
			{ return mDescription; }
			set
			{ mDescription = value; }
		}

    public bool CanResubmitFrom
    {
      get { return mCanResubmitFrom; }
      set { mCanResubmitFrom = value; }
    }

		public override IDictionaryEnumerator GetEnumerator()
		{
			return new PropertyMetaDataIterator(base.GetEnumerator());
		}

		public IMTAttributes Attributes
		{
			get
			{ return mAttributes; }
		}

		public IEnumerable OrderedProperties
		{
			get
			{ return ArrayList.ReadOnly(mOrderedProperties); }
		}

		private IMTAttributes mAttributes = new MTAttributes();
		private string mName;
		private int mNameID;
		private string mTableName;
		private string mLongTableName;
		private string mDescription;
    private bool mCanResubmitFrom;
		private ArrayList mOrderedProperties = new ArrayList();
	}


	[ComVisible(false)]
	public interface IMetaDataParser
	{
		void ReadMetaDataFromFile(IPropertyMetaDataSet metaData, string filename, string tableNamePrefix);
		void ReadMetaDataFromDocument(IPropertyMetaDataSet metaData, XmlDocument doc, string tableNamePrefix);
	}


	[ComVisible(false)]
	public class MetaDataParser : IMetaDataParser
	{
		public void ReadMetaDataFromFile(IPropertyMetaDataSet metaData, string filename, string tableNamePrefix)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(filename);

			ReadMetaDataFromDocument(metaData, doc, tableNamePrefix);
		}

		public void ReadMetaDataFromDocument(IPropertyMetaDataSet metaData, XmlDocument doc, string tableNamePrefix)
		{
			string name = MTXmlDocument.GetNodeValueAsString(doc, "/*/name");
			bool canResubmitFrom = MTXmlDocument.GetNodeValueAsBool(doc, "/*/can_resubmit_from", false);
			string desc = MTXmlDocument.GetNodeValueAsString(doc, "/*/description", "");

			metaData.Name = name;
			metaData.NameID = mNameID.GetNameID(name);
			metaData.Description = desc;
			metaData.TableName = CalculateTableName(tableNamePrefix, name);
			metaData.LongTableName = CalculateLongTableName(tableNamePrefix, name);
      metaData.CanResubmitFrom = canResubmitFrom;

			// attribute on the top level node itself
			XmlNode defineService = doc.SelectSingleNode("/*");
			IMTAttributes msixDefAttributes = metaData.Attributes;
			foreach (XmlAttribute attr in defineService.Attributes)
			{
				// TODO: not sure why this can't be IMTAttributeMetaData.  "Add" fails to compile below
				MTAttributeMetaData attrMeta = new MTAttributeMetaData();
				attrMeta.Name = attr.Name;
				// TODO: we don't know the defaults.. is there any way to
				// configure a set of defaults?
				IMTAttribute mtAttr = msixDefAttributes.Add(attrMeta);
				mtAttr.Value = attr.Value;
			}

			XmlNodeList props = doc.SelectNodes("/*/ptype");
			foreach (XmlNode node in props)
			{
				IMTPropertyMetaData propMeta = ParseProperty(metaData, node);
			}
		}

		private IMTPropertyMetaData ParseProperty(IPropertyMetaDataSet metaData, XmlNode node)
		{
			string name = MTXmlDocument.GetNodeValueAsString(node, "dn");
			IMTPropertyMetaData propMeta = new MTPropertyMetaData();
			propMeta.Name = name;
      // TODO: populate true localized name
			propMeta.DisplayName = name;
			metaData.Add(name, propMeta);

			XmlNode typeNode = MTXmlDocument.SelectOnlyNode(node, "type");
			PropValType type = ParsePropValType(typeNode);

			XmlAttributeCollection typeAttributes = typeNode.Attributes;
			if (type == PropValType.PROP_TYPE_ENUM)
			{
				// if enumspace and enumtype are specified, use them.
				// Otherwise default them

				string enumspace = string.Empty;
				foreach (XmlAttribute attr in typeAttributes)
				{
					if (string.Compare(attr.Name, "enumspace", true) == 0)
					{
						enumspace = attr.Value;
						break;
					}
				}
				if (enumspace == string.Empty)
					enumspace = metaData.Name;
				propMeta.EnumSpace = enumspace;


				string enumtype = string.Empty;
				foreach (XmlAttribute attr in typeAttributes)
				{
					if (string.Compare(attr.Name, "enumtype", true) == 0)
					{
						enumtype = attr.Value;
						break;
					}
				}
				if (enumtype == string.Empty)
					enumtype = propMeta.Name;
				propMeta.EnumType = enumtype;
			}

			// TODO: make sure length is supplied if we need it
			// <Length></length> or <length>100</length>
			int length;
			XmlNode lengthNode = MTXmlDocument.SingleNodeExists(node, "length");
			if (lengthNode == null)
				length = 0;
			else if (!MTXmlDocument.NodeIsEmpty(lengthNode))
				length = MTXmlDocument.GetNodeValueAsInt(lengthNode);
			else
				length = 0;

			bool required;
			XmlNode requiredNode = MTXmlDocument.SingleNodeExists(node, "required");
			if (requiredNode == null)
        // TODO: should we warn here?
				required = false;
			else if (!MTXmlDocument.NodeIsEmpty(requiredNode))
				required = MTXmlDocument.GetNodeValueAsBool(requiredNode);
			else
				required = false;

			// TODO: verify default value based on type
			string defaultText;
			XmlNode defaultValueNode = MTXmlDocument.SingleNodeExists(node, "defaultvalue");
			if (defaultValueNode == null)
				defaultText = string.Empty;
			else if (!MTXmlDocument.NodeIsEmpty(defaultValueNode))
				defaultText = MTXmlDocument.GetNodeValueAsString(defaultValueNode);
			else
				defaultText = string.Empty;

			propMeta.DataType = type;
			propMeta.Length = length;
			propMeta.Required = required;
			propMeta.DefaultValue = defaultText;
			propMeta.Description = MTXmlDocument.GetNodeValueAsString(node, "description", string.Empty);

			XmlAttributeCollection attributes = node.Attributes;
			if (attributes != null)
				ParseAttributes(propMeta, attributes);

			// column name
			// TODO: the old code allowed a name to appear more than once.
			//       it would append a unique number to the end of the column
			//       name. do we need to support that?
			propMeta.DBColumnName = string.Format("c_{0}", name);

			return propMeta;
		}

		private void ParseAttributes(IMTPropertyMetaData propMeta, XmlAttributeCollection attributes)
		{
			IMTAttributes mtAttrs = propMeta.Attributes;

			foreach (XmlNode attribute in attributes)
			{
				// TODO: not sure why this can't be IMTAttributeMetaData.  "Add" fails to compile below
				MTAttributeMetaData attrMeta = new MTAttributeMetaData();
				string name = attribute.Name;
				string value = attribute.Value;
				attrMeta.Name = name;
				// TODO: we don't know the defaults.. is there any way to
				// configure a set of defaults?
				IMTAttribute mtAttr = mtAttrs.Add(attrMeta);
				mtAttr.Value = value;
			}
		}

		private PropValType ParsePropValType(XmlNode node)
		{
			string typeString = node.InnerText;

			// TODO: there is no difference between string and unistring
			if (0 == string.Compare(typeString, "string", true))
				return PropValType.PROP_TYPE_STRING;
			if (0 == string.Compare(typeString, "unistring", true))
				return PropValType.PROP_TYPE_STRING;
			if (0 == string.Compare(typeString, "int32", true))
				return PropValType.PROP_TYPE_INTEGER;
			if (0 == string.Compare(typeString, "int64", true))
				return PropValType.PROP_TYPE_BIGINTEGER;
			if (0 == string.Compare(typeString, "timestamp", true))
				return PropValType.PROP_TYPE_DATETIME;
			if (0 == string.Compare(typeString, "float", true))
				return PropValType.PROP_TYPE_DECIMAL;  //for filtering purposes, in the database, we store all doubles and floats as decimal
			if (0 == string.Compare(typeString, "double", true))
				return PropValType.PROP_TYPE_DECIMAL;
			if (0 == string.Compare(typeString, "enum", true))
				return PropValType.PROP_TYPE_ENUM;
			if (0 == string.Compare(typeString, "boolean", true))
				return PropValType.PROP_TYPE_BOOLEAN;
			if (0 == string.Compare(typeString, "time", true))
				return PropValType.PROP_TYPE_TIME;
			if (0 == string.Compare(typeString, "decimal", true))
				return PropValType.PROP_TYPE_DECIMAL;

			throw new MTXmlException(node, "Unable to parse property type from string '{0}'", typeString);
		}

    private string CalculateTableName(string prefix, string defName)
    {
      return CalculateTableName(prefix,defName,19);
    }

    private string CalculateLongTableName(string prefix, string defName)
    {
      return CalculateTableName(prefix,defName,0);
    }

		// based on the C++ implementation of CMSIXDefinition::GenerateTableName
		private string CalculateTableName(string prefix, string defName, int maxLengthWithoutPrefix)
		{
			// table name is a string manipulation of the name
			// for example: if name is metratech.com/audioconfcall, the
			// table name gets translated to <prefix>_audioconfcall
      // the resulting name is hashed if it's longer than 30 chars and 
      // the db type is oracle, then the name
			string tableName = defName;
			int pos = tableName.IndexOf('/');
			if (pos == -1)
			{
				pos = tableName.IndexOf('\\');
			}

      if (pos != -1)
      {
        tableName = tableName.Substring(pos + 1);
      }

      /* No more special treatment for aggregate-rated priceable item types.  They're 
         just going to have to deal with it like everyone else.
      */

			tableName = prefix + tableName;

			tableName = tableName.Replace("/", "_");
			tableName = tableName.Replace("\\", "_");

      // compose the table name and hash it ... if there's a prefix?!!?
      string shortname = tableName;
      if (prefix.Length > 0)
        shortname = HasherHack.GetDBNameHash(tableName);

      return shortname;
		}

 		public static object ParseValue(PropValType valType, string valString)
		{
			switch (valType)
			{
			case PropValType.PROP_TYPE_STRING:
				return valString;
			case PropValType.PROP_TYPE_INTEGER:
				return MTXmlDocument.ToInt(valString);
			case PropValType.PROP_TYPE_BIGINTEGER:
				return MTXmlDocument.ToLong(valString);
			case PropValType.PROP_TYPE_DATETIME:
				return MTXmlDocument.ToDateTime(valString);
			case PropValType.PROP_TYPE_DOUBLE:
				// TODO: should probably be moved into Xml.cs but
				// this conversion isn't very frequently used.
				return System.Convert.ToDouble(valString);
			case PropValType.PROP_TYPE_ENUM:
				Debug.Assert(false, "not implemented");
				throw new MTXmlException("Conversion to enum not yet implemented");
			case PropValType.PROP_TYPE_BOOLEAN:
				return MTXmlDocument.ToBool(valString);
			case PropValType.PROP_TYPE_TIME:
				Debug.Assert(false, "not implemented");
				throw new MTXmlException("Conversion to time not yet implemented");
			case PropValType.PROP_TYPE_DECIMAL:
				return MTXmlDocument.ToDecimal(valString);
			default:
				Debug.Assert(false, "bad type");
				throw new MTXmlException("bad prop val type");
			}
		}

		NameID.IMTNameID mNameID = new NameID.MTNameIDClass();
  }

  // we're in the MetraTech.Xml assembly here.  MetraTech.DataAcess already
  // depends on this, yet we need it to get a hashed db name.  So, to prevent 
  // a circular dependency, we'll just call the DBNameHash com object.  
  // At least for now.
  internal class HasherHack 
  {
    static public string GetDBNameHash(string name)
    {
      try
      {
        Type hasherType = Type.GetTypeFromProgID("MetraTech.DataAccess.DBNameHash");
        object hasher = Activator.CreateInstance(hasherType);

        object[] args = {name};

        string hashName = (string)hasherType.InvokeMember("GetDBNameHash",
          BindingFlags.Default
          | BindingFlags.InvokeMethod,
          null,
          hasher,
          args);

        return hashName;
      }
      catch(Exception e)
      {
        // crap. bad hack.
        Console.WriteLine(e.Message);
      }
      return name;
    }
  }


}





