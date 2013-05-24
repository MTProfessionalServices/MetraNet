using System;
using MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;//.DispIdAttribute
using MetraTech.Localization;

namespace MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for NamedBaseProperty.
	/// </summary>
	/// 
	[ComVisible(false)]
  public interface INamedBaseProperty
  {
    [DispId(0)]
    int ID
    {
      set; get;
    }
    string GUID
    {
      set; get;
    }
    string Name
    {
      set; get;
    }
    string Description
    {
      set; get;
    }
    string DisplayName
    {
      set; get;
    }
    ILocalizedEntity DisplayNames
    {
      get;
    }
  }

  [ComVisible(false)]
	public class NamedBaseProperty : PCBase
	{
		public NamedBaseProperty(MTPCEntityType aPCEntity)
		{
	    LoadPropertiesMetaData(aPCEntity);
		}
    
    [DispId(0)]
    public int ID
    {
      get { return GetID(); }
      set { PutPropertyValue("ID", value); }
    }
    public string GUID
    {
      get 
      { 
        return (string)GetPropertyValue("GUID");
      }
      set { PutPropertyValue("GUID", value); }
    }
    public string Name
    {
      get 
      { 
        return (string)GetPropertyValue("Name");
      }
      set { PutPropertyValue("Name", value); }
    }
    public string Description
    {
      get 
      { 
        return (string)GetPropertyValue("Description");
      }
      set { PutPropertyValue("Description", value); }
    }

    public string DisplayName
    {
      get 
      { 
        return (string)GetPropertyValue("DisplayName");
      }
      set { PutPropertyValue("DisplayName", value); }
    }

    public ILocalizedEntity DisplayNames
    {
      get 
      { 
        object temp = null;
        GetObjectProperty("DisplayNames",ref temp);
        if (temp==null)
        {
          temp = new LocalizedEntity();
          PutObjectProperty("DisplayNames",temp);
        }
        return (ILocalizedEntity) temp; 
      }
    }         

	}
}
