using System;
using System.IO;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Threading;
using System.Globalization;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Localization;
using MetraTech.OnlineBill;
using MetraTech.UI.Tools;
using RCD = MetraTech.Interop.RCD;
using System.Text;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.IO.Compression;

namespace MetraTech.UI.Common
{

  /// <summary>
  /// MetraTech User Interface Base Page
  /// </summary>
  /// <remarks>
  /// All MetraTech ASP.Net pages should derrive from MTPage.
  /// MTPage inherits from <see cref="System.Web.UI.Page"/>.
  /// </remarks>
  /// <example>
  /// <code>
  /// 
  /// using MetraTech.UI.Common;
  ///
  /// namespace MetraView
  /// {
  ///   public class test : MTPage
  ///   { ...
  ///   
  /// </code>
  /// </example>
  public class MTPage : Page
  {

    #region Properties

    /// <summary>
    /// Returns the current UI Manager. Setup at login time.
    /// </summary>
    public UIManager UI
    {
      get { return Session[Constants.UI_MANAGER] as UIManager; }
      set { Session[Constants.UI_MANAGER] = value; }
    }

    /// <summary>
    /// Page Navigation Manager, the execute of this class is used to fire events, and causes page transitions.
    /// This object is initialized for each page request.
    /// </summary>
    private PageNavManager mPageNav;
    public PageNavManager PageNav
    {
      get { return mPageNav; }
      set { mPageNav = value; }
    }

    /// <summary>
    /// Returns the current help page.  Setup on page load.
    /// </summary>
    public string HelpPage
    {
      get { return Session[Constants.HELP_PAGE] as string; }
      set { Session[Constants.HELP_PAGE] = value; }
    }
    
    /// <summary>
    /// Get the MetraTech logger object
    /// </summary>
    private Logger mLog = new Logger("[MTPage]");
    public Logger Logger
    {
      get { return mLog; }
      set { mLog = value; }
    }

    /// <summary>
    /// Gets the template for the CDT.
    /// </summary>
    public string TemplatePath
    {
      get
      {
        RCD.IMTRcd rcd = new RCD.MTRcd();
        string path = Path.Combine(rcd.ExtensionDir, "Account\\Config\\PageLayouts");
        return path + "\\";

        //return Request.PhysicalApplicationPath + "\\" + "Templates" + "\\";
      }
    }
	
    /// <summary>
    /// The current UI ApplicationTime.  This maybe metratime or a value set
    /// by the UI (like when accounts are being looked up in the future).  
    /// </summary>
    public DateTime ApplicationTime
    {
     get
     {
       if (Session[Constants.APP_TIME] == null)
       {
         Session[Constants.APP_TIME] = MetraTime.Now;
       }
       return (DateTime)Session[Constants.APP_TIME];
     }
     set
     {
       Session[Constants.APP_TIME] = value;
     }
    }

    /// <summary>
    /// Returns the current application URL. Useful as it uses HttpContext and doesn't rely on having a Request object.
    /// </summary>
    public string ApplicationURL
    {
      get
      {
        return string.Format("{0}://{1}{2}",
                                      HttpContext.Current.Request.Url.Scheme,
                                      HttpContext.Current.Request.ServerVariables["HTTP_HOST"],
                                      (HttpContext.Current.Request.ApplicationPath.Equals("/")) ? string.Empty : HttpContext.Current.Request.ApplicationPath
          );
      }
    }

      #endregion

    #region Public Methods

    public string Encrypt(string str)
    {
      if (Session["QueryStringEncrypt"] == null)
      {
        Session["QueryStringEncrypt"] = new QueryStringEncrypt();
      }

      QueryStringEncrypt enc = (QueryStringEncrypt)Session["QueryStringEncrypt"];
      return enc.EncryptString(str);
    }

    public string Decrypt(string str)
    {
      if(Session["QueryStringEncrypt"] == null)
      {
        Session["QueryStringEncrypt"] = new QueryStringEncrypt();   
      }

      QueryStringEncrypt enc = (QueryStringEncrypt)Session["QueryStringEncrypt"];
      return enc.DecryptString(str);
    }

    /// <summary>
    /// Finds a Control recursively. Note: finds the first match and exits.
    /// </summary>
    /// <param name="Root">starting control</param>
    /// <param name="Id">control id to find</param>
    /// <returns></returns>
    public static Control FindControlRecursive(Control Root, string Id)
    {
      if (Root == null)
        return null;
      if (Root.ID == Id)
        return Root;

      foreach (Control Ctl in Root.Controls)
      {
        Control FoundCtl = FindControlRecursive(Ctl, Id);
        if (FoundCtl != null)
          return FoundCtl;
      }

      return null;
    }

    /// <summary>
    /// FindControlIterative
    /// </summary>
    /// <param name="control"></param>
    /// <param name="id"></param>
    /// <returns></returns>
    public static Control FindControlIterative(Control control, string id)
    {
      Control ctl = control;

      LinkedList<Control> controls = new LinkedList<Control>();

      while (ctl != null)
      {
        if (ctl.ID == id)
        {
          return ctl;
        }
        foreach (Control child in ctl.Controls)
        {
          if (child.ID == id)
          {
            return child;
          }
          if (child.HasControls())
          {
            controls.AddLast(child);
          }
        }
        ctl = controls.First.Value;
        controls.Remove(ctl);
      }
      return null;
    }


    /// <summary>
    /// Redirect to MessagePage.  Should be called outside of try block.
    /// </summary>
    /// <param name="title"></param>
    /// <param name="message"></param>
    public void ConfirmMessage(string title, string message)
    {
      /*Response.Redirect(String.Format(UI.DictionaryManager["MessagePage"] + "?title={0}&msg={1}",
          Server.UrlEncode(title),
          Server.UrlEncode(message)));*/
      ConfirmMessage(title, message, null);
    }

    /// <summary>
    /// Redirect to MessagePage.  Should be called outside of try block.
    /// </summary>
    /// <param name="title"></param>
    /// <param name="message"></param>
    /// <param name="returnUrl">Indicates an URL to return back from confirmation page.</param>
    public void ConfirmMessage(string title, string message, string returnUrl)
    {
      Response.Redirect(String.Format(UI.DictionaryManager["MessagePage"] + "?title={0}&msg={1}{2}",
          Server.UrlEncode(title),
          Server.UrlEncode(message),
          string.IsNullOrWhiteSpace(returnUrl) ? string.Empty : string.Format("&returnUrl={0}", HttpUtility.UrlEncode(returnUrl))));
    }

    /// <summary>
    /// Returns localized text based on a MetraNet FQN (Fully Qualified Name)
    /// </summary>
    /// <param name="fqn"></param>
    /// <returns></returns>
    public string  GetLocalizedText(string fqn)
    {
      var localizedDecription = LocalizedDescription.GetInstance();
      return localizedDecription.GetByName(GetLanguageCode().ToString(), fqn);
    }

    /// <summary>
    /// Get MetraNet language code for the current thread culture
    /// </summary>
    /// <returns></returns>
    public LanguageCode GetLanguageCode()
    {
      try
      {
        var languageCode = (LanguageCode)CommonEnumHelper.GetEnumByValue(typeof(LanguageCode), Thread.CurrentThread.CurrentUICulture.ToString());
        return languageCode;
      }
      catch (Exception)
      {
        return LanguageCode.US;
      }
    }
    #endregion
    
    #region Protected Methods

    protected override void OnInit(EventArgs e)
    {
      base.OnInit(e);
      if (DesignMode)
        return;

      ViewStateUserKey = Session.SessionID;
    }

    protected override void OnLoad(EventArgs e)
    {
      Session.CodePage = 65001;
      Response.Charset = "utf-8";

      // Set the current Page, ViewState, state, and wf name in the PageNav object.
      if (UI != null)
      {
        PageNav = new PageNavManager(UI.User, this, ViewState);
      }

      // Setup help page
      SetupHelpUrl();

      base.OnLoad(e);

     }

    private string GenerateValidateFormScript()
    {
      String sLoopElementScript = @"var ctrl=Ext.getCmp(arrControls[i]);
                                    if(ctrl !== undefined){
                                      if (!ctrl.validate()){
                                        if (typeof(resetButtonClickCount) == 'function') resetButtonClickCount();
                                        return false;
                                      }
                                    }
                                    ";
      StringBuilder sScript = new StringBuilder();
      sScript.Append("<script type=\"text/javascript\">");
      List<Control> controlList = new List<Control>();

      FindMTControls(this, ref controlList);

      sScript.Append("function ValidateForm(){ var arrControls=[");
      int i = 0;
      foreach (Control pageControl in controlList)
      {
        {
          if (i > 0)
          {
            sScript.Append(",");
          }
          sScript.Append("'" + pageControl.ClientID + "'");

          i++;
        }
      }
      sScript.Append("];");

      sScript.Append("for(var i=0;i<arrControls.length;i++){");
      sScript.Append(sLoopElementScript);
      sScript.Append("}");
      sScript.Append("return true;}");
      sScript.Append("</script>");

      return sScript.ToString();
    }

    /// <summary>
    /// Returns the content placeholder control, which is the root for all UI controls on the page
    /// </summary>
    /// <returns></returns>
    private Control GetContentPlaceholder()
    {
      if (Page.HasControls())
      {
        if (Controls.Count > 0)
        {
          if(Controls[0].HasControls())
          {
            foreach (Control level2Control in Controls[0].Controls)
            {
              if (level2Control is HtmlForm)
              {
                if (level2Control.HasControls())
                {
                  foreach (Control level3Control in level2Control.Controls)
                  {
                    if (level3Control is ContentPlaceHolder)
                    {
                      return level3Control;
                    }
                  }
                }
              }
            }
          }
        }
      }
      return null;
    }

    private void FindMTControls(Control Root, ref List<Control> controlList)
    {
      if(!Root.HasControls())
      {
        return;
      }

      foreach(Control curCtrl in Root.Controls)
      {
        //if this control is MT control, add it to the list
        string controlTypeName = curCtrl.GetType().Name;

        if((controlTypeName == "MTCheckBox") ||
          (controlTypeName == "MTDatePicker") ||
          (controlTypeName == "MTDropDown") ||
          (controlTypeName == "MTNumberField") ||
          (controlTypeName == "MTRadio") ||
          (controlTypeName == "MTPasswordMeter") ||
          (controlTypeName == "MTTextArea") ||
          (controlTypeName == "MTTextBoxControl") ||
          (controlTypeName == "MTSuperBoxSelect"))
        {
          controlList.Add(curCtrl);
        }

        //recurse over the child
        FindMTControls(curCtrl, ref controlList);
      }
    }

    protected override void OnPreRender(EventArgs e)
    {
      base.OnPreRender(e);

      string sScript = String.Format("<script type=\"text/javascript\">var JSMetraTime = new Date({0},{1},{2},{3},{4},{5},{6});var JSVirtualFolder='{7}';</script>",
        MetraTime.Now.Year,
        (MetraTime.Now.Month - 1),
        MetraTime.Now.Day,
        MetraTime.Now.Hour,
        MetraTime.Now.Minute,
        MetraTime.Now.Second,
        MetraTime.Now.Millisecond,
        HttpRuntime.AppDomainAppVirtualPath);  

      //if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "JavaScriptMetraTime"))
      //{
      //  Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JavaScriptMetraTime", sScript);
      //}

      sScript += GenerateValidateFormScript();
      if (!Page.ClientScript.IsClientScriptBlockRegistered(Page.GetType(), "JavaScriptValidateForm"))
      {
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JavaScriptValidateForm", sScript);
      }

    }

    /// <summary>
    /// Create javascript variable containing current MetraTime
    /// </summary>
    public void SetupJavascriptMetraTime()
    {
      
    }

    /// <summary>
    /// Generate Wiki help link for the page.
    /// </summary>
    public void SetupHelpUrl()
    {
      try
      {
        if (Request.ServerVariables["SCRIPT_NAME"].Contains("AjaxServices")) return;

        string pageName = Path.GetFileName(Request.ServerVariables["SCRIPT_NAME"]);
        pageName = pageName.Replace(".aspx", ".hlp.htm");
        string filePath = "";

        if ((Request.ApplicationPath == "/MetraView") && ((pageName == "BEList.hlp.htm")  || (pageName == "BEEdit.hlp.htm")))
        {
          HelpPage = "/MetraViewHelp/en-US/mvaindex.htm";
          filePath = Server.MapPath(HelpPage);
        }
        else
        {
          HelpPage = String.Format("{0}Help/{1}/index.htm?toc.htm?{2}", Request.ApplicationPath,
                                    Thread.CurrentThread.CurrentCulture, pageName);
          filePath = Server.MapPath(HelpPage.Substring(0, HelpPage.IndexOf('?'))).Replace("index.htm", pageName);
        }
        

        if (!File.Exists(filePath))
        {
            Logger.LogInfo(String.Format("Missing help page: {0}, defaulting to index.htm", filePath));
          HelpPage = String.Format("{0}Help/{1}/index.htm", Request.ApplicationPath, Thread.CurrentThread.CurrentCulture);        

            filePath = Server.MapPath(HelpPage);
            //Default to EN-US if we have more trouble.
            if (!File.Exists(filePath))
            {
                // Set to en-us if you can't find Current Culture Help
                HelpPage = string.Format("{0}Help/{1}/index.htm", Request.ApplicationPath, "en-us");
            }
        }
      }
      catch
      {
      }
    }

    /// <summary>
    /// InitializeCulture based on the browser's locale or the value in session.
    /// </summary>
    protected override void InitializeCulture()
    {
      if (Session[Constants.SELECTED_LANGUAGE] != null)
      {
        Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(Session[Constants.SELECTED_LANGUAGE].ToString());
        Thread.CurrentThread.CurrentUICulture = new CultureInfo(Session[Constants.SELECTED_LANGUAGE].ToString());
      }
      
      if ((!Request.IsAuthenticated) && (HttpContext.Current.Session != null))
      {
          if (UI != null)
          {
              if (UI.User.AccountId != 0)
              {
                  string url = Request.QueryString["ReturnUrl"];
                  if ((!url.ToLower().Equals("%2fmetranet")) || (!url.ToLower().Equals("/metranet")))
                  {
                      System.Web.Security.FormsAuthentication.SetAuthCookie(UI.User.UserName, false);
                      Response.Redirect(url);
                  }
              }
          }
      }

      base.InitializeCulture();
    }

    /// <summary>
    /// Trace events in run time only, not in designer view
    /// </summary>
    /// <param name="eventName"></param>
    protected void TraceEvent(string eventName)
    {
      if (Context != null)
      {
        Trace.Write("MetraTech UI Event", eventName);
        Logger.LogDebug(String.Format("MetraTech UI Event: {0}", eventName));
      }
    }

    /// <summary>
    /// Sets an error in session that will be displayed by the error user control.
    /// Also logs, the error to MTLog.
    /// </summary>
    /// <param name="error"></param>
    protected void SetError(string error)
    {
      if (Context != null)
      {
        Session[Constants.ERROR] = error;
        Logger.LogError(error);
      }
    }

    /// <summary>
    /// Sets an error from MAS in session that will be displayed by the error user control.
    /// Also logs, the error to MTLog.
    /// </summary>
    /// <param name="fe"></param>
    protected void SetMASError(FaultException<MASBasicFaultDetail> fe)
    {
      foreach (string msg in fe.Detail.ErrorMessages)
      {
        // CORE-6182 Security: /MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx page is vulnerable to Cross-Site Scripting 
        // Removed insecure formatting
        //Session[Constants.ERROR] = msg + "<br />";
        Session[Constants.ERROR] = msg + Environment.NewLine;
      }
      string errCodeString = Utils.ExtractString(Session[Constants.ERROR].ToString(), "status '", "'");
      if (errCodeString != "")
      {
        string detailedError = Utils.MTErrorMessage(errCodeString);
        Session[Constants.ERROR] += "  " + detailedError;
      }
    }

    protected override void OnError(EventArgs e)
    {
      // At this point we have information about the error
      HttpContext ctx = HttpContext.Current;
      if ((ctx == null) || (ctx.Session == null))
      {
        Response.Redirect (ctx.Request.ApplicationPath  + "/Login.aspx",true);
      }
      if ((UI == null) || (UI.User == null) || (UI.User.AccountId <= 0))
      {
        Response.Redirect(ctx.Request.ApplicationPath  +"/Login.aspx", true);
      }

      Exception exception = ctx.Server.GetLastError();

      Session[Constants.ERROR] = exception.Message;

     // string errorInfo =
     //    "<br /><b>Message:</b> " + exception.Message +
     //    "<br /><b>Offending URL:</b> " + ctx.Request.Url +
     //    "<br /><b>Source:</b> " + exception.Source +
     //    "<br /><b>Stack trace:</b> <a href='JavaScript:alert(\"" + exception.StackTrace + "\")'>show details</a>" +
     //    "<br /><br /><a target='_top' href='" + ctx.Request.ApplicationPath + "/Default.aspx'>Home</a>";

     // ctx.Response.Write("<html><head>");
      //// ctx.Response.Write("<link rel=\"stylesheet\" type=\"text/css\" href=\"/Res/Ext/resources/css/ext-all.css?v=6.5\" />");
      // ctx.Response.Write("<link rel=\"stylesheet\" type=\"text/css\" href=\"/Res/Styles/baseStyle.css?v=6.5\"/>");
     // ctx.Response.Write("<link rel=\"stylesheet\" type=\"text/css\" href=\"/Res/Styles/menuStyle.css?v=6.5\"/>");
     // ctx.Response.Write("</head><body>");
     // ctx.Response.Write("<div class=\"CaptionBar\">");
     // ctx.Response.Write("Page Error");
     // ctx.Response.Write("</div>");
     // ctx.Response.Write("<div class=\"AboutBox\">");
     // ctx.Response.Write(errorInfo);
     // ctx.Response.Write("</div></body></html>");

      Logger.LogException("Exception caught by MTPage", exception);

      // To let the page finish running we clear the error
      ctx.Server.ClearError();

      base.OnError(e);
    }

    #endregion

    #region Compress Viewstate
    public static byte[] Compress(byte[] data)
    {
      MemoryStream output = new MemoryStream();
      GZipStream gzip = new GZipStream(output, CompressionMode.Compress, true);
      gzip.Write(data, 0, data.Length);
      gzip.Close();
      return output.ToArray();
    }

    public static byte[] Decompress(byte[] data)
    {
      MemoryStream input = new MemoryStream();
      input.Write(data, 0, data.Length);
      input.Position = 0;
      GZipStream gzip = new GZipStream(input, CompressionMode.Decompress, true);
      MemoryStream output = new MemoryStream();
      byte[] buff = new byte[64];
      int read = -1;
      read = gzip.Read(buff, 0, buff.Length);
      while (read > 0)
      {
        output.Write(buff, 0, read);
        read = gzip.Read(buff, 0, buff.Length);
      }
      gzip.Close();
      return output.ToArray();
    }

    private ObjectStateFormatter _formatter =new ObjectStateFormatter();

    protected override void SavePageStateToPersistenceMedium(object viewState)
    {
      MemoryStream ms = new MemoryStream();
      _formatter.Serialize(ms, viewState);
      byte[] viewStateArray = ms.ToArray();
      ClientScript.RegisterHiddenField("__COMPRESSEDVIEWSTATE", Convert.ToBase64String(Compress(viewStateArray)));
    }

    protected override object LoadPageStateFromPersistenceMedium()
    {
      string vsString = Request.Form["__COMPRESSEDVIEWSTATE"];
      byte[] bytes = Convert.FromBase64String(vsString);
      bytes = Decompress(bytes);
      return _formatter.Deserialize(Convert.ToBase64String(bytes));
    }
    #endregion
  }
}