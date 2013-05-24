using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.ComponentModel;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
  public enum MTMessageWarningLevel
  {
    None = 0,
    Info = 1,
    Warning = 2,
    Error = 3
  }
  [ToolboxData("<{0}:MTMessage runat=server></{0}:MTMessage>")]
  [Designer("System.Web.UI.Design.ReadWriteControlDesigner, System.Design")]
  [PersistChildren(true)]
  [ParseChildren(false)]
  public class MTMessage : Panel
  {
    #region Properties

    private string text;
    /// <summary>
    /// Text of the error message
    /// </summary>
    public string Text
    {
      get { return text; }
      set { text = value; }
    }

    private MTMessageWarningLevel warningLevel = MTMessageWarningLevel.None;
    public MTMessageWarningLevel WarningLevel
    {
      get { return warningLevel; }
      set { warningLevel = value; }
    }
    #endregion

    #region Javascript
    
    // image <img border=\'0\' style=\'padding-right: 5px; \' src=\'/Res/Images/Icons/information.png\'>
    protected string EXT_SCRIPT = @"
            <div id='panelMessage_[%%CONTROL_ID%%]' style='padding:10px;display:[%%VISIBLE%%]'></div>
            <script language='javascript'>
              Ext.onReady(function(){
                        var moveNote = new Ext.Panel({
                            width: '[%%WIDTH%%]',
                            bodyStyle  : 'padding: 10px; background-color: #DFE8F6',
                            html: '[%%ICON%%]&nbsp;[%%MESSAGE_TEXT%%]</div>',
                            renderTo: 'panelMessage_[%%CONTROL_ID%%]'
                        });
                    });</script>";
    #endregion

    #region Methods
      protected override void Render(System.Web.UI.HtmlTextWriter writer)
      {
        string html = EXT_SCRIPT.Replace("[%%CONTROL_ID%%]", ClientID.Replace(".", "_"));
        // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
        // Added JavaScript encoding
        //html = html.Replace("[%%MESSAGE_TEXT%%]", Text);
        html = html.Replace("[%%MESSAGE_TEXT%%]", (Text ?? string.Empty).EncodeForJavaScript());

        if ((Width != null) && (Width.Value > 0))
        {
          html = html.Replace("[%%WIDTH%%]",  Width.Value.ToString());
        }
        else
        {
          html = html.Replace("[%%WIDTH%%]", "300");
        }

        html = html.Replace("[%%VISIBLE%%]", Visible.ToString().ToLower());

        //fill in the icon
        string imagePath = string.Empty;
        switch (warningLevel)
        {
          case MTMessageWarningLevel.None:
            imagePath = string.Empty;
            break;
          case MTMessageWarningLevel.Info:
            imagePath = "/Res/Images/Icons/information.png";
            break;
          case MTMessageWarningLevel.Warning:
            imagePath = "/Res/Images/Icons/information_error.png";
            break;
          case MTMessageWarningLevel.Error:
            imagePath = "/Res/Images/Icons/exclamation.png";
            break;
          default:
            imagePath = "/Res/Images/Icons/information.png";
            break;
        }

        //format image HTML
        string imageHTML = String.Empty;
        if (!String.IsNullOrEmpty(imagePath))
        {
          imageHTML = string.Format("<img border=\"0\" style=\"padding-right: 5px;\" src=\"{0}\">", imagePath);
          html = html.Replace("[%%ICON%%]", imageHTML);
        }
        
        writer.Write(html);
      }


      /// <summary>
      /// Render all panels etc as DIV not SPAN
      /// </summary>
      /// <param name="writer"></param>
      public override void RenderBeginTag(System.Web.UI.HtmlTextWriter writer)
      {
        writer.AddAttribute(HtmlTextWriterAttribute.Id, this.ClientID.Replace(".", "_"));
        writer.RenderBeginTag(HtmlTextWriterTag.Div);
      }


    #endregion

  }
}
