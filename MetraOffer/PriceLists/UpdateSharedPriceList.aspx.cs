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


public partial class MetraOffer_UpdateSharedPriceList : MTPage
{
  public PriceList sharedpricelist
  {
    get { return ViewState["sharedpricelist"] as PriceList; } //The ViewState labels are immaterial here..
    set { ViewState["sharedpricelist"] = value; }
  }

  public string strincomingPLID { get; set; } //so we can read it any time in the session 
  public int intincomingPLID { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    strincomingPLID = Request.QueryString["ID"];
    intincomingPLID = System.Convert.ToInt32(strincomingPLID);

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
        MTGenericForm1.TemplateName = "Core.UI.UpdateSharedPriceList";
        MTGenericForm1.ReadOnly = false;

        PriceListServiceClient getPL = new PriceListServiceClient();

        getPL.ClientCredentials.UserName.UserName = UI.User.UserName;
        getPL.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        PriceList spl;

        getPL.GetSharedPriceListByID(intincomingPLID, out spl);
        
        
        getPL.Close();

        sharedpricelist.Name = spl.Name;
        sharedpricelist.Description = spl.Description;
        sharedpricelist.Currency = spl.Currency;
        sharedpricelist.PLPartitionId = spl.PLPartitionId;

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

  public override void Validate()
  {
    

    //Currency can not be NULL
    //if ((sharedpricelist.Currency).ToString() == "")
    //{
    //  throw new ApplicationException(Resources.ErrorMessages.ERROR_INVALID_CURRENCY);
    //}

    if (sharedpricelist.PLPartitionId <= 0)
    {
      throw new ApplicationException(Resources.ErrorMessages.ERROR_INVALID_PARTITIONID);
    }

  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!this.MTDataBinder1.Unbind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }

    Page.Validate(); 

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

  protected void btnAddRatesToPT_Click(object sender, EventArgs e)
  {
    var targetUrl = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/PriceList.AddParamTable.asp|ID=" + intincomingPLID;// sharedpricelist.ID;
    //We may try to redirect to another frame instead of page so that the close of that frame will bring back where you were before, but OK for now
    Response.Redirect(targetUrl, false); 
 }

}