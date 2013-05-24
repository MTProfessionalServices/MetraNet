using System;
using MetraTech;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Xml;
using MetraTech.Localization;
using System.Runtime.InteropServices;

namespace MetraTech.Adjustments

{
	/// <summary>
	/// Summary description for ReasonCode.
	/// </summary>
	/// 

  [Guid("8c4bb871-4999-4fe5-ad70-251aed3cbe29")]
  public interface IReasonCode : IMTPCBase
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

    void FromXML(string xml);
    int Save();

    //TODO: figure out attributes magic 
    //to  allow not to do it
    //IMTPCBase
    new void SetSessionContext(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCtx);
    new MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContext();

    //IMTProperties
    MetraTech.Interop.MTProductCatalog.IMTProperties Properties
    {
      get;
    }
  }

  [Guid("6c22ab63-e422-416f-b5ec-27b81b10bf13")]
  [ClassInterface(ClassInterfaceType.None)]
	public class ReasonCode : NamedBaseProperty, IReasonCode, IMTPCBase
	{
		public ReasonCode() : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT_REASON_CODE)
		{
			LoadPropertiesMetaData(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT_REASON_CODE);

      //Create and store an object to store localized display names
      PutObjectProperty("DisplayNames",new LocalizedEntity());
		}

    public void FromXML(string xml)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.LoadXml(xml);

      string name = doc.GetNodeValueAsString("reasoncode/name");
      string description = doc.GetNodeValueAsString("reasoncode/description");
      string displayname = doc.GetNodeValueAsString("reasoncode/displayname");
      Name = name;
      Description = description;
      DisplayName = displayname;
    }

    public int Save()
    {
      IReasonCodeWriter writer = new ReasonCodeWriter();
      //for now try look it up by name and mark for update here
      IReasonCodeReader reader = new ReasonCodeReader();
      IReasonCode code = 
        reader.FindReasonCodeByName
        ((IMTSessionContext)GetSessionContext(), this.Name);
      if (code != null)
      {
        ID = code.ID;
      }
      if(HasID())
        return writer.Create((IMTSessionContext)GetSessionContext(), this);
      else
      {
        writer.Update((IMTSessionContext)GetSessionContext(), this);
        return GetID();
      }
    }
    
	}
}
