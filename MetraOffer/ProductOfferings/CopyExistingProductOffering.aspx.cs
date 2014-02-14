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
using MetraTech.DomainModel.Enums.Core.Global;
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
using MetraTech.Interop.MTProductCatalog;


public partial class MetraOffer_CopyExistingProductOffering : MTPage
{

  public MetraTech.DomainModel.BaseTypes.BaseProductOffering productoffering
  {
    get { return ViewState["productoffering"] as BaseProductOffering; } 
    set { ViewState["productoffering"] = value; }
  }

  //public IMTProductOffering SourceProductOffering { get; set; }
  public int intincomingPOID { get; set; }
  public string strincomingPOID { get; set; } //so we can read it any time in the session 
  //public string stringincomingCurrency { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    strincomingPOID = Request.QueryString["poid"];
    intincomingPOID = System.Convert.ToInt32(strincomingPOID);
    //stringincomingCurrency = Request.QueryString["pocurrency"];
  
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
        MTGenericForm1.TemplateName = "Core.UI.CopyExistingProductOffering";
        MTGenericForm1.ReadOnly = false;

        ProductOfferingServiceClient clientGetPO = new ProductOfferingServiceClient();

        clientGetPO.ClientCredentials.UserName.UserName = UI.User.UserName;
        clientGetPO.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        ProductOffering existingProductOffering;

        clientGetPO.GetProductOffering(new PCIdentifier(intincomingPOID), out existingProductOffering);

        clientGetPO.Close();

        //SourceProductOffering = objMTProductCatalogGetPO.GetProductOffering(intincomingPOID); 
        
        //Initialize some values from the the original PO
        productoffering.Name = "Copy Of " + existingProductOffering.Name;
        productoffering.DisplayName = "Copy Of " + existingProductOffering.DisplayName;
        productoffering.Description = existingProductOffering.Description;
        productoffering.Currency = existingProductOffering.Currency;
        productoffering.EffectiveTimeSpan.StartDate = existingProductOffering.EffectiveTimeSpan.StartDate;
        productoffering.POPartitionId = existingProductOffering.POPartitionId;

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

  try
     {
      //I know this is redundant but for now it is working. 
      MTProductCatalog objMTProductCatalogCopyPO = new MTProductCatalog();

       IMTProductOffering SourceProductOffering, NewProductOffering;

      SourceProductOffering = objMTProductCatalogCopyPO.GetProductOffering(intincomingPOID);

      NewProductOffering = SourceProductOffering.CreateCopy(productoffering.Name, productoffering.Currency);
    
      NewProductOffering.Name = productoffering.Name;
      NewProductOffering.DisplayName = productoffering.DisplayName;
      NewProductOffering.Description = productoffering.Description;
      NewProductOffering.EffectiveDate.StartDate = (System.DateTime)productoffering.EffectiveTimeSpan.StartDate;
      //NewProductOffering.SetCurrencyCode((string)productoffering.Currency);

       /* 
       foreach (LanguageCode langCode in Enum.GetValues(typeof(LanguageCode))) // Tried this but it gives error for MX/BR language codes
       {
         if ((langCode.ToString() != "MX") || (langCode.ToString() != "BR")) //Skip MX/BR Localization for now as they are giving some trouble
         {
           ((MetraTech.Localization.LocalizedEntity) NewProductOffering.DisplayNames).SetMapping(langCode.ToString(),productoffering.DisplayName);
           ((MetraTech.Localization.LocalizedEntity) NewProductOffering.DisplayDescriptions).SetMapping(langCode.ToString(), productoffering.Description);
         }
       }
     */  
    //There is a better way to do this, by looping through language list, I will implement that later  
    //Add Display Name localizations  
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("US", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("ES", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("ES-MX", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("PT-BR", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("DA", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("DE", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("GB", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("IT", productoffering.DisplayName);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayNames).SetMapping("FR", productoffering.DisplayName);
    
      //Add Description localizations
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("US", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("ES", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("ES-MX", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("PT-BR", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("DA", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("DE", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("GB", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("IT", productoffering.Description);
      ((MetraTech.Localization.LocalizedEntity)NewProductOffering.DisplayDescriptions).SetMapping("FR", productoffering.Description);
    

    //NewProductOffering.CreateCopy(productoffering.Name, productoffering.Currency);

      NewProductOffering.Save(); 

      //From here go to PO Details Screen so that user can be update the newly created Product Offering 
        string targetURL = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/ProductOffering.ViewEdit.Frame.asp|ID=" + NewProductOffering.ID;;
      
        Response.Redirect(targetURL, false);

    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
    }

  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ProductOfferingsList.aspx", false);
  }

}