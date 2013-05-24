using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SampleAspNetApp
{
    public partial class Events : System.Web.UI.Page
    {
        protected void Page_Init(object sender, EventArgs e)
        {
            this.sdsEvents.ConnectionString =
                string.Format("data source=\"{0}\"", Server.MapPath("~/App_Data/SecurityFramework.db"));
        }
    }
}