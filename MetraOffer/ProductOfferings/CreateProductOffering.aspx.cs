using System;
using System.Linq;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraNet.MetraOffer.ProductOfferings
{
  public partial class MetraOfferCreateProductOffering : MTPage
  {
    public BaseProductOffering ProductOffering
    {
      get { return ViewState["productoffering"] as BaseProductOffering; } //The ViewState labels are immaterial here..
      set { ViewState["productoffering"] = value; }
    }

    public bool IsPartition { get { return PartitionLibrary.PartitionData.isPartitionUser; } }
    public int PartitionId { get { return PartitionLibrary.PartitionData.POPartitionId; } }

    protected void Page_Load(object sender, EventArgs e)
    {
      if (IsPostBack) return;
      try
      {
        ProductOffering = new BaseProductOffering();

        MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
        MTGenericForm1.RenderObjectType = ProductOffering.GetType();

        //This should be same as the public property defined above 
        MTGenericForm1.RenderObjectInstanceName = "productoffering";

        //This is the Page Layout Template name
        MTGenericForm1.TemplateName = "Core.UI.CreateProductOffering";
        MTGenericForm1.ReadOnly = false;

        ProductOffering.Currency = SystemCurrencies.USD; //Default Currency set to USD on page load

        if (IsPartition)
        {
          ProductOffering.POPartitionId = PartitionId;
          ProductOffering.Name = PartitionLibrary.PartitionData.PartitionUserName + ":";
        }
        else
        {
          ProductOffering.POPartitionId = 1;
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

    protected void btnOK_Click(object sender, EventArgs e)
    {
      if (!MTDataBinder1.Unbind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }

      //Initialize some read only values 
      PartitionLibrary.RetrievePartitionInformation();

      var displayName = string.IsNullOrEmpty(ProductOffering.DisplayName)
                          ? ProductOffering.Name
                          : ProductOffering.DisplayName;

      var codes = Enum.GetNames(typeof(LanguageCode));
      var localizedDisplayName =
        codes.Select(code => (LanguageCode)Enum.Parse(typeof(LanguageCode), code)).Where(x => x != LanguageCode.US)
             .ToDictionary(languageCode => languageCode, languageCode => string.Format("{0} {1}{2}{3}", displayName, "{", languageCode, "}"));
      localizedDisplayName.Add(LanguageCode.US, displayName);

      var localizedDescriptions = codes.Select(code => (LanguageCode)Enum.Parse(typeof(LanguageCode), code))
             .ToDictionary(languageCode => languageCode, languageCode => ProductOffering.Description);

      var newProductOffering = new ProductOffering
        {
          Name = ProductOffering.Name,
          DisplayName = displayName,
          Description = ProductOffering.Description,
          Currency = ProductOffering.Currency,
          CanUserSubscribe = false,
          CanUserUnsubscribe = false,
          EffectiveTimeSpan = {StartDate = ProductOffering.EffectiveTimeSpan.StartDate},
          IsHidden = false,
          POPartitionId = IsPartition ? PartitionId : ProductOffering.POPartitionId,
          LocalizedDisplayNames = localizedDisplayName,
          LocalizedDescriptions = localizedDescriptions
        };
      
      using (var client = new ProductOfferingServiceClient())
        try
        {
          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }
          client.SaveProductOffering(ref newProductOffering);
          //From here go to PO Details Screen so that user can be update the newly created Product Offering 
          var targetUrl = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/ProductOffering.ViewEdit.Frame.asp|ID=" + newProductOffering.ProductOfferingId;
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