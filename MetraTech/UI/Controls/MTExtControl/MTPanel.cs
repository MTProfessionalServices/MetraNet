using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.ComponentModel;
using MetraTech.SecurityFramework;

namespace MetraTech.UI.Controls
{
  [ToolboxData("<{0}:MTPanel runat=server></{0}:MTPanel>")]
  [Designer("System.Web.UI.Design.ReadWriteControlDesigner, System.Design")]
  [PersistChildren(true)]
  [ParseChildren(false)]
  public class MTPanel : Panel
  {
    #region Properties
    private string text;

    public string Text
    {
      get { return text; }
      set { text = value; }
    }

    private bool collapsible = true;

    public bool Collapsible
    {
      get { return collapsible; }
      set { collapsible = value; }
    }

    private bool collapsed = false;

    public bool Collapsed
    {
      get { return collapsed; }
      set { collapsed = value; }
    }

    private bool enableChrome = true;

    public bool EnableChrome
    {
      get { return enableChrome; }
      set { enableChrome = value; }
    }

    public string ToolbarButtonsScript { get; set; }

    #endregion

    #region JavaScript

    private const string EXT_AFTER_RENDER_SCRIPT = @"
                                                    ,afterRender: function(component, eOpts)
                                                      {
                                                        var formCmp =  Ext.get('formPanel_%%CONTROL_ID%%');                               
                                                        formCmp.setWidth(%%FORMWIDTH%%);
                                                        Ext.DomHelper.insertHtml('beforeEnd', formCmp.query('.x-panel-header-text')[0], '%%FORM_TITLE%%');

                                                        var div = document.createElement('div');
                                                        div.id = 'divPanelRender_%%CONTROL_ID%%';
                                                        div.className = 'x-panel-tbar'; 
                                                        Ext.get(div).insertAfter(Ext.get('formPanel_%%CONTROL_ID%%').first());

                                                        %%TOOLBARBUTTONS%%
                                                      }";


    private const string EXT_SCRIPT = @"
          <div id='MyFormDiv_%%CONTROL_ID%%' class='mtpanel'></div>
                      <script type=""text/javascript"">
                          Ext.onReady(function(){
                            var pnl_%%CONTROL_ID%% = new Ext.Panel({
                                    bodyStyle: 'padding:5px 5px 5px 5px',  
                              layout:'form',
                              %%FORM_WIDTH%%
                              id:'formPanel_%%CONTROL_ID%%',
                              labelWidth:75,
                              frame:true,
                              title:'%%FORM_TITLE%%',
                              cls:'%%CSS_CLASS%%',
                              iconCls:'mtpanel-formicon',
                              collapsible:%%COLLAPSIBLE%%,
                              collapsed:%%COLLAPSED%%,
                              contentEl:'divChildren_%%CONTROL_ID%%'  
                              %%AFTER_RENDER_SCRIPT%%           
                            });
                          pnl_%%CONTROL_ID%%.render(Ext.get('MyFormDiv_%%CONTROL_ID%%'));
                      });
                          
                      </script>";
    #endregion

    protected override void Render(System.Web.UI.HtmlTextWriter writer)
    {
      if (EnableChrome)
      {
        string html = EXT_SCRIPT.Replace("%%CONTROL_ID%%", ClientID.Replace(".", "_"));
        if (!string.IsNullOrEmpty(Text))
        {
          // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
          // Added JavaScript encoding
          //html = html.Replace("%%FORM_TITLE%%", String.IsNullOrEmpty(Text)? Text: Page.Server.HtmlEncode(Text).Replace("'","\\'"));
          html = html.Replace("%%FORM_TITLE%%", Text.EncodeForHtml().EncodeForJavaScript());
        }
        else
          html = html.Replace("%%FORM_TITLE%%", "");

        if ((Width != null) && (Width.Value > 0))
          html = html.Replace("%%FORM_WIDTH%%", String.Format("width:'{0}',", Width.Value.ToString()));
        else
          html = html.Replace("%%FORM_WIDTH%%", "");

        if (String.IsNullOrEmpty(CssClass))
        {
          CssClass = "mtpanel-inner";
        }
        html = html.Replace("%%CSS_CLASS%%", CssClass);

        html = html.Replace("%%COLLAPSIBLE%%", Collapsible.ToString().ToLower());
        html = html.Replace("%%COLLAPSED%%", Collapsed.ToString().ToLower());

        var toolbarHtml = string.Empty;

        if (!String.IsNullOrEmpty(ToolbarButtonsScript))
        {
          var toolbar = string.Format("var tb = {0};tb.render('divPanelRender_{1}');", ToolbarButtonsScript, ClientID.Replace(".", "_"));
          toolbar = toolbar.Replace("%%TOOLBARBUTTONSWIDTH%%", Width.Value.ToString());

          toolbarHtml = EXT_AFTER_RENDER_SCRIPT.Replace("%%CONTROL_ID%%", ClientID.Replace(".", "_"));
          toolbarHtml = toolbarHtml.Replace("%%FORM_TITLE%%", Text.EncodeForHtml().EncodeForJavaScript());
          toolbarHtml = toolbarHtml.Replace("%%FORMWIDTH%%", Width.Value.ToString());
          toolbarHtml = toolbarHtml.Replace("%%TOOLBARBUTTONS%%", toolbar);
        }

        html = html.Replace("%%AFTER_RENDER_SCRIPT%%", toolbarHtml);

        writer.Write("<div id='divChildren_" + ClientID.Replace(".", "_") + "'>");
        foreach (Control ctrl in Controls)
        {
          ctrl.RenderControl(writer);
        }
        writer.Write("</div>");

        writer.Write(html);
      }
      else
      {
        base.Render(writer);
      }
    }

    /// <summary>
    /// Render all panels etc as DIV not SPAN
    /// </summary>
    /// <param name="writer"></param>
    public override void RenderBeginTag(System.Web.UI.HtmlTextWriter writer)
    {
      if (EnableChrome)
      {
        writer.AddAttribute(HtmlTextWriterAttribute.Id, this.ClientID.Replace(".", "_"));
        writer.RenderBeginTag(HtmlTextWriterTag.Div);
      }
      else
      {
        base.RenderBeginTag(writer);
      }
    }
  }
}
