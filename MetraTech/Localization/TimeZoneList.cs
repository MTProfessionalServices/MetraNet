
using MetraTech.Xml;
using System.Xml;
using System.Runtime.InteropServices;
using System;
using System.Collections;

namespace MetraTech.Localization
{
 	using System.Diagnostics;
	using System.Collections;
  using MetraTech.DataAccess;

  
  [Guid("866b411a-85a6-4fef-a8ce-0d96a3e11e2e")]
	public interface ITimeZoneList
	{
		string GetTimeZoneName(int aTzID);
    
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("f81be062-5da4-42a3-8941-2db2110fb9a7")]
	public class TimeZoneList : ITimeZoneList
  {
    public TimeZoneList()
    {
    }

		public string GetTimeZoneName(int id)
		{
			TimeZone tz = TimeZoneCache.GetInstance().GetTimeZoneByID(id);
			return (tz == null) ? "" : tz.Name;
		}
    
  }

	class TimeZoneCache
	{
		private static TimeZoneCache mInstance = null;

		internal TimeZone GetTimeZoneByID(int id)
		{
			if(mTimeZones.ContainsKey(id) == false)
			{
				//don't throw to keep behaviot consistent with what calandar lookup and weigth plugin expect
				//throw new TimezoneConfigurationException(string.Format("Timezone with id '{0}' is not defined in configuration file.", id));
				return null;
			}
			else
				return (TimeZone)mTimeZones[id];

		}
		internal static TimeZoneCache GetInstance()
		{
			if(mInstance == null)
			{
				lock(typeof(TimeZoneCache))
				{
					if(mInstance == null)
					{
						mInstance = new TimeZoneCache();
					}
				}
			}

			return mInstance;

		}
		private TimeZoneCache()
		{
			BuildCol();
		}

		private static Hashtable mTimeZones = null;
		private void BuildCol()
		{
			try
			{
				mTimeZones = new Hashtable();
				MTXmlDocument doc = new MTXmlDocument();
				doc.LoadConfigFile(@"timezone\Timezones.xml");
				XmlNodeList nodes = doc.SelectNodes("xmlconfig/timezone");
				foreach(XmlNode node in nodes)
				{
					int zid = MTXmlDocument.GetNodeValueAsInt(node, "id");
					string name = MTXmlDocument.GetNodeValueAsString(node, "name");
					if(mTimeZones.ContainsKey(zid))
					{
						throw new TimezoneConfigurationException(string.Format("Timezone with id '{0}' defined more than once.", zid));
					}
					else
					{
						mTimeZones[zid] = new TimeZone(zid, name);
					}

				}
  		}
			catch(System.Exception)
			{
				throw;
			}
		}

	}

	[Guid("22afa9fa-d977-40e1-9e4e-af5e76d5e77b")]
	public interface ITimeZone
	{
		int ID {get;set;}
		string Name {get;set;}
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("dd64afea-6d3b-4aa1-bdfd-ac225070ee1f")]
	public class TimeZone : ITimeZone
	{
		public TimeZone(int id, string name)
		{
			ID = id;
			Name = name;
		}
		int mID;
		public int ID 
		{
			get{return mID;}
			set{mID = value;}
		}
		string mName;
		public string Name 
		{
			get{return mName;}
			set{mName = value;}
		}
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("eba46ace-b5c8-40d9-b6bd-d9cfc11e3649")]
	public class TimezoneConfigurationException : ApplicationException
	{
		public TimezoneConfigurationException(string msg) : base(msg){}
	}




  
}

