using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MetraTech.UI.Controls
{
  [DefaultProperty("Text")]
  [ToolboxData("<{0}:MTSection runat=server></{0}:MTSection>")]
  public class MTSection : WebControl
  {
    [Bindable(true)]
    [Category("Appearance")]
    [DefaultValue("")]
    [Localizable(true)]
    public string Text
    {
      get
      {
        String s = (String)ViewState["Text"];
        return ((s == null) ? String.Empty : s);
      }

      set
      {
        ViewState["Text"] = value;
      }
    }

    protected override void RenderContents(HtmlTextWriter output)
    {
      string html = @"<div class=""SectionCaptionBar"">&nbsp;{0}
                        <hr />
                      </div>";
      output.Write(String.Format(html, Text));
    }
  }
}
