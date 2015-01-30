using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
using Resources;

public partial class MetraControl_FileManagement_File_Pending : MTPage
{
    public string customTitle;
    public string stateFilter = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
      if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
      {
        Response.End();
        return;
      }
      string customTitle = FileManagementResources.FILE_PENDING_TITLE;
        stateFilter = EnumHelper.GetDbValueByEnum(EFileState.PENDING).ToString();
        MTTitle1.Text = customTitle;
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        MTGridDataElement stateElement = MTFilterGrid1.FindElementByID("_State");

        if (stateElement != null)
        {
            stateElement.ElementValue =
                    EnumHelper.GetDbValueByEnum(EFileState.REJECTED).ToString();
            stateElement.ElementValue2 = "PENDING";
        }
      
        base.OnLoadComplete(e);
    }
}
