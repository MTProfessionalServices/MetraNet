using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;

namespace SampleAspNetApp
{
	public partial class PolicyActionsView : System.Web.UI.UserControl
	{
		private long _eventId;

		[Bindable(true)]
		public long EventId
		{
			get
			{
				return _eventId;
			}
			set
			{
				_eventId = value;

				this.sdsActions.SelectParameters[0].DefaultValue = value.ToString();
				this.BulletedList1.DataBind();
			}
		}

		protected void Page_Init(object sender, EventArgs e)
		{
			this.sdsActions.ConnectionString =
				string.Format("data source=\"{0}\"", Server.MapPath("~/App_Data/SecurityFramework.db"));
		}
	}
}