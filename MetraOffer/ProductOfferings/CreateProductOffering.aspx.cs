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
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using MetraTech.UI.MetraNet.App_Code;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Xml;
using MetraTech.Interop.RCD;
using MetraTech.DomainModel.BaseTypes;


public partial class MetraOffer_CreateProductOffering : MTPage
{

  public MetraTech.DomainModel.BaseTypes.BaseProductOffering productoffering
  {
    get { return ViewState["productoffering"] as BaseProductOffering; } //The ViewState labels are immaterial here..
    set { ViewState["productoffering"] = value; }
  }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      try
      {
        productoffering = new BaseProductOffering();

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = productoffering.GetType();

        //This should be same as the public property defined above 
        MTGenericForm1.RenderObjectInstanceName = "productoffering";

        //This is the Page Layout Template name
        MTGenericForm1.TemplateName = "Core.UI.CreateProductOffering";
        MTGenericForm1.ReadOnly = false;

        productoffering.Currency = SystemCurrencies.USD; //Default Currency set to USD on page load

        if (PartitionLibrary.PartitionData.isPartitionUser)
        {
          productoffering.POPartitionId = PartitionLibrary.PartitionData.POPartitionId;
          productoffering.Name = PartitionLibrary.PartitionData.PartitionUserName+ ":";
        }
        else
        {
          productoffering.POPartitionId = 1;
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

    //Initialize some read only values 
    PartitionLibrary.RetrievePartitionInformation();

    ProductOffering newProductOffering = new ProductOffering();

    //mypo = productoffering;
    
    //Initialize some read only values 
    newProductOffering.Name = productoffering.Name;
    newProductOffering.DisplayName = productoffering.DisplayName;
    newProductOffering.Description = productoffering.Description;
    newProductOffering.Currency = productoffering.Currency;
    newProductOffering.CanUserSubscribe = false;
    newProductOffering.CanUserUnsubscribe = false;
    newProductOffering.EffectiveTimeSpan.StartDate = productoffering.EffectiveTimeSpan.StartDate;
    newProductOffering.IsHidden = false;
    newProductOffering.POPartitionId = productoffering.POPartitionId;
    
    ProductOfferingServiceClient client = null;
    
    try
    {
      client = new ProductOfferingServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      client.SaveProductOffering(ref newProductOffering);
      
      client.Close();

      //From here go to PO Details Screen so that user can be update the newly created Product Offering 
      string targetURL = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/ProductOffering.ViewEdit.Frame.asp|ID=" + newProductOffering.ProductOfferingId;
      Response.Redirect(targetURL, false);

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
    Response.Redirect("ProductOfferingsList.aspx", false);
  }



}