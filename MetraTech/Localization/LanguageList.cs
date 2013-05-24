
using System.Xml;
using System.Runtime.InteropServices;
using System;

namespace MetraTech.Localization
{
 	using System.Diagnostics;
	using System.Collections;
  using MetraTech.DataAccess;

  
  [Guid("d89f0948-6b67-42d7-a3bf-92dc3d27b6b4")]
	public interface ILanguageList
	{
		string GetLanguageCode(int aLanguageID);
    int GetLanguageID(string aLanguageCode);

		ILanguageInformation GetLanguageInformationFromID(int aLanguageID);
		ILanguageInformation GetLanguageInformationFromCode(string aLanguageCode);

		IEnumerable Codes
		{
			get;
		}

		IEnumerable CodesInPreferredOrder
		{
			get;
		}

    IEnumerable Ids
    {
      get;
    }
    
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("b7bb0262-bf43-4bf6-9b32-43bfef0bd31f")]
	public class LanguageList : ILanguageList
  {
    public LanguageList()
    {
      if(mbInitialized == false)
        BuildCol();
    }
		public IEnumerable Codes
		{
			get { return mLanguageMappings.Keys; }
		}

		public IEnumerable CodesInPreferredOrder
		{
			get { return mPreferredOrder; }
		}

    public IEnumerable Ids
    {
      get { return mLanguageMappings.Values; }
    }

    public string GetLanguageCode(int aLanguageID)
    {
      if(!mLanguageMappings.ContainsValue(aLanguageID))
        throw new ApplicationException(String.Format("Unknown language id {0}", aLanguageID));
      else
        return (string)mLanguageMappings.GetKey(mLanguageMappings.IndexOfValue(aLanguageID));
    }
    public int GetLanguageID(string aLanguageCode)
    {
      string upper = aLanguageCode.ToUpper();
      if(!mLanguageMappings.ContainsKey(upper))
        throw new ApplicationException(String.Format("Unknown language code {0}", aLanguageCode));
      else
        return (int)mLanguageMappings[upper];
    }
		public ILanguageInformation GetLanguageInformationFromID(int aLanguageID)
		{
			return (ILanguageInformation) mLanguageInformation[aLanguageID];
		}

		public ILanguageInformation GetLanguageInformationFromCode(string aLanguageCode)
		{
			return (ILanguageInformation) mLanguageInformation[GetLanguageID(aLanguageCode)];
		}

    private void BuildCol()
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            mLanguageMappings = new SortedList();
            mLanguageInformation = new Hashtable();
            mPreferredOrder = new Queue();

            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Database", "__GET_LANGUAGE_CODES__"))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader.GetString("LanguageCode").ToUpper();

                        int id = reader.GetInt32("LanguageID");
                        int order = 0;
                        string description = "";
                        if (!reader.IsDBNull("PreferredOrder"))
                            order = reader.GetInt32("PreferredOrder");
                        if (!reader.IsDBNull("Description"))
                            description = reader.GetString("Description");

                        mLanguageMappings.Add(code, id);
                        mLanguageInformation.Add(id, new LanguageInformation(id, code, description, order));
                        mPreferredOrder.Enqueue(code);
                    }

                }
            }
         
            mbInitialized = true;
            return;
        }

    }


    
    private static SortedList mLanguageMappings = null;
		private static Hashtable mLanguageInformation = null;
		private static Queue mPreferredOrder = null;

    private static bool mbInitialized = false;

    
  }


	[Guid("03C91A9D-F9E8-45d7-8B0D-96F97E79F9E7")]
	public interface ILanguageInformation
	{
		int ID
		{
			get;
		}

		string Code
		{
			get;
		}

		string Description
		{
			get;
		}

		int PreferredOrder
		{
			get;
		}

	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("817A89AE-8CCD-4c31-9721-8E263F108556")]
	public class LanguageInformation : ILanguageInformation
	{
		public LanguageInformation()
		{
		}

		public LanguageInformation(int ID, string LanguageCode, string Description, int PreferredOrder)
		{
			mID=ID;
			mLanguageCode=LanguageCode;
			mDescription=Description;
			mPreferredOrder=PreferredOrder;
		}

		public int ID
		{
			get { return mID; }
		}
		public string Code
		{
			get { return mLanguageCode; }
		}

		public string Description
		{
			get { return mDescription; }
		}

		public int PreferredOrder
		{
			get { return mPreferredOrder; }
		}
		
		private int mID;
		private string mLanguageCode;
		private string mDescription;
		private int mPreferredOrder;
	}

  
}
