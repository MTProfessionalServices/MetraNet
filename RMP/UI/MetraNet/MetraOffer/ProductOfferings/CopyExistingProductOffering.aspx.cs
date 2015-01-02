using System;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTProductCatalog;

namespace MetraNet.MetraOffer.ProductOfferings
{
  public partial class CopyExistingProductOffering : MTPage
  {
    public BaseProductOffering productoffering
    {
      get { return ViewState["productoffering"] as BaseProductOffering; } 
      set { ViewState["productoffering"] = value; }
    }

    public bool IsPartition { get { return PartitionLibrary.PartitionData.isPartitionUser; } }
    public int PartitionId { get { return PartitionLibrary.PartitionData.POPartitionId; } }
    public int IntincomingPoId { get; set; }
    public string StringComingPoId { get; set; } //so we can read it any time in the session 

    protected void Page_Load(object sender, EventArgs e)
    {
      StringComingPoId = Request.QueryString["poid"];
      IntincomingPoId = Convert.ToInt32(StringComingPoId);

      if (IsPostBack) return;

      productoffering = new BaseProductOffering();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = productoffering.GetType();

      //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "productoffering";

      //This is the Page Layout Template name
      MTGenericForm1.TemplateName = "Core.UI.CopyExistingProductOffering";
      MTGenericForm1.ReadOnly = false;

      using (var client = new ProductOfferingServiceClient())
        try
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }

          ProductOffering existingProductOffering;
          client.GetProductOffering(new PCIdentifier(IntincomingPoId), out existingProductOffering);

          //Initialize some values from the the original PO
          productoffering.Name = "Copy Of " + existingProductOffering.Name;
          productoffering.DisplayName = "Copy Of " + existingProductOffering.DisplayName;
          productoffering.Description = existingProductOffering.Description;
          productoffering.Currency = existingProductOffering.Currency;
          productoffering.EffectiveTimeSpan.StartDate = existingProductOffering.EffectiveTimeSpan.StartDate;
          productoffering.POPartitionId = PartitionId;

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

    protected void btnOK_Click(object sender, EventArgs e)
    {
      if (!MTDataBinder1.Unbind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

      try
      {
        //I know this is redundant but for now it is working. 
        var objMtProductCatalogCopyPo = new MTProductCatalog();

        var sourceProductOffering = objMtProductCatalogCopyPo.GetProductOffering(IntincomingPoId);
        var copyProductOffering = sourceProductOffering.CreateCopy(productoffering.Name, productoffering.Currency.ToString());
    
        copyProductOffering.Name = productoffering.Name;
        copyProductOffering.DisplayName = productoffering.DisplayName;
        copyProductOffering.Description = productoffering.Description;
        copyProductOffering.EffectiveDate.StartDate = productoffering.EffectiveTimeSpan.StartDate.GetValueOrDefault();
        copyProductOffering.POPartitionId = productoffering.POPartitionId;
 
        //There is a better way to do this, by looping through language list, I will implement that later  
        //Add Display Name localizations  
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("US", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("ES", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("ES-MX", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("PT-BR", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("DA", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("DE", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("GB", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("IT", productoffering.DisplayName);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayNames).SetMapping("FR", productoffering.DisplayName);
    
        //Add Description localizations
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("US", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("ES", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("ES-MX", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("PT-BR", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("DA", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("DE", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("GB", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("IT", productoffering.Description);
        ((MetraTech.Localization.LocalizedEntity)copyProductOffering.DisplayDescriptions).SetMapping("FR", productoffering.Description);

        copyProductOffering.Save(); 

        //From here go to PO Details Screen so that user can be update the newly created Product Offering 
        var targetUrl = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/ProductOffering.ViewEdit.Frame.asp|ID=" + copyProductOffering.ID+"**Master=" + Convert.ToBoolean(Request["Master"]);
        Response.Redirect(targetUrl, false);
      }
      catch (Exception ex)
      {
        SetError(ex.Message);
        Logger.LogError(ex.Message);
      }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("ProductOfferingsList.aspx", false);
    }
  }
}