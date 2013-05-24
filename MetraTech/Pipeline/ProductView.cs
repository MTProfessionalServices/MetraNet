
using System.Runtime.InteropServices;

namespace MetraTech.Pipeline
{
	using MetraTech.Interop.MTProductCatalog;
	using MetraTech.Xml;

	using System;
	using System.Diagnostics;
	using System.Collections;
	using System.Collections.Specialized;

	[Guid("003b4106-ee89-4fbf-bb1d-2ae28da8520e")]
	public interface IProductViewDefinition : IPropertyMetaDataSet
	{
		IEnumerable Properties
		{
			get;
		}

		IEnumerable SortedProperties
		{
			get;
		}

		IMTPropertyMetaData GetProperty(string name);
	}
	
	[Guid("a96fa1ec-d213-42b2-bb86-9cc85f9c7a04")]
	[ClassInterface(ClassInterfaceType.None)]
	public class ProductViewDefinition : PropertyMetaDataSet, IProductViewDefinition
	{
		public IEnumerable Properties
		{
			get { return this.Values; }
		}

		// TODO: move this into the base class but still make it callable by
		// VBScript
		public IEnumerable SortedProperties
		{
			get
			{
				string [] propNames = new string[Count];
				IMTPropertyMetaData [] props = new IMTPropertyMetaData[Count];

				// sort the property names
				Keys.CopyTo(propNames, 0);
				Array.Sort(propNames);

				// now layout the values in the same order
				int i = 0;
				foreach (string propName in propNames)
					props[i++] = (IMTPropertyMetaData) this[propName];

				return props;
			}
		}

		// this method is useful for VBScript which can't call base class members
		public IMTPropertyMetaData GetProperty(string name)
		{
			return (IMTPropertyMetaData) this[name];
		}
	}

	
	[Guid("786006af-59c5-4817-a333-2e1a76bc1c01")]
	public interface IProductViewDefinitionCollection
	{
		IProductViewDefinition GetProductViewDefinition(string pvDefName);
		IEnumerable Names{get;}
		IEnumerable SortedNames{get;}
	}


	// TODO: move common code between this and ServiceDefinitionCollection
	[Guid("bf71521c-f93e-452c-88af-515db1503096")]
	[ClassInterface(ClassInterfaceType.None)]
	public class ProductViewDefinitionCollection : IProductViewDefinitionCollection
	{
    public ProductViewDefinitionCollection()
		{
			InitPVDefList();
		}

		public IProductViewDefinition GetProductViewDefinition(string pvDefName)
		{
			string filename = mPVDefFilenames[pvDefName];
			if (filename == null)
				throw new System.ArgumentException(pvDefName +
																					 " is not a valid product view def name");

			// first check to see if we've already cached it
			ProductViewDefinition def = (ProductViewDefinition) mPVDefs[filename];
			if (def != null)
				return def;

			// not cached - read it in
			MetaDataParser parser = new MetaDataParser();

			def = new ProductViewDefinition();
			parser.ReadMetaDataFromFile(def, filename, "t_pv_");

			Debug.Assert(def.Name.ToLower() == pvDefName.ToLower(), "Service name mismatch");
			mPVDefs[filename] = def;

			return def;
		}

		public IEnumerable Names
		{
			get
			{
				return mPVDefFilenames.Keys;
			}
		}

		public IEnumerable SortedNames
		{
			get
			{
				string [] names = new string[mPVDefFilenames.Count];
				ICollection coll = mPVDefFilenames.Keys;
				coll.CopyTo(names, 0);
				Array.Sort(names);
				return names;
			}
		}

		private string FilenameToDefName(string filename)
		{
			// r:\extensions\pcsample\config\productview\metratech.com\testpi.msixdef
			int delim = filename.IndexOf("config\\productview");

			if (delim == -1)
				throw new System.ArgumentException(filename +
																					 " is not a valid product view def name");

			string suffix = filename.Substring(delim + "config\\productview".Length + 1);
			// change slashes
			suffix = suffix.Replace('\\', '/');
			suffix = suffix.Replace(".msixdef", "");
			return suffix;
		}

		private void InitPVDefList()
		{
			string dirName = "productview";

			string query;
			query = "config\\" + dirName + "\\*.msixdef";

			foreach (string filename in MTXmlDocument.FindFilesInExtensions(query))
			{
				string defName = FilenameToDefName(filename);
				mPVDefFilenames[defName] = filename;
			}
		}

		// mapping of product def name to full filename
		private NameValueCollection mPVDefFilenames = new NameValueCollection();

		// mapping of product view def filename to product def object.
		// NOTE: not case insensitive because we always use the value in
		// mPVDefFilenames as the key to this table
		private Hashtable mPVDefs = new Hashtable();
	}

}
