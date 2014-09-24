using System;
using System.Web.Script.Serialization;
using ASP.Models;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;

public partial class AjaxServices_LoadRevenueRecognitionData : MTListServicePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      var items = new MTList<RevRecModel>();

      items.TotalRows = 1;
      items.PageSize = 10;
      items.CurrentPage = 1;


      var model = new RevRecModel();
      model.Id = 1;
      model.Amount1 = 0;
      items.Items.Add(model);

      //convert adjustments into JSON
      JavaScriptSerializer jss = new JavaScriptSerializer();
      string json = jss.Serialize(items);
      json = FixJsonDate(json);
      json = FixJsonBigInt(json);
      Response.Write(json);

    }
}