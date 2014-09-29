using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.Core;
using MetraTech.Events;
using MetraTech.UI.CDT;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Controls;
using Resources;

public partial class BEEdit : MTPage
{

  #region Variables

  protected string strNumberUpdatingRecords;

  #endregion

  #region Properties

  public EntityInstance BE
  {
    get { return ViewState["BE"] as EntityInstance; }
    set { ViewState["BE"] = value; }
  }

  public string RouteTo
  {
    get { return ViewState["RouteTo"] as string; }
    set { ViewState["RouteTo"] = value; }
  }

  public string BEName
  {
    get { return ViewState["BEName"] as string; }
    set { ViewState["BEName"] = value; }
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

  public string Id
  {
    get { return ViewState["Id"] as string; }
    set { ViewState["Id"] = value; }
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

  public bool IsBulkUpdate
  {
    get
    {
      Boolean isBulkUpdate;
      Boolean.TryParse(Convert.ToString(ViewState["IsBulkUpdate"]), out isBulkUpdate);
      return isBulkUpdate;
    }
    set
    {
      ViewState["IsBulkUpdate"] = value;
    }
  }

  public string BulkUpdateType
  {
    get
    {
      string bulkUpdateType = "";

      if (Session["BulkUpdateType"] != null)
      {
        bulkUpdateType = Session["BulkUpdateType"].ToString();
      }

      return bulkUpdateType;
    }
  }

  public int NumberUpdatingRecords
  {
    get
    {
      int res = 0;

      if (Session["NumberUpdatingRecords"] != null)
      {
        Int32.TryParse(Session["NumberUpdatingRecords"].ToString(), out res);
      }

      return res;
    }
  }

  #endregion

  #region  Events

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Update Runtime Configuration")) Response.End();
    if (!IsPostBack)
    {
      GetProperties();

      ResolveAssociation();

      string templateName = Request.QueryString["name"];

      PageLayout layout = BMEInstanceForm.GetPageLayoutByName(templateName);

      if (IsBulkUpdate)
      {
        var layoutBulkUpdate = BMEInstanceForm.GetPageLayoutByName(string.Concat(templateName, "_BulkUpdate"));
        if (layoutBulkUpdate != null && IsAnyPropertiesExist(layoutBulkUpdate))
        {
          layout = layoutBulkUpdate;
        }
      }

      templateName = layout.Name;

      string title = layout.Header.PageTitle.GetValue();
      if (String.IsNullOrEmpty(title))
      {
        title = templateName.Substring(templateName.LastIndexOf(".") + 1);
      }

      // if we have a parent we will use that id to get the single entity
      if (!String.IsNullOrEmpty(ParentId) && !String.IsNullOrEmpty(ParentName))
      {
        LoadEntityByParent(title, layout.ObjectName);
      }
      else
      {
        if (String.IsNullOrEmpty(Id))
        {
          MTTitle1.Text = string.Concat(GetLocalResourceObject("TEXT_NEW"), title);

          // Create Business Entity Instance 
          BE = CreateEntityInstance(layout.ObjectName);

          if (!String.IsNullOrEmpty(AccountDefProp))
          {
            BE.SetValue(int.Parse(AccountDefProp), "AccountId");
          }

          if (!String.IsNullOrEmpty(SubscriptionDefProp))
          {
            BE.SetValue(int.Parse(SubscriptionDefProp), "SubscriptionId");
          }
        }
        else
        {
          MTTitle1.Text = string.Concat(GetLocalResourceObject("TEXT_EDIT"), title);

          // Load existing entity instance by id
          BE = LoadEntityInstaceById(layout.ObjectName);
        }
      }

      if (BE == null)
      {
        Logger.LogError("Unable to find business entity for [{0}].", templateName);
        return;
      }

      BMEInstanceForm.RenderObjectInstanceName = "BE";
      BMEInstanceForm.TemplateName = templateName;

      // check for Read Only capability
      if (!MenuManager.CheckBECapability(BE.ExtensionName, AccessType.Write, UI.SessionContext.SecurityContext))
      {
        BMEInstanceForm.ReadOnly = true;
        btnOK.Visible = false;
      }

      if (IsBulkUpdate)
      {
        MTTitle1.Text = string.Concat(GetGlobalResourceObject("JSConsts", "TEXT_BULKUPDATE"), title);
        hfDeniedProperties.Value = String.Join(",", GetDeniedProperties());
        strNumberUpdatingRecords = string.Format(GetLocalResourceObject("TEXT_NUMBER_UPDATING_ITEM").ToString(), NumberUpdatingRecords);
      }
      else
      {
        hfDeniedProperties.Value = String.Empty;
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (Page.IsValid)
    {
      MTDataBinder1.Unbind();

      // Save entity

      // Check for presence of "BusinessKey" and set it to a GUID 
      // Empty business key properties will automatically be provided with a new GUID by the backend
      if (BE["BusinessKey"] != null)
      {
        if (BE["BusinessKey"].Value == null)
        {
          BE["BusinessKey"].Value = Guid.NewGuid();
        }
      }

      try
      {
        if (BE.Properties.Any(pr => pr.Name == "UID"))
          BE["UID"].Value = UI.User.AccountId;

        //Mass Update
        if (IsBulkUpdate)
        {
          DoBulkUpdate();
        }

        else if ((Request["Unrelated"] == "true") || (Request["EditChildRow"] == "true"))
        {
          SaveEntityInstance();
        }
        else
        {
          if (!String.IsNullOrEmpty(ParentId) && !String.IsNullOrEmpty(ParentName) && String.IsNullOrEmpty(Id))
          {
            BE = CreateEntityInstanceForParent();
          }
          else
          {
            SaveEntityInstance();
          }

          if (UI.Subscriber.SelectedAccount != null)
          {
            var updateMessage = new InfoMessage("UPDATE", BE.EntityFullName);
            var em = new EventManager();
            em.Send(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount.Name_Space, updateMessage);
          }
        }
      }
      catch (FaultException<MASBasicFaultDetail> fe)
      {
        SetMASError(fe);
        return;
      }
      catch (Exception exp)
      {
        SetError(exp.Message);
        return;
      }

      Response.Redirect(RouteTo);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(RouteTo);
  }

  #endregion

  #region Related Entities
  /// <summary>
  /// Renders links for related entities
  /// </summary>
  private void ShowRelatedEntityLinks()
  {
    if (BE != null)
    {
      var relatedEntities = GetRelatedEntities();

      if (relatedEntities.Count > 0)
      {
        PanelRelatedEntities.Visible = true;
        PanelRelatedEntities.Text = GetLocalResourceObject("TEXT_MORE_ITEMS") as string;

        int i = 0;
        foreach (RelatedEntity ent in relatedEntities)
        {
          if (ent.Multiplicity == Multiplicity.One)
          {
            var link = new MTBEEdit
                         {
                           Extension = ent.Entity.ExtensionName,
                           ObjectName = ent.Entity.FullName,
                           ParentId = BE.Id.ToString(),
                           ParentName = BE.EntityFullName,
                           Text = ent.Entity.GetLocalizedLabel()
                         };
            PanelRelatedEntities.Controls.Add(link);
          }
          else
          {
            var link = new MTBEList
                         {
                           Extension = ent.Entity.ExtensionName,
                           ObjectName = ent.Entity.FullName,
                           ParentId = BE.Id.ToString(),
                           ParentName = BE.EntityFullName,
                           Text = ent.Entity.PluralName
                         };
            string title = Server.HtmlEncode(ent.Entity.GetLocalizedLabel());
            if (!String.IsNullOrEmpty(title))
            {
              link.Text = title;
            }
            PanelRelatedEntities.Controls.Add(link);
          }

          i++;
          if (i < relatedEntities.Count)
          {
            var spacer = new Literal {Text = JSConsts.TEXT_SPACER};
            PanelRelatedEntities.Controls.Add(spacer);
          }
        }
      }
    }
  }
  #endregion

  #region Private Methods

  private Guid[] GetIdsToBeUpdated()
  {
    try
    {
      var ids = new List<Guid>(0);

      if (Session["IdsForBulkUpdate"] != null)
      {
        ids.AddRange(Session["IdsForBulkUpdate"].ToString().Split(',').Select(idString => new Guid(idString)));
      }

      return ids.ToArray();
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      return new Guid[] { };
    }
  }

  private List<string> GetPropertiesToBeUpdated()
  {
    try
    {
      var checkedCheckboxes = hfCheckedCheckboxes.Value.Split(',');

      var fieldNamesToBeUpdated = checkedCheckboxes.Select(el => ParseFieldName(el)).ToList();

      var deniedProperties = GetDeniedProperties();

      fieldNamesToBeUpdated.RemoveAll(e => e == String.Empty);
      fieldNamesToBeUpdated.RemoveAll(e => deniedProperties.Contains(e));
      
      fieldNamesToBeUpdated.Add("UID");

      return fieldNamesToBeUpdated;

    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      return new List<string>();
    }
  }

  private string ParseFieldName(string uniqueName)
  {
    if (String.IsNullOrEmpty(uniqueName))
      return String.Empty;

    const string stringToRemoveWithMTField = "check_MTField_ctl00_ContentPlaceHolder1_";
    const string stringToRemoveWithoutMTField = "check_ctl00_ContentPlaceHolder1_";

    if (uniqueName.Contains(stringToRemoveWithMTField))
      uniqueName = uniqueName.Replace(stringToRemoveWithMTField, String.Empty);
    else if (uniqueName.Contains(stringToRemoveWithoutMTField))
      uniqueName = uniqueName.Replace(stringToRemoveWithoutMTField, String.Empty);

    uniqueName = uniqueName.Remove(0, 2);

    if (BE.Properties.Select(e => e.Name).Contains(uniqueName))
      return uniqueName;

    int underIndex = uniqueName.LastIndexOf('_');

    if (underIndex == -1)
      return String.Empty;

    uniqueName = uniqueName.Remove(underIndex);

    if (BE.Properties.Select(e => e.Name).Contains(uniqueName))
      return uniqueName;

    return String.Empty;
  }

  private void DoBulkUpdate()
  {

    if (BulkUpdateType == "Selected")
    {
      var client = new EntityInstanceService_UpdateEntitiesByGuids_Client
                     {
                       UserName = UI.User.UserName,
                       Password = UI.User.SessionPassword,
                       In_beInstance = BE,
                       In_ids = GetIdsToBeUpdated(),
                       In_propertiesToUpdate = GetPropertiesToBeUpdated()
                     };
      client.Invoke();
    }
    else if (BulkUpdateType == "All" || BulkUpdateType == "CurPage")
    {
      var mtList = new MTList<EntityInstance>();

      if (Session["BEItemsForBulkUpdate"] != null)
      {
        mtList = (MTList<EntityInstance>)Session["BEItemsForBulkUpdate"];
      }

      if (Session["BEItemsForBulkUpdate"] != null)
      {
        mtList = (MTList<EntityInstance>)Session["BEItemsForBulkUpdate"];
      }

      var client = new EntityInstanceService_UpdateEntities_Client
      {
        UserName = UI.User.UserName,
        Password = UI.User.SessionPassword,
        In_beInstance = BE,
        In_mtList = mtList,
        In_propertiesToUpdate = GetPropertiesToBeUpdated()
      };
      client.Invoke();
    }
  }

  private void ResolveAssociation()
  {
    if (!String.IsNullOrEmpty(Request["Association"]))
    {
      if (Request["Association"].ToLower().Contains("account"))
      {
        AccountDefProp = UI.Subscriber.SelectedAccount._AccountID.ToString();
      }

      if (Request["Association"].ToLower().Contains("subscription"))
      {
        SubscriptionDefProp = Session["BESubscriptionId"].ToString();
      }
    }
  }

  private List<string> GetDeniedProperties()
  {
    try
    {
      var metadataService = new MetadataService_GetEntity_Client
                              {
                                UserName = UI.User.UserName,
                                Password = UI.User.SessionPassword,
                                In_entityName = BE.EntityFullName
                              };
      metadataService.Invoke();
      var entity = metadataService.Out_entity;

      var deniedProperties = new List<string>();

      foreach (var property in BE.Properties)
      {
        var prop = entity[property.Name];
        if (prop != null && (prop.IsBusinessKey || prop.IsUnique))
        {
          deniedProperties.Add(property.Name);
        }
      }
      return deniedProperties;
    }
    catch (Exception ex)
    {

      SetError(ex.Message);
      return new List<string>();
    }
  }

  private bool IsAnyPropertiesExist(PageLayout layout)
  {
    try
    {
      return layout.Sections.Any(section => section.Columns.Any(column => column.Fields.Any()));
    }
    catch (Exception ex)
    {
      SetError(ex.Message);
      return false;
    }
  }

  private void GetProperties()
  {
    RouteTo = !String.IsNullOrEmpty(Request.QueryString["url"]) ? Decrypt(Request.QueryString["url"]) : Request.UrlReferrer.ToString();

    bool isBulkUpdate;
    IsBulkUpdate = Boolean.TryParse(Request["IsBulkUpdate"], out isBulkUpdate) && isBulkUpdate;

    ParentName = String.IsNullOrEmpty(Request["ParentName"]) ? null : Request["ParentName"];
    ParentId = String.IsNullOrEmpty(Request["ParentId"]) ? null : Request["ParentId"];

    Id = Request.QueryString["id"];
  }

  private EntityInstance LoadEntityInstaceById(string entityName)
  {
    var client = new EntityInstanceService_LoadEntityInstance_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = entityName,
                     In_id = new Guid(Id)
                   };
    client.Invoke();
    return client.Out_entityInstance;
  }

  private EntityInstance CreateEntityInstance(string entityName)
  {
    var createNewEntityInstanceClient = new EntityInstanceService_GetNewEntityInstance_Client
                                          {
                                            UserName = UI.User.UserName,
                                            Password = UI.User.SessionPassword,
                                            In_entityName = entityName
                                          };
    createNewEntityInstanceClient.Invoke();
    return createNewEntityInstanceClient.Out_entityInstance;
  }

  private EntityInstance LoadEntityInstanceForParent(string entityName)
  {
    var client = new EntityInstanceService_LoadEntityInstanceFor_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityName = entityName,
                     In_forEntityId = new Guid(ParentId),
                     In_forEntityName = ParentName
                   };

    client.Invoke();
    return client.Out_entityInstance;
  }

  private void LoadEntityByParent(string title, string entityName)
  {
    bool isNewOneToMany = false;

    if (!String.IsNullOrEmpty(Request["NewOneToMany"]))
    {
      if (Request["NewOneToMany"].ToLower() == "true")
      {
        isNewOneToMany = true;
      }
    }

    if (!isNewOneToMany)
    {
      MTTitle1.Text = string.Concat(GetLocalResourceObject("TEXT_EDIT"), title);

      BE = LoadEntityInstanceForParent(entityName);

    }

    // if entity is null, we new it up, and set any associations we may have
    if (BE == null)
    {
      MTTitle1.Text = string.Concat(GetLocalResourceObject("TEXT_NEW"), title);

      BE = CreateEntityInstance(entityName);

      if (!String.IsNullOrEmpty(AccountDefProp))
      {
        BE.SetValue(int.Parse(AccountDefProp), "AccountId");
      }

      if (!String.IsNullOrEmpty(SubscriptionDefProp))
      {
        BE.SetValue(int.Parse(SubscriptionDefProp), "SubscriptionId");
      }
    }
    else
    {
      Id = BE.Id.ToString();
    }
  }

  private void SaveEntityInstance()
  {
    var client = new EntityInstanceService_SaveEntityInstanceVoid_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_entityInstance = BE
                   };
    client.Invoke();    
  }

  private EntityInstance CreateEntityInstanceForParent()
  {
    var client = new EntityInstanceService_CreateEntityInstanceFor_Client
                   {
                     UserName = UI.User.UserName,
                     Password = UI.User.SessionPassword,
                     In_forEntityId = new Guid(ParentId),
                     In_forEntityName = ParentName,
                     InOut_entityInstance = BE
                   };
    client.Invoke();
    return client.InOut_entityInstance;
  }

  private List<RelatedEntity> GetRelatedEntities()
  {
    var getTargetEntitiesClient = new MetadataService_GetTargetEntities_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_entityName = BE.EntityFullName
    };
    getTargetEntitiesClient.Invoke();
    return getTargetEntitiesClient.Out_targetEntities;
  }

  #endregion

}

