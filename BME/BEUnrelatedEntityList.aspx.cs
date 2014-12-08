// Usage:  http://localhost/MetraNet/BEList.aspx?Name=Core.OrderManagement.Order&Extension=Account
//         &Association=Account&ParentId=123&ParentName=Core.OrderManagement.Parent 
// Loads list of orders with the OrderTemplate.xml grid layout in the Account extension
using System;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.CDT;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Controls.CDT;

public partial class BEUnrelatedEntityList : MTPage
{

  #region Properties


  public string BEName
  {
    get { return ViewState["BEName"] as string; }
    set { ViewState["BEName"] = value; }
  }

  public string MultiSelect
  {
    get { return ViewState["MultiSelect"] as string; }
    set { ViewState["MultiSelect"] = value; }
  }

  public string RefererUrl
  {
    get { return ViewState["RefererURL"] as string; }
    set { ViewState["RefererURL"] = value; }
  }

  public string ReturnUrl
  {
    get { return ViewState["ReturnURL"] as string; }
    set { ViewState["ReturnURL"] = value; }
  }

  public string AccountDefProp
  {
    get { return ViewState["AccountDef"] as string; }
    set { ViewState["AccountDef"] = value; }
  }

  public string SubscriptionDefProp
  {
    get { return ViewState["SubscriptionDef"] as string; }
    set { ViewState["SubscriptionDef"] = value; }
  }

  public string AssociationValue
  {
    get { return ViewState["AssociationValue"] as string; }
    set { ViewState["AssociationValue"] = value; }
  }

  public string ParentId
  {
    get { return ViewState["ParentId"] as string; }
    set { ViewState["ParentId"] = value; }
  }

  public string ParentName
  {
    get { return ViewState["ParentName"] as string; }
    set { ViewState["ParentName"] = value; }
  }

  public string ReadOnly
  {
    get { return ViewState["ReadOnly"] as string; }
    set { ViewState["ReadOnly"] = value; }
  }

  public string Unrelated
  {
    get { return ViewState["Unrelated"] as string; }
    set { ViewState["Unrelated"] = value; }
  }

  #endregion

  #region Events
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {

      RefererUrl = Encrypt(Request.Url.ToString());

      if (!String.IsNullOrEmpty(Request["Association"]))
      {
        AssociationValue = Request["Association"];
        if (AssociationValue.ToLower().Contains("account"))
        {
          AccountDefProp = UI.Subscriber.SelectedAccount._AccountID.ToString();
        }

        if (AssociationValue.ToLower().Contains("subscription"))
        {
          Session["BESubscriptionId"] = String.IsNullOrEmpty(Request["id_sub"]) ? Session["BESubscriptionId"].ToString() : Request["id_sub"];
          SubscriptionDefProp = Session["BESubscriptionId"].ToString();
        }
      }

      ParentName = String.IsNullOrEmpty(Request["ParentName"]) ? null : Request["ParentName"];
      ParentId = String.IsNullOrEmpty(Request["ParentId"]) ? null : Request["ParentId"];

      if (String.IsNullOrEmpty(Request["ReturnURL"]))
      {
        if (Request.UrlReferrer != null)
        {
          if (Request.UrlReferrer.ToString().ToLower().Contains("login.aspx") ||
              Request.UrlReferrer.ToString().ToLower().Contains("default.aspx"))
          {
            ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
          }
          else
          {
            ReturnUrl = Request.UrlReferrer.ToString();
          }
        }
        else
        {
          ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
        }
      }
      else
      {
        ReturnUrl = Request["ReturnURL"].Replace("'", "").Replace("|", "?").Replace("**", "&");
      }

      ReadOnly = "false";
      BEName = Server.HtmlEncode(Request.QueryString["Name"]);

      BMEGrid.ExtensionName = Request.QueryString["Extension"];
      BMEGrid.TemplateFileName = BEName + ".xml";
      //LblcurrentEntityName.Text = String.IsNullOrEmpty(Request["currentEntityName"]) ? null : Resources.Resource.TEXT_ADD_RELATED_ENTITIES + Request["currentEntityName"];
      // ReSharper disable StringLastIndexOfIsCultureSpecific.1
      LblcurrentEntityName.Text = String.IsNullOrEmpty(Request["currentEntityName"]) ? null : Resources.Resource.TEXT_RELATED_ENTITIES_1 + GetBMELocalizedName(BEName) + Resources.Resource.TEXT_RELATED_ENTITIES_2 + Request["currentEntityName"];
      // ReSharper restore StringLastIndexOfIsCultureSpecific.1

    }
  }

  private string GetBMELocalizedName(string bmename)
  {
    var BMEInstanceForm = new MTGenericForm();
    PageLayout layout = BMEInstanceForm.GetPageLayoutByName(BEName);
    if (layout == null)
      return bmename;
    return layout.Header.PageTitle.GetValue();
  }

  protected override void OnLoadComplete(EventArgs e)
  {

    MultiSelect = String.IsNullOrEmpty(Request["MultiSelect"]) ? "false" : Request["MultiSelect"];
    Unrelated = String.IsNullOrEmpty(Request["Unrelated"]) ? "false" : Request["Unrelated"];

    var gridTitle = GetBMELocalizedName(BEName);
    //if (String.IsNullOrEmpty())
    {
      string Text1 = Resources.Resource.TEXT_UNRELATED_1;
      string Text2 = Resources.Resource.TEXT_UNRELATED_2;
      //BMEGrid.Title = Server.HtmlEncode(Text1 + BEName.Substring(BEName.LastIndexOf(".") + 1) + " " + Text2);

      BMEGrid.Title = Text1 + gridTitle + Text2;

      // Set additional argument for grid     
      if (!String.IsNullOrEmpty(AccountDefProp))
      {
        BMEGrid.DataSourceURL += "&AccountDef=" + Encrypt(AccountDefProp);
      }

      if (!String.IsNullOrEmpty(SubscriptionDefProp))
      {
        BMEGrid.DataSourceURL += "&SubscriptionDef=" + Encrypt(SubscriptionDefProp);
      }

      if (!String.IsNullOrEmpty(ParentName))
      {
        BMEGrid.DataSourceURL += "&ParentName=" + ParentName;
      }

      if (!String.IsNullOrEmpty(ParentId))
      {
        BMEGrid.DataSourceURL += "&ParentId=" + ParentId;
      }

      BMEGrid.DataSourceURL += "&UnrelatedEntityList=true";

      if (!MenuManager.CheckBECapability(BMEGrid.ExtensionName, AccessType.Write, UI.SessionContext.SecurityContext))
      {
        ReadOnly = "true";
        if (BMEGrid.ToolbarButtons.Count > 0)
        {
          // remove the first toolbar button which is add by default on generic page
          BMEGrid.ToolbarButtons.RemoveAll(b => b.ButtonID.ToLower() == "add");
        }
      }
      else
      {
        ReadOnly = "false";
      }


      if (Unrelated == "true")
      {
        if (MultiSelect == "Many")
        {
          BMEGrid.MultiSelect = true;
          BMEGrid.SelectionModel = MTGridSelectionModel.Checkbox;
        }
        else
        {
          BMEGrid.MultiSelect = false;
          BMEGrid.SelectionModel = MTGridSelectionModel.Checkbox;
        }

        BMEGrid.ToolbarButtons.RemoveAll(b => b.ButtonID.ToLower() == "bulkupdate");

        BMEGrid.Buttons = MTButtonType.OKCancel;
      }
      base.OnLoadComplete(e);


    }
  }
  #endregion


}

