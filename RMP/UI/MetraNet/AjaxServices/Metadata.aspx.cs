using System;
// Uncomment line 3 and line 10 in case you want to use ExpressionEngine
//using MetraTech.ExpressionEngine.Metadata;
using MetraTech.UI.Common;

public partial class AjaxServices_GetMetadata : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
//    Response.Write(MetadataHelper.RetrieveJsonMetadata());
    Response.End();
  }
}
