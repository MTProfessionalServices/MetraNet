using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech.UI.Common;
using MetraTech.Interop.MTAuth;

[assembly: TagPrefix ("MetraTech.UI.Controls" , "MT") ]

namespace MetraTech.UI.Controls
{	

  /// <summary>
  /// MTSecurity is a panel container that will hide it's contents if the specified capabilities
  /// are not met.
  /// </summary>
  [ToolboxData("<{0}:MTSecurity runat=server Capabilities='' id='Security1'></{0}:MTSecurity>")]
	public class MTSecurity : Panel
	{
		
		public MTSecurity() : base()
		{			
		}

		[Browsable(true),
		Category("Behavior"),
		DefaultValue(""),
    Description("Capabilities required to render panel.")]
		public string Capabilities
		{
			get { return Convert.ToString(ViewState["MTCapabilitites"]); }
			set { ViewState["MTCapabilitites"] = value; }
		}
		
		/// <summary>
		/// Fires when the panel gets loaded
		/// </summary>
		/// <param name="e"></param>
		protected override void OnLoad(EventArgs e)
		{
			base.OnLoad(e);

      Visible = false;

      if (DesignMode)
        return;

      IMTSecurity security = new MTSecurityClass();

      // Check capabilities
      string[] caps = Capabilities.Split(',');
      foreach (string cap in caps)
      {
        IMTCompositeCapability requiredCap = security.GetCapabilityTypeByName(cap).CreateInstance();
        // If any capability check fails leave the panel hidden (Visible = false)
        if (!((MTPage)Page).UI.SessionContext.SecurityContext.CoarseHasAccess(requiredCap))  // just a coarse check
        {
          return;
        }
      }

      Visible = true;
		}

	}
}
