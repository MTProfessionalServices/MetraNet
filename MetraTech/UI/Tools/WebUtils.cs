using System;
using System.Configuration;
using System.Web;
using System.Reflection;
using System.Data;
using System.IO;
using System.Web.Caching;
using System.Web.UI;
using System.Web.Compilation;
using System.CodeDom;
using System.Web.SessionState;
using System.Runtime.Remoting.Contexts;


namespace MetraTech.UI.Tools
{
  [ExpressionPrefix("Code")]
  public class CodeExpressionBuilder : ExpressionBuilder
  {
    public override CodeExpression GetCodeExpression(BoundPropertyEntry entry,
       object parsedData, ExpressionBuilderContext context)
    {
      return new CodeSnippetExpression(entry.Expression);
    }
  }
	/// <summary>
	/// Summary description for WebUtils.
	/// </summary>
	public class WebUtils
	{

		#region ASP.Net Helper Functions
        /// <summary>
        /// Returns a fully qualified HTTP path from a partial path starting out with a ~.
        /// Same syntax that ASP.Net internally supports.
        /// </summary>
        /// <param name="RelativePath"></param>
        /// <returns></returns>
        public static string ResolveUrl(string RelativePath)
        {
            if (RelativePath == null)
                return null;

            if (RelativePath.IndexOf(":") != -1)
                return RelativePath;
    
            // *** Fix up image path for ~ root app dir directory
            if (RelativePath.StartsWith("~"))
            {
                if (HttpContext.Current != null)
                    return HttpContext.Current.Request.ApplicationPath + RelativePath.Substring(1);
                else
                    // *** Assume current directory is the base directory
                    return RelativePath.Substring(1);
            }

            return RelativePath;
        }

        /// <summary>
        /// This method returns a fully qualified server Url which includes
        /// the protocol, server, port in addition to the server relative Url.
        /// 
        /// It work like Page.ResolveUrl, but adds these to the beginning.
        /// This method is useful for generating Urls for AJAX methods
        /// </summary>
        /// <param name="ServerUrl">Any Url, either App relative or fully qualified</param>
        /// <returns></returns>
        public static string ResolveServerUrl(string ServerUrl)
        {
            if (ServerUrl.ToLower().StartsWith("http"))
                return ServerUrl;

            // *** Start by fixing up the Url an Application relative Url
            string Url = ResolveUrl(ServerUrl);

            Uri ExistingUrl = HttpContext.Current.Request.Url;
            Url = ExistingUrl.Scheme + "://" + ExistingUrl.Authority + Url;

            return Url;
        }



		/// <summary>
		/// Sets a user's Locale based on the browser's Locale setting. If no setting
		/// is provided the default Locale is used.
		/// </summary>
		public static void SetUserLocale(string CurrencySymbol) 
		{
			HttpRequest Request = HttpContext.Current.Request;
			if (Request.UserLanguages == null)
				return;

			string Lang =  Request.UserLanguages[0];
			if (Lang != null) 
			{
				// *** Problems with Turkish Locale and upper/lower case
				// *** DataRow/DataTable indexes
				if (Lang.StartsWith("tr") )
					return;

				if (Lang.Length < 3) 
					Lang = Lang + "-" + Lang.ToUpper();
				try 
				{
					System.Threading.Thread.CurrentThread.CurrentCulture =  new System.Globalization.CultureInfo(Lang) ; 
					
					if (CurrencySymbol != null && CurrencySymbol != "")
						System.Threading.Thread.CurrentThread.CurrentCulture.NumberFormat.CurrencySymbol = 
						  CurrencySymbol;
				}
				catch 
				{;}
			}
		}

        /// <summary>
        /// Finds a Control recursively. Note finds the first match and exits
        /// </summary>
        /// <param name="Root"></param>
        /// <param name="Id"></param>
        /// <returns></returns>
    public static Control FindControlRecursive(Control Root, string Id)
    {
      if ((Root.ID != null) && (Root.ID.ToLower() == Id.ToLower()))
      {
        return Root;
      }
      foreach (Control Ctl in Root.Controls)
      {
        Control FoundCtl = FindControlRecursive(Ctl, Id);
        if (FoundCtl != null)
          return FoundCtl;
      }

      return null;
    } 

		/// <summary>
		/// Reads Web Form FormVariable names into an object's proeprties matching by
		/// property/field name. An optional prefix (like 'txt') may be used to read
		/// values. Only a shallow parse is done.
		/// </summary>
		/// <param name="Target"></param>
		/// <param name="FormVarPrefix"></param>
		public static void FormVarsToObject(object Target,string FormVarPrefix) 
		{
			if (FormVarPrefix == null)
				FormVarPrefix = "";

			HttpRequest Request = HttpContext.Current.Request;

			MemberInfo[] miT = Target.GetType().FindMembers(MemberTypes.Field | MemberTypes.Property,
				   Utils.MemberAccess, null,null);

			foreach (MemberInfo Field in miT) 
			{
				string Name = Field.Name;
				
				FieldInfo fi = null;
				PropertyInfo pi = null;
				Type FieldType = null;

				if (Field.MemberType == MemberTypes.Field)  
				{
					fi = (FieldInfo) Field;	
					FieldType = fi.FieldType;
				}
				else 
				{
					pi = (PropertyInfo) Field;
					FieldType = pi.PropertyType;
				}

				string strValue = Request.Form[FormVarPrefix + Name];
				if (strValue == null) 
				{
					// *** Must handle checkboxes/radios
					if ( FieldType == typeof(bool) )
						strValue = "false";
					else
						continue;
				}

				object Value = Utils.StringToTypedValue(strValue,FieldType);

				if (Value == null)
					return;

				try 
				{
					if (Field.MemberType == MemberTypes.Field) 
						fi.SetValue(Target,Value);
					else
						pi.SetValue(Target,Value,null);
				}
				catch {;}
			}
		}

        /// <summary>
        /// Generically retrieves form variables from an HTML form and stores it into a
        ///  specific DataRow.
        /// <seealso>Class WebUtils</seealso>
        /// </summary>
        /// <param name="loRow">
        /// A DataRow object to load up with values from the Request.Form[] collection.
        /// </param>
        /// <param name="Prefix">
        /// Optional prefix of form vars. For example, "txtCompany" has a "txt" prefix 
        /// to map to the "Company" field.
        /// </param>
        public static bool FormVarsToDataRow(DataRow loRow, string Prefix)
        {
            if (Prefix == null)
                Prefix = "";

            DataColumnCollection loColumns = loRow.Table.Columns;

            for (int x = 0; x < loColumns.Count; x++)
            {
                string lcFieldname = loColumns[x].ColumnName;

                string lcRowType = loColumns[x].DataType.Name;

                string lcValue = HttpContext.Current.Request.Form[Prefix + lcFieldname];
                if (lcValue == null)
                    continue;
                if (lcRowType == "String")
                    loRow[lcFieldname] = lcValue;
                else if (lcRowType == "Int16")
                    loRow[lcFieldname] = Convert.ToInt16(lcValue);
                else if (lcRowType == "Int32")
                    loRow[lcFieldname] = Convert.ToInt32(lcValue);
                else if (lcRowType == "Int64")
                    loRow[lcFieldname] = Convert.ToInt64(lcValue);
                else if (lcRowType == "Byte")
                    loRow[lcFieldname] = Convert.ToByte(lcValue);
                else if (lcRowType == "Decimal")
                    loRow[lcFieldname] = Convert.ToDecimal(lcValue);
                else if (lcRowType == "Double")
                    loRow[lcFieldname] = Convert.ToDouble(lcValue);
                else if (lcRowType == "Boolean")
                {
                    lcValue = lcValue.ToLower();
                    if (lcValue == "on" || lcValue == "true" || lcValue == "1")
                        loRow[lcFieldname] = true;
                    else
                        loRow[lcFieldname] = false;
                }
                else if (lcRowType == "DateTime")
                    loRow[lcFieldname] = Convert.ToDateTime(lcValue);
                else  // Not HANDLED!!!
                    throw (new Exception("Field Type not Handled in FormVarsToDataRow"));
            }

            return true;
        }

        /// <summary>
        /// Creates the headers required to force the current request to not go into 
        /// the client side cache, forcing a reload of the page.
        /// 
        /// This method can be called anywhere as part of the Response processing to 
        /// modify the headers. Use this for any non POST pages that should never be 
        /// cached.
        /// <seealso>Class WebUtils</seealso>
        /// </summary>
        /// <returns>Void</returns>
        public static void ForceReload()
        {
            HttpResponse Response = HttpContext.Current.Response;
            Response.Expires = 0;
            Response.AppendHeader("Pragma", "no-cache");
            Response.AppendHeader("Cache-Control", "no-cache, mustrevalidate");
        }


        /// <summary>
        /// (CORE-4877)
        /// Disables caching of the userControl parameter if the system is currently in DemoMode.
        /// Any cached user control (i.e., with an OutputCache directive) that should NOT be cached 
        /// while in DemoMode should call this method at the end of its Page_Load() method.
        /// (Source: http://stackoverflow.com/questions/1544162/how-to-remove-outputcache-programmatically-for-ascx
        /// or: http://dotnetslackers.com/ASP_NET/re-63091_ASP_NET_clear_user_control_output_cache.aspx)
        /// </summary>
        /// <param name="userControl">The user control</param>
        public static void DisableUserControlCachingInDemoMode(UserControl userControl)
        {
          bool demoMode = (System.Configuration.ConfigurationManager.AppSettings["DemoMode"].ToLower() == "true");
          if (demoMode)
          {
            string cacheKey = userControl.GetType().Name + "UCCacheKey";
            HttpRuntime.Cache.Insert(cacheKey, DateTime.Now);
            BasePartialCachingControl pcc = userControl.Parent as BasePartialCachingControl;
            pcc.Dependency = new CacheDependency(null, new string[] { cacheKey });

            // Updating cacheKey in the cache removes the dependent item, i.e., the user control, 
            // from the cache, thereby disabling caching of the user control.
            HttpRuntime.Cache.Insert(cacheKey, DateTime.Now);
          }
        }


        /// <summary>
        /// Returns the result from an ASPX 'template' page in the /templates directory of this application.
        /// This method uses an HTTP client to call into the Web server and retrieve the result as a string.
        /// </summary>
        /// <param name="TemplatePageAndQueryString">The name of a page (ASPX, HTM etc.) in the Templates directory to retrieve plus the querystring</param>
        /// <param name="ErrorMessage">If this method returns null this message will contain the error info</param>
        /// <returns>Merged Text or null if an HTTP error occurs - note: could also return an Error page HTML result if the template page has an error.</returns>
        public static string AspTextMerge(string TemplatePageAndQueryString, ref string ErrorMessage)
        {

            string MergedText = "";

            // *** Save the current request information
            HttpContext Context = HttpContext.Current;

            // *** Fix up the path to point at the templates directory
            TemplatePageAndQueryString = Context.Request.ApplicationPath +
                "/templates/" + TemplatePageAndQueryString;

            // *** Now call the other page and load into StringWriter
            StringWriter sw = new StringWriter();
            try
            {
                // *** IMPORTANT: Child page's FilePath still points at current page
                //                QueryString provided is mapped into new page and then reset
                Context.Server.Execute(TemplatePageAndQueryString, sw);
                MergedText = sw.ToString();
            }
            catch (Exception ex)
            {
                MergedText = null;
                ErrorMessage = ex.Message;
            }

            return MergedText;

        }


		/// <summary>
		/// Returns just the Path of a full Url. Strips off the filename and querystring
		/// </summary>
		/// <param name="url"></param>
		/// <returns></returns>
		public static string GetUrlPath(string url) 
		{
			int lnAt = url.LastIndexOf("/");
			if (lnAt > 0) 
			{
				return url.Substring(0,lnAt+1);
			}
			return "/";
		}

    /// <summary>
    /// "Magic" code to re-generate session ID
    /// </summary>
    /// <remarks>
    /// CORE-4889 - Session Identifier Not Updated 
    /// http://stackoverflow.com/questions/1368403/generating-a-new-asp-net-session-in-the-current-httpcontext?answertab=votes#tab-top
    /// </remarks>
    public static void RegenerateSessionId()
    {
      System.Web.SessionState.SessionIDManager manager = new System.Web.SessionState.SessionIDManager();
      string oldId = manager.GetSessionID(HttpContext.Current);
      string newId = manager.CreateSessionID(HttpContext.Current);
      bool isAdd = false;
      bool isRedir = false;
      manager.SaveSessionID(HttpContext.Current, newId, out isRedir, out isAdd);

      // Hack SessionStateModule internal fields
      HttpApplication ctx = (HttpApplication)HttpContext.Current.ApplicationInstance;
      HttpModuleCollection mods = ctx.Modules;
      System.Web.SessionState.SessionStateModule ssm = (SessionStateModule)mods.Get("Session");
      System.Reflection.FieldInfo[] fields = ssm.GetType().GetFields(BindingFlags.NonPublic | BindingFlags.Instance);
      SessionStateStoreProviderBase store = null;
      System.Reflection.FieldInfo rqIdField = null;
      System.Reflection.FieldInfo rqLockIdField = null;
      System.Reflection.FieldInfo rqStateNotFoundField = null;
      foreach (System.Reflection.FieldInfo field in fields)
      {
        if (field.Name.Equals("_store"))
          store = (SessionStateStoreProviderBase)field.GetValue(ssm);
        if (field.Name.Equals("_rqId"))
          rqIdField = field;
        if (field.Name.Equals("_rqLockId"))
          rqLockIdField = field;
        if (field.Name.Equals("_rqSessionStateNotFound"))
          rqStateNotFoundField = field;
      }

      object lockId = rqLockIdField.GetValue(ssm);
      if ((lockId != null) && (oldId != null)) store.ReleaseItemExclusive(HttpContext.Current, oldId, lockId);
      rqStateNotFoundField.SetValue(ssm, true);
      rqIdField.SetValue(ssm, newId);
    }
		#endregion
	}
}
