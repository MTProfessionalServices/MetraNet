<%@ Application Language="C#" %>
<%@ Import Namespace="MetraTech" %>
<%@ Import Namespace="MetraTech.Interop.MTAuth" %>
<%@ Import Namespace="MetraTech.Interop.RCD" %>
<%@ Import Namespace="MetraTech.UI.Tools"%>
<%@ Import Namespace="System.Web.Hosting"%>
<%@ Import Namespace="System.Resources"%>
<%@ Import Namespace="System.IO"%>
<%@ Import Namespace="MetraTech.UI.Common" %>
<%@ Import Namespace="MetraTech.Interop.MTEnumConfig" %>
<%@ Import Namespace="MetraTech.UI.CDT" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="MetraTech.SecurityFramework" %>
<%@ Import Namespace="MetraTech.Debug.Diagnostics" %>
<%@ Import Namespace="System.Diagnostics" %>

<script runat="server"> 
  
  void Application_Start(object sender, EventArgs e) 
  {
    // Pre load to cache singletons
    Application.Lock();
    Application["EnumConfigCache"] = new EnumConfigClass();
    Application["PageLayouts"] = new GenericObjectRenderer();
    Application.UnLock();

    CreateJavaScriptLocalizations();

    CreateLocalizedGlobalResources();

    // Setup security framework
    Application["Security"] = new MTSecurityClass();

    using (var rcd1 = new MTComSmartPtr<IMTRcd>())
    {
      rcd1.Item = new MTRcdClass();
      rcd1.Item.Init();
      
      //SECENG: Change SecurityFramework version
      var path = Path.Combine(rcd1.Item.ConfigDir, @"Security\Validation\MtSfConfigurationLoader.xml");
      //var path = Path.Combine(rcd1.Item.ConfigDir, @"Security\Validation\MtSecurityFramework.properties");
      var logger = new Logger("[MetraNetApplication]");
      logger.LogDebug("Security framework path: {0}", path);
      SecurityKernel.Initialize(path);
      SecurityKernel.Start();
    }
            
    // Load dictionary for each available culture
    char[] splitter = { ',' };
    string supportedCultures = "en-US"; // We don't use the dictionary for localized resources, so this is always just en-US
    foreach (string culture in supportedCultures.Split(splitter))
    {
      LoadDictionary(culture);
    }

    MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
    MetraTech.Interop.RCD.MTRcdFileList fileList = rcd.RunQueryInAlternateFolder(@"Account\AccountService.xml", true, rcd.ConfigDir);

    string configPath = "";
    if (fileList.Count > 0)
    {
        configPath = (string)fileList[0];
    }

    XmlDocument configDoc = new XmlDocument();
    configDoc.Load(configPath);

    XmlNode node = configDoc.SelectSingleNode(@"//AccountServiceConfig");
    Application["GetAccountListMaxPages"] = Int32.Parse(node.Attributes["GetAccountListMaxPages"].Value);
  }

  private void CreateLocalizedGlobalResources()
  {
    System.Diagnostics.ProcessStartInfo procStartInfo = new System.Diagnostics.ProcessStartInfo();
    IMTRcd processDir = new MTRcd();
    procStartInfo.FileName = Path.Combine(processDir.ConfigDir, @"Localization\") + @"\ResGen.exe";

    IMTRcd rcd = new MTRcd();
    string resourceFileLocation = Path.Combine(rcd.ConfigDir, @"Localization\Global");
    DirectoryInfo dir = new DirectoryInfo(resourceFileLocation);
    foreach (FileInfo file in dir.GetFiles("*.resx"))
    {
      procStartInfo.Arguments = file.FullName;
      procStartInfo.UseShellExecute = false;
      Process.Start(procStartInfo);
    }
  }

  /// <summary>
  //   Convert JSConsts.*.resx to Localized.*.js files
  /// </summary>
  private void CreateJavaScriptLocalizations()
  {
      foreach (var file in Directory.GetFiles(HostingEnvironment.MapPath("/MetraNet/App_GlobalResources"),
        "JSConsts*"))
      {
          if (!file.Contains("designer"))
          {
              string culture = Utils.ExtractString(Path.GetFileName(file), ".", ".");
              using (ResXResourceReader reader = new ResXResourceReader(file))
              {
                  StringBuilder js = new StringBuilder();
                  js.Append("// This file is auto generated from /MetraNet/App_GlobalResources/JSConsts.*.resx");
                  js.Append(Environment.NewLine);
                  foreach (DictionaryEntry entry in reader)
                  {
                      js.Append("var ");
                      js.Append(entry.Key);
                      js.Append(" = \"");
                      js.Append(entry.Value);
                      js.Append("\";");
                      js.Append(Environment.NewLine);
                  }
                  File.WriteAllText(Path.Combine(HostingEnvironment.MapPath("/Res/JavaScript/"), String.Format("Localized{0}.js",
                    String.IsNullOrEmpty(culture) ? "" : "." + culture)),
                    js.ToString());
              }
          }
      }
  }


  void Application_End(object sender, EventArgs e)
  {
    SecurityKernel.Stop();
    SecurityKernel.Shutdown();
  }

  void Application_BeginRequest(object sender, EventArgs e)
  {
    using (new MetraTech.Debug.Diagnostics.HighResolutionTimer("Security Check", 10000))
    {
      try
      {
        if (Application["Security"] != null && SecurityKernel.IsWebInspectorEnabled)
        {
          SecurityKernel.WebInspectorSubsystem.Api.ExecuteDefaultByCategory(
                WebInspectorEngineCategory.WebInspectorRequest.ToString(),
                new ApiInput(
                  new WebInspectorRequestApiInput(
                    HttpContext.Current.ApplicationInstance,
                    HttpContext.Current,
                    HttpContext.Current.Request,
                    HttpContext.Current.Response)));
          /*
          foreach (string key in Request.QueryString)
          {
            DetectBad(Request.QueryString[key]);
          }

          foreach (string key in Request.Form)
          {
            DetectBad(Request.Form[key]);
          }

          foreach (string key in Request.Cookies)
          {
            DetectBad(Request.Cookies[key].Value);
          }
           */
        }
      }
      catch (Exception exp)
      {
        var logger = new Logger("[MetraNetSecurity]");
        logger.LogException("Security framework exception: {0}", exp);
        Response.Write(Resources.Resource.TEXT_VALIDATION_ERROR);
        Response.End();
      }
    }
  }

  static void DetectBad(string v)
  {
    try
    {
      v.DetectBad();
    }
    catch (System.Exception)
    {
      // work around security framework ". " issue, where we have a false positive
      if(v.Contains(". "))
      {
        v.Replace(". ", "_").DetectBad();
      }
      //ESR-4621 Filtering on enums in usage PV 
      //(filtering on a PV for a string i.e. accountName=’TV4’ the semantics is to get all rows where accountName stars with ‘TV4’ so we will also get TV400.)
      else if (v.Contains("'"))
      {
          v.Replace("'", "").DetectBad();
      }    
      else
      {
        throw;
      }
    }
  }
  
  protected void Application_Error(Object sender, EventArgs e)
  {
    // At this point we have information about the error
    HttpContext ctx = HttpContext.Current;

    if (ctx == null)
    {
      Response.Redirect("~/login.aspx");
    }
    Exception exception = ctx.Server.GetLastError();

    // CORE-6182 Security: /MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx page is vulnerable to Cross-Site Scripting 
    // Removed insecure formatting

    //string errorInfo =
    //   "<br>Offending URL: " + ctx.Request.Url.ToString() +
    //   "<br>Source: " + exception.Source +
    //   "<br>Message: " + exception.Message +
    //   "<br>Stack trace: " + exception.StackTrace;

    string errorInfo =
       string.Format("{0}Offending URL: {1}{0}Source: {2}{0}Message: {3}{0}Stack trace: {4}", Environment.NewLine, ctx.Request.Url, exception.Source, exception.Message, exception.StackTrace);

    ctx.Response.Write("<html><head><link href=\"/Res/Styles/baseStyle.css\" type=\"text/css\" rel=\"stylesheet\" /><script src=\"/Res/JavaScript/Common.js?v=6.5\" type=\"text/javascript\"></head><body><div class=\"AboutBox\">");
    ctx.Response.Write(Resources.Resource.TEXT_VALIDATION_ERROR);
    ctx.Response.Write("</div></body></html>");
    Session[Constants.ERROR] = exception.Message;
    
    MetraTech.Logger logger = new MetraTech.Logger("[MetraNetApplication]");
    //logger.LogError(errorInfo.Replace("<br>", Environment.NewLine));
    logger.LogError(errorInfo);

    // To let the page finish running we clear the error
    ctx.Server.ClearError();
  }

  private void LoadDictionary(string culturePref)
  {
    DictionaryManager dict = new DictionaryManager(culturePref);

    string appFolder = HttpRuntime.AppDomainAppVirtualPath;
    string appPath = Server.MapPath(appFolder);
    
    dict.AddShared("APP_VIRTUAL_DIR", appFolder);
    dict.AddShared("APP_PATH", Server.MapPath(appFolder));
    dict.LoadDirectory(appPath + @"\Config\", "configuration", "item", culturePref);
    dict.LoadDirectory(appPath + @"\Config\" + culturePref, "configuration", "item", culturePref);
           
    dict.Render();

    Application.Lock();
    Application["DictionaryCache"] = dict;
    Application.UnLock();
  }
  
  void Session_Start(object sender, EventArgs e) 
  {
      Session[Constants.SELECTED_LANGUAGE] = "en-US";
  }

  void Session_End(object sender, EventArgs e) 
  {
      // Code that runs when a session ends. 
      // Note: The Session_End event is raised only when the sessionstate mode
      // is set to InProc in the Web.config file. If session mode is set to StateServer 
      // or SQLServer, the event is not raised.

      // TODO: clear workflows?
    DeleteAutoSavedSearches();
  }

  private void DeleteAutoSavedSearches()
  {
    if (Session["AdvancedSearchAccount"] != null) 
    {
      try
      {
        var sId = Session.SessionID;
        var iAccId = (int)Session["AdvancedSearchAccount"];
        using (MetraTech.DataAccess.IMTConnection oConn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
        {
          using (MetraTech.DataAccess.IMTCallableStatement callableStmt = oConn.CreateCallableStatement("DeleteSavedSearchBySessionID"))
          {
            callableStmt.AddParam("SessionID", MetraTech.DataAccess.MTParameterType.String, sId);
            callableStmt.AddParam("CreatedBy", MetraTech.DataAccess.MTParameterType.Integer, iAccId);
            callableStmt.ExecuteNonQuery();
          }
        }
      }
      catch (Exception exp)
      {
        var logger = new Logger("[Metranet]");
        logger.LogException("Autosaved searches delete exception: {0}", exp);
      }
    }
  }
       
</script>
