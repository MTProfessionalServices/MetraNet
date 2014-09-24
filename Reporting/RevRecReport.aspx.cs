using System;
using MetraTech.UI.Common;

public partial class RevRecReport : MTPage
{
  public string month1;
  public string month2;
  public string month3;
  public string month4;
  public string month5;
  public string month6;
  public string month7;
  public string month8;
  public string month9;
  public string month10;
  public string month11;
  public string month12;
  public string month13;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      var now = new DateTime(DateTime.Now.Year, DateTime.Now.Month-1, 1);
      month1 = now.ToString("MMM yyyy");
      month2 = now.AddMonths(1).ToString("MMM yyyy");
      month3 = now.AddMonths(2).ToString("MMM yyyy");
      month4 = now.AddMonths(3).ToString("MMM yyyy");
      month5 = now.AddMonths(4).ToString("MMM yyyy");
      month6 = now.AddMonths(5).ToString("MMM yyyy");
      month7 = now.AddMonths(6).ToString("MMM yyyy");
      month8 = now.AddMonths(7).ToString("MMM yyyy");
      month9 = now.AddMonths(8).ToString("MMM yyyy");
      month10 = now.AddMonths(9).ToString("MMM yyyy");
      month11 = now.AddMonths(10).ToString("MMM yyyy");
      month12 = now.AddMonths(11).ToString("MMM yyyy");
      month13 = now.AddMonths(12).ToString("MMM yyyy");

      // TODO:  Get data to bind to and place in viewstate
     
      // TODO:  Set binding properties and template on MTGenericForm control
      // MTGenericForm1.RenderObjectType = Data.GetType();
      // MTGenericForm1.RenderObjectInstanceName = "Data";
      // MTGenericForm1.TemplatePath = TemplatePath;
      // MTGenericForm1.ReadOnly = false;
    }
  }
}
