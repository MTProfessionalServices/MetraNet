using System;
using MetraTech.ExpressionEngine.Metadata;
using MetraTech.UI.Common;

public partial class AjaxServices_GetMetadata : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Response.Write(MetadataHelper.RetrieveJsonMetadata());
    Response.End();
  }
}
