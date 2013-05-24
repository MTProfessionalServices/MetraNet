
using System.Xml;
using System.Runtime.InteropServices;
using System;

namespace MetraTech.Pipeline
{
	using MetraTech.Interop.MTProductCatalog;
  using MetraTech.Xml;

	using System.Diagnostics;
	using System.Collections;
	using System.Collections.Specialized;

  [Guid("a15af03c-69b0-46a5-8322-8a86d427198a")]
	public enum AccountIdentifierType
  {
     ACCOUNT_ID, ACCOUNT_NAME, ACCOUNT_NAMESPACE
  }

	[Guid("00faed31-a916-4759-bed9-0e3d9dc9c896")]
	public interface IServiceDefinition : IPropertyMetaDataSet
	{
		IEnumerable AccountIdentifiers
		{
			get;
		}
    bool IdentifiedBySEInternalID
    {
      get;
    }
    bool IdentifiedBySEExternalID
    {
      get;
    }
    bool IdentifiedByAccountInternalID
    {
      get;
    }
    bool IdentifiedByAccountExternalID
    {
      get;
    }
		IEnumerable Properties
		{
			get;
		}

		// returns properties sorted alphabetically by name
		IEnumerable SortedProperties
		{
			get;
		}

		IMTPropertyMetaData GetProperty(string name);

		// returns properties in the order in which they are listed in the msixdef
		IEnumerable OrderedProperties
		{
			get;
		}
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("c560216d-8b24-467e-b284-14e23d8ad179")]
	public class ServiceDefinition : PropertyMetaDataSet, IServiceDefinition
  {
		// this method is useful for VBScript which can't call base class members
		public IMTPropertyMetaData GetProperty(string name)
		{
			return (IMTPropertyMetaData) this[name];
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

		public IEnumerable Properties
		{
			get { return this.Values; }
		}

    public IEnumerable AccountIdentifiers
    {
      get
      {
        if(mIdentifiers != null)
          return mIdentifiers;
        mIdentifiers = new ArrayList();
        foreach (IMTPropertyMetaData prop in this)
        {
         string idname = string.Empty;
         if (HasValidIdentifier(prop, ref idname))
           mIdentifiers.Add(new AccountIdentifier(idname, prop));
        }
        return mIdentifiers;
      }
    }
    public ServiceDefinition()
    {
      mValidIds = new Hashtable();
      mValidIds.Add("accountid", new ValidIdentifier("accountid"));
      mValidIds.Add("accountname", new ValidIdentifier("accountname"));
      mValidIds.Add("accountnamespace", new ValidIdentifier("accountnamespace"));
      mIdentifiers = null;
    }
    public bool IdentifiedBySEInternalID
    {
      get
      {
        return false;
      }
    }
    public bool IdentifiedBySEExternalID
    {
      get
      {
				return false;
      }
    }
    public bool IdentifiedByAccountInternalID
    {
      get
      {
        return ((ValidIdentifier)mValidIds["accountid"]).Seen;
      }
    }
    public bool IdentifiedByAccountExternalID
    {
      get
      {
        return ((ValidIdentifier)mValidIds["accountname"]).Seen;
      }
    }
    private bool HasValidIdentifier(IMTPropertyMetaData aProp, ref string apIDType)
    {
      bool ret = false;
      foreach(IMTAttribute attrib in aProp.Attributes)
      {
        //handle more than one same identifier
        //on service def.
        string name = attrib.Name.ToLower();
        string sFound = string.Empty;
        if(mValidIds.Contains(name))
        {
          if(((ValidIdentifier)mValidIds[name]).Seen)
            throw new MTXmlException(System.String.Format("More than one properties are marked as '{0}' in '{1}'", attrib.Name, Name));
          //make sure that same MSIX property was not marked as
          //with more than 1 account identiying attributes
          if(sFound.Length > 0)
            throw new MTXmlException(System.String.Format("One property can not be '{0}' and '{1}' at the same time", sFound, name));
         ((ValidIdentifier)mValidIds[name]).Seen = true;
          sFound = name;
          ret = true;
          apIDType = name;
        }
      }

      return ret;

    }
    private Hashtable mValidIds;
    private ArrayList mIdentifiers;
    
    internal class ValidIdentifier
    {
      public ValidIdentifier(string aName)
      {
        mName = aName;
        mSeen = false;
      }
      public string Name
      {
        get{return mName;}
      }
      internal bool Seen
      {
        get{return mSeen;}
        set{mSeen = value;}
      }
      private string mName;
      private bool mSeen;
      
    }


  }

	[Guid("fd5bc53d-15d9-40ac-b6c6-b2da64b63866")]
	public interface IAccountIdentifier
	{
		AccountIdentifierType IdentifierType {get;}
		IMTPropertyMetaData MSIXProperty {get;}
		bool IsAccountIdentifier();
		bool IsSEIdentifier();
	}

	[Guid("14ba3c6a-6a70-4131-b22c-d7c77a1e38c8")]
	[ClassInterface(ClassInterfaceType.None)]
  public class AccountIdentifier : IAccountIdentifier
  {
		//Although this class does not have a default constructor, 
		//it's OK for it to be ComVisible. Com clients just won't be able to create it.
    public AccountIdentifier(string aIDType, IMTPropertyMetaData aProp) : this(ConvertIDType(aIDType), aProp)
    {
    }

    public AccountIdentifier(AccountIdentifierType aIDType, IMTPropertyMetaData aProp)
    {
      mType = aIDType;
      mMD = aProp;
    }
      
    /// <summary>
    /// Valid types are:
    ///accountid, accountname, accountnamespace, 
    /// </summary>
    public AccountIdentifierType IdentifierType
    {
      get{return mType;}
      set{mType = value;}
    }
    public IMTPropertyMetaData MSIXProperty
    {
      get{return mMD;}
      set{mMD = value;}
    }

    public bool IsAccountIdentifier()
    {
      return (int)mType < 3;
    }
    public bool IsSEIdentifier()
    {
      return (int)mType > 2;
    }
    private static AccountIdentifierType ConvertIDType(string aStrType)
    {
      
      /// Valid types are:
      /// serviceendpointid, accountid, serviceendpointname, accountname
      /// serviceendpointnamespace, accountnamespace, 
      /// serviceendpointcorpname, serviceendpointcorpnamespace

      if (string.Compare(aStrType, "accountid", true) == 0)
        return AccountIdentifierType.ACCOUNT_ID;
      if (string.Compare(aStrType, "accountname", true) == 0)
        return AccountIdentifierType.ACCOUNT_NAME;
      if (string.Compare(aStrType, "accountnamespace", true) == 0)
        return AccountIdentifierType.ACCOUNT_NAMESPACE;
      throw new MTXmlException(String.Format("Unknown Account Identifier {0}", aStrType));
    }


    private AccountIdentifierType mType;
    private IMTPropertyMetaData mMD;

  }

	[Guid("e4b92c99-5e83-4654-bf3f-343743478c08")]
	public interface IServiceDefinitionCollection
	{
		IServiceDefinition GetServiceDefinition(string serviceDefName);
		IEnumerable Names{get;}
		IEnumerable SortedNames{get;}
		string GetServiceDefFileName(string serviceDefName);
	}


	[Guid("d35f4644-c620-41df-943e-07f3f2477e2d")]
	[ClassInterface(ClassInterfaceType.None)]
	public class ServiceDefinitionCollection : IServiceDefinitionCollection
	{

		public string strProductDef = "service";
    public ServiceDefinitionCollection()
		{
			InitServiceDefList();
		}


		public ServiceDefinitionCollection(string ProductDefName)
		{
			strProductDef = ProductDefName;
			InitServiceDefList();
		}

		public IServiceDefinition GetServiceDefinition(string serviceDefName)
		{
			string filename = mSvcDefFilenames[serviceDefName];
			if (filename == null)
				throw new System.ArgumentException(serviceDefName +
																					 " is not a valid service def name");

			// first check to see if we've already cached it
			ServiceDefinition def = (ServiceDefinition) mSvcDefs[filename];
			if (def != null)
				return def;

			// not cached - read it in
			MetaDataParser parser = new MetaDataParser();

			def = new ServiceDefinition();
			parser.ReadMetaDataFromFile(def, filename, "");

			if (string.Compare(def.Name, serviceDefName, true) != 0)
				throw new MTXmlException("Service name mismatch for service " + serviceDefName);
			mSvcDefs[filename] = def;

			return def;
		}

		public IEnumerable Names
		{
			get
			{
				return mSvcDefFilenames.Keys;
			}
		}
		public string GetServiceDefFileName(string serviceDefName)
		{
			return mSvcDefFilenames[serviceDefName];
		}

		public IEnumerable SortedNames
		{
			get
			{
				string [] names = new string[mSvcDefFilenames.Count];
				ICollection coll = mSvcDefFilenames.Keys;
				coll.CopyTo(names, 0);
				Array.Sort(names);
				return names;
			}
		}


		private string FilenameToDefName(string filename)
		{
			// r:\extensions\pcsample\config\service\metratech.com\testpi.msixdef
			int delim = filename.IndexOf("config\\" + strProductDef);

			if (delim == -1)
				throw new System.ArgumentException(filename +
																					 " is not a valid service def name");

			string suffix = filename.Substring(delim + ("config\\" + strProductDef).Length + 1);
			// change slashes
			suffix = suffix.Replace('\\', '/');
			suffix = suffix.Replace(".msixdef", "");
			return suffix;
		}

		private void InitServiceDefList()
		{
			string dirName = strProductDef;

			string query;
			query = "config\\" + dirName + "\\*.msixdef";

			foreach (string filename in MTXmlDocument.FindFilesInExtensions(query))
			{
				string defName = FilenameToDefName(filename);
				mSvcDefFilenames[defName] = filename;
			}
		}

   
   

		// mapping of service def name to full filename
		private NameValueCollection mSvcDefFilenames = new NameValueCollection();

		// mapping of service def filename to service def object.
		// NOTE: not case insensitive because we always use the value in
		// mSvcDefFilenames as the key to this table
		private Hashtable mSvcDefs = new Hashtable();

   

   
	}

}
