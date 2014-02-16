using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Auth.Capabilities;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Xml;
using MetraTech.Interop.RCD;


public partial class MetraOffer_CreateSharedPriceList : MTPage
{

  public PriceList sharedpricelist
  {
    get { return ViewState["sharedpricelist"] as PriceList; } //The ViewState labels are immaterial here..
    set { ViewState["sharedpricelist"] = value; }
  }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      try
      {
        sharedpricelist = new PriceList();

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = sharedpricelist.GetType();

        //This should be same as the public property defined above 
        MTGenericForm1.RenderObjectInstanceName = "sharedpricelist";

        //This is the Page Layout Template name
        MTGenericForm1.TemplateName = "Core.UI.CreateSharedPriceList";
        MTGenericForm1.ReadOnly = false;

        //MTTextBoxControl tbPLPartitionId = FindControlRecursive(MTGenericForm1, "tbPLPartitionId") as MTTextBoxControl;
        //tbPLPartitionId.ReadOnly = true;
        
        if (PartitionLibrary.PartitionData.isPartitionUser)
        {
          sharedpricelist.PLPartitionId = PartitionLibrary.PartitionData.PLPartitionId;
          //if (tbPOPartitionId != null)
          //{
          //  tbPLPartitionId.ReadOnly = true;
          //}

        }
        else
        {
          sharedpricelist.PLPartitionId = 1;
        }
        

        if (!MTDataBinder1.DataBind())
        {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
        }
      }
      catch (Exception ex)
      {
        Logger.LogError(ex.ToString());
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!this.MTDataBinder1.Unbind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }

    PriceListServiceClient client = null;
    PriceList mypl = new PriceList();

    mypl = sharedpricelist;
    
    try
    {
      client = new PriceListServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      
      client.SaveSharedPriceList(ref mypl);

      client.Close();
      Response.Redirect("PriceListsList.aspx",false);

    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
      client.Abort();
    }

  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("PriceListsList.aspx");
  }

}