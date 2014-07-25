using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;

public partial class Templates_ApplyTemplate : MTPage
{

  public AccountTemplate AccountTemplateInstance
  {
    get { return ViewState["AccountTemplateInstance"] as AccountTemplate; }
    set { ViewState["AccountTemplateInstance"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      AccountTemplateInstance = PageNav.Data.Out_StateInitData["AccountTemplateInstance"] as AccountTemplate;

      MTGenericFormAccountTemplate.DataBinderInstanceName = "MTDataBinder1";
//      StartDate.Text = MetraTech.MetraTime.Now.ToString();
//      EndDate.Text = MetraTech.MetraTime.Max.ToString();
      if (AccountTemplateInstance != null) MTGenericFormAccountTemplate.RenderObjectType = AccountTemplateInstance.GetType();
      MTGenericFormAccountTemplate.RenderObjectInstanceName = "AccountTemplateInstance";
      MTGenericFormAccountTemplate.TemplateName = MTGenericFormAccountTemplate.RenderObjectType.Name + "Apply_Template";
      MTGenericFormAccountTemplate.TemplatePath = TemplatePath;
      MTGenericFormAccountTemplate.ReadOnly = false;

      MTDataBinder1.UseMinimalBinding = true;
      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

      /* CORE-6239: Templates: unable to apply template for coresubscriber if coresubscriber is template owner.
       * 
      if (getDescendantCount() == 0)
      {
          // Display the warning to the user and eliminate the OK button
          SetError(GetLocalResourceObject("ERROR_NO_DESCENDANTS").ToString());
          btnOK.Visible = false;
      }*/
    }

    
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    TemplateEvents_CancelApplyTemplate_Client cancel = new TemplateEvents_CancelApplyTemplate_Client();
    cancel.In_AccountId = new AccountIdentifier(UI.User.AccountId);
    if (PageNav != null) PageNav.Execute(cancel);
  }

  /* CORE-6239: Templates: unable to apply template for coresubscriber if coresubscriber is template owner.
   * 
  private int getDescendantCount()
  {
      int cnt = 0;
     try
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {

              IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\AccHierarchies", "__GET_ANCESTOR_COUNT__");
              stmt.AddParam("%%ID_ACC%%", AccountTemplateInstance.AccountID);
              
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                  if (rdr.Read())
                  {
                      cnt = rdr.GetInt32("c_cnt_descendents");
                      Logger.LogDebug("Num descendants for this Template = " + cnt.ToString());
                  }
              }
          }
      }
      catch (Exception exp)
      {
          cnt = 0;
          Logger.LogException("Unable to retrieve descendent count.", exp);
      }

      return cnt;
  }*/
}