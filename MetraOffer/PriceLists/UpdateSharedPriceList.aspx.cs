using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Common;

public partial class MetraOffer_UpdateSharedPriceList : MTPage
{
  public PriceList sharedpricelist
  {
    get { return ViewState["sharedpricelist"] as PriceList; } //The ViewState labels are immaterial here..
    set { ViewState["sharedpricelist"] = value; }
  }

  public string strincomingPLID { get; set; } //so we can read it any time in the session 
  public int intincomingPLID { get; set; }

  public bool IsPartition
  {
    get { return PartitionLibrary.PartitionData.isPartitionUser; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    strincomingPLID = Request.QueryString["ID"];
    intincomingPLID = Convert.ToInt32(strincomingPLID);

    if (IsPostBack) return;

    sharedpricelist = new PriceList();

    MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
    MTGenericForm1.RenderObjectType = sharedpricelist.GetType();

    //This should be same as the public property defined above 
    MTGenericForm1.RenderObjectInstanceName = "sharedpricelist";

    //This is the Page Layout Template name
    MTGenericForm1.TemplateName = "Core.UI.UpdateSharedPriceList";
    MTGenericForm1.ReadOnly = false;

    using (var getPL = new PriceListServiceClient())
      try
      {
        if (getPL.ClientCredentials != null)
        {
          getPL.ClientCredentials.UserName.UserName = UI.User.UserName;
          getPL.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        PriceList spl;
        getPL.GetSharedPriceListByID(intincomingPLID, out spl);

        sharedpricelist.Name = spl.Name;
        sharedpricelist.Description = spl.Description;
        sharedpricelist.Currency = spl.Currency;
        sharedpricelist.PLPartitionId = spl.PLPartitionId;

        if (!MTDataBinder1.DataBind())
        {
          Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
        }
      }
      catch (Exception exc)
      {
        Logger.LogError(exc.ToString());
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
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    Page.Validate();

    using (var client = new PriceListServiceClient())
      try
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        var mypl = sharedpricelist;
        client.SaveSharedPriceList(ref mypl);

        client.Close();
        Response.Redirect("PriceListsList.aspx", false);

      }
      catch (Exception ex)
      {
        SetError(ex.Message);
        Logger.LogError(ex.Message);
        client.Abort();
      }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("PriceListsList.aspx?PreviousResultView=True");
  }

  protected void btnAddRatesToPT_Click(object sender, EventArgs e)
  {
    var targetUrl = "/MetraNet/TicketToMCM.aspx?Redirect=True&URL=/MCM/default/dialog/PriceList.AddParamTable.asp|ID=" +
                    intincomingPLID + "**FramedPriceList=true"; // sharedpricelist.ID;
    //We may try to redirect to another frame instead of page so that the close of that frame will bring back where you were before, but OK for now
    Response.Redirect(targetUrl, false);
  }
}