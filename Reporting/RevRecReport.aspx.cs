using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;

public partial class RevRecReport : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      // TODO:  Get data to bind to and place in viewstate
     
      // TODO:  Set binding properties and template on MTGenericForm control
      // MTGenericForm1.RenderObjectType = Data.GetType();
      // MTGenericForm1.RenderObjectInstanceName = "Data";
      // MTGenericForm1.TemplatePath = TemplatePath;
      // MTGenericForm1.ReadOnly = false;
    }
  }
}
