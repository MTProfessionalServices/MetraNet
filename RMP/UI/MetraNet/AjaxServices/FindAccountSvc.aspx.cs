using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Common;
using MetraTech;
using System.Web.Script.Serialization;
using System.ServiceModel;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Reflection;
using MetraTech.DomainModel.Enums;
using System.Text;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.BaseTypes;
using System.Threading;
using System.Linq;

public partial class AjaxServices_FindAccountSvc : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;
    private bool displayAliases = false;

    // CORE-7119 fix specific to the Advanced Find page to ensure that all items serialized to the json will have a unique id for the grid
    protected struct WrappedAccount
    {
        public Account account;
        public int advancedfinduniquerowid;      
    }

    // CORE-7119 fix specific to the Advanced Find page to ensure that all items serialized to the json will have a unique id for the grid
    protected bool wrapAccountsList(ref MTList<MetraTech.DomainModel.BaseTypes.Account> input,
                                    ref MTList<WrappedAccount> output)
    {
        try
        {
            int i = 0;
            foreach (var item in input.Items)
            {
                var wrappedAccount = new WrappedAccount { account = item, advancedfinduniquerowid = i };
                output.Items.Add(wrappedAccount);
                i++;
            }
            output.TotalRows = input.TotalRows;
        }
        catch (Exception ex)
        {
            Response.StatusCode = 500;
            Response.StatusDescription = Response.Status;
            Logger.LogError(ex.Message);
            SendResult(false, ex.Message);
            Response.End();
            return false;
        }
        return true;
    }

    protected bool ExtractDataInternal(AccountServiceClient client, ref MTList<MetraTech.DomainModel.BaseTypes.Account> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();

            items.PageSize = limit;
            items.CurrentPage = batchID;

            client.GetAccountList(ApplicationTime, ref items, displayAliases);

            foreach (MetraTech.DomainModel.BaseTypes.Account acc in items.Items)
            {
                FixAccount(acc);
            }
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            Response.StatusCode = 500;
            Response.StatusDescription = Response.Status;
            this.Logger.LogError(fe.Detail.ErrorMessages[0]);
            //Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
            SendResult(false, fe.Detail.ErrorMessages[0]);
            Response.End();
            return false;
        }
        catch (CommunicationException ce)
        {
            Response.StatusCode = 500;
            Response.StatusDescription = Response.Status;
            Logger.LogError(ce.Message);
            //Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
            SendResult(false, ce.Message);
            Response.End();
            return false;
        }
        catch (Exception ex)
        {
            Response.StatusCode = 500;
            Response.StatusDescription = Response.Status;
            Logger.LogError(ex.Message);
            //Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
            SendResult(false, ex.Message);
            Response.End();
            return false;
        }

        return true;
    }

    protected void SendResult(bool success, string msg)
    {
        string strResponse = "{success:'" + success.ToString().ToLower() + "',message:'" + msg + "'}";
        Response.Write(strResponse);
        Response.End();
    }

    protected bool ExtractData(AccountServiceClient client, ref MTList<MetraTech.DomainModel.BaseTypes.Account> items)
    {
        if (Page.Request["mode"] == "csv")
        {
            Response.BufferOutput = false;
            Response.ContentType = "application/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
            Response.BinaryWrite(BOM);
        }
        else
        {
            Response.ContentType = "text/json";
        }

        //if there are more records to process than we can process at once, we need to break up into multiple batches
        if ((items.PageSize > MAX_RECORDS_PER_BATCH || Page.Request["export"] == "all") && (Page.Request["mode"] == "csv"))
        {
            int totalRows = items.PageSize;

            if (Page.Request["export"] == "all")
            {
                try
                {
                    client.GetAccountListTotalRows(ApplicationTime, items, displayAliases, out totalRows);
                }
                #region Error Handling
                catch (FaultException<MASBasicFaultDetail> fe)
                {
                    Response.StatusCode = 500;
                    Response.StatusDescription = Response.Status;
                    this.Logger.LogError(fe.Detail.ErrorMessages[0]);
                    //Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
                    SendResult(false, fe.Detail.ErrorMessages[0]);
                    Response.End();
                    return false;
                }
                catch (CommunicationException ce)
                {
                    Response.StatusCode = 500;
                    Response.StatusDescription = Response.Status;
                    Logger.LogError(ce.Message);
                    //Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
                    SendResult(false, ce.Message);
                    Response.End();
                    return false;
                }
                catch (Exception ex)
                {
                    Response.StatusCode = 500;
                    Response.StatusDescription = Response.Status;
                    Logger.LogError(ex.Message);
                    //Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
                    SendResult(false, ex.Message);
                    Response.End();
                    return false;
                }
                #endregion
            }

            int advancePage = (totalRows % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

            int numBatches = advancePage + (totalRows / MAX_RECORDS_PER_BATCH);
            for (int batchID = 0; batchID < numBatches; batchID++)
            {
                ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH);

                string strCSV = ConvertObjectToCSV(items, (batchID == 0));
                Response.Write(strCSV);
            }
        }
        else
        {
            ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize);
            if (Page.Request["mode"] == "csv")
            {
                string strCSV = ConvertObjectToCSV(items, true);
                Response.Write(strCSV);
            }
        }

        return true;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((!String.IsNullOrEmpty(Request.QueryString["DisplayAliases"])) && (
          (Request.QueryString["DisplayAliases"] == "1") ||
          (Request.QueryString["DisplayAliases"].ToLower() == "y") ||
          (Request.QueryString["DisplayAliases"].ToLower() == "true")))
        {
            displayAliases = true;
        }
        using (new HighResolutionTimer("AccountFinderAjax", 5000))
        {
            AccountServiceClient client = null;

            try
            {
                client = new AccountServiceClient();
            //client.ClientCredentials.UserName.UserName = UI.User.UserName;
            //client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            client.ClientCredentials.UserName.UserName = UI.User.Ticket;
            client.ClientCredentials.UserName.Password = String.Empty;

                MTList<MetraTech.DomainModel.BaseTypes.Account> items = new MTList<MetraTech.DomainModel.BaseTypes.Account>();

                //request from inline search
                if (!String.IsNullOrEmpty(Request["query"]))
                {
                    string requestedUsername = Request["query"] + "%";
                    Regex rg1 = new Regex("\\*");
                    requestedUsername = rg1.Replace(requestedUsername, "%");

                    while (requestedUsername.IndexOf("%%") >= 0)
                    {
                        Regex rg2 = new Regex("%%");
                        requestedUsername = rg2.Replace(requestedUsername, "%");
                    }

                    MTFilterElement fe = new MTFilterElement("username", MTFilterElement.OperationType.Like_W, requestedUsername);
                    items.Filters.Add(fe);
                }

                SetPaging(items);
                SetSorting(items);
                if (Request.Form.Keys.OfType<string>().Contains("invoiceID"))
                {
                    // Search by invoice number
                    var rowSet = GetAccountByInvoice(Request["invoiceID"]);

                    while ((Int16)rowSet.EOF == 0)
                    {
                        // This circle has to work one time onle, due to an invoice is associated with one account.
                        MetraTech.DomainModel.BaseTypes.Account account = AccountLib.LoadAccount((int)rowSet.Value[0], UI.User, MetraTime.Now);
                        if (account != null)
                        {
                            items.Items.Add(account);
                        }

                        rowSet.MoveNext();
                    }

                    items.TotalRows = items.Items.Count;
                }
                else
                {
                    // Search by other conditions
                    SetFilters(items);

                    if (!String.IsNullOrEmpty(Request["query"]))
                    {
                        items.SortCriteria.Add(new SortCriteria("username", SortType.Ascending));
                    }

                    //unable to extract data
                    if (!ExtractData(client, ref items))
                    {
                        return;
                    }
                }

                if (items.Items.Count == 0)
                {
                    Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
                    try
                    {
                        Response.End();
                    }
                    catch (ThreadAbortException)
                    {

                    }
                    return;
                }

                if (Page.Request["mode"] != "csv")
                {
                    // CORE-7119 fix specific to the Advanced Find page to ensure that all items serialized to the json will have a unique id for the grid
                    MTList<WrappedAccount> wrappedItems = new MTList<WrappedAccount>();
                    wrapAccountsList(ref items, ref wrappedItems);
                    //convert accounts into JSON
                    JavaScriptSerializer jss = new JavaScriptSerializer();
                    string json = jss.Serialize(wrappedItems);
                    json = json.Replace(@"},""advancedfinduniquerowid""", @",""advancedfinduniquerowid""").Replace(@"""account"":{", ""); // CORE-7119 fix specific to the Advanced Find page to ensure that all items serialized to the json will have a unique id for the grid

                    //fix empty LDAP view
                    json = FixJsonDate(json);
                    Response.Write(json);
                }
                client.Close();
            }
            catch (ThreadAbortException)
            {

            }
            catch (Exception ex)
            {
                Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
                client.Abort();
                throw;
            }
            finally
            {
                Response.End();
            }
        }
    }

    private static bool GetMTDataMemberAttribute(PropertyInfo pi, out MTDataMemberAttribute attribute)
    {
        object[] attributes = pi.GetCustomAttributes(true);
        if (attributes != null)
        {
            foreach (object attr in attributes)
            {
                if (attr is MTDataMemberAttribute)
                {
                    attribute = (MTDataMemberAttribute)attr;
                    return true;
                }
            }
        }

        attribute = null;
        return false;
    }
    private static bool IsView(PropertyInfo pi, out string viewType, out string className)
    {
        MTDataMemberAttribute attribute;
        if (GetMTDataMemberAttribute(pi, out attribute))
        {
            if (!String.IsNullOrEmpty(attribute.ViewType))
            {
                viewType = attribute.ViewType;
                className = attribute.ClassName;
                return true;
            }
        }

        viewType = String.Empty;
        className = String.Empty;
        return false;
    }

    private static object CreateGenericObject(Type generic, Type innerType, params object[] args)
    {
        Type specificType = generic.MakeGenericType(new Type[] { innerType });
        return Activator.CreateInstance(specificType, args);
    }
    private static bool IsPartOfKey(PropertyInfo pi)
    {
        MTDataMemberAttribute attribute;
        if (GetMTDataMemberAttribute(pi, out attribute))
            return attribute.IsPartOfKey;

        return false;
    }

    private void FixView(MetraTech.DomainModel.BaseTypes.Account account, string viewName, string viewType, IList viewList)
    {
        MetraTech.DomainModel.BaseTypes.View view = MetraTech.DomainModel.BaseTypes.View.CreateView(viewType);

        /* Go thru all properties of the view.
         * If the property is part of the key, then find a corresponding Enum with the same name as the prop name.
         * Then, attempt to match each value in the enum with a view within the account object.
         * If account object doesn't have that view, we need to add it to the account.
         */
        //String prefix = "MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.";

        IList curViewList = (IList)account.GetType().GetProperty(viewName).GetValue(account, null);

        foreach (PropertyInfo pi in view.GetMTProperties())
        {
            if (IsPartOfKey(pi))
            {
                //find enum corresponding to pi.Name
                Type enumType = Nullable.GetUnderlyingType(pi.PropertyType); // EnumHelper.GetEnumTypeByTypeName(prefix + pi.Name);
                Logger.LogDebug("XXXXX FindAccountSvc.FixView: enumType={0}", enumType);
                List<MetraTech.DomainModel.BaseTypes.EnumData> enumList = BaseObject.GetEnumData(enumType);

                //for each item in enum, attempt to find a corresponding view in main object
                for (int i = 0; i < enumList.Count; i++)
                {
                    MetraTech.DomainModel.BaseTypes.EnumData enumInstance = enumList[i];

                    //check if this account has a view with name viewName that has a specific
                    //enum instance as part of key property, specified by pi.Name
                    bool bAccountHasView = CheckAccountForView(account, viewName, pi.Name, i, enumInstance.EnumInstance);

                    //if such a view does not exist, we need to create one
                    if (!bAccountHasView)
                    {
                        MetraTech.DomainModel.BaseTypes.View realView = MetraTech.DomainModel.BaseTypes.View.CreateView(viewType);
                        pi.SetValue(realView, enumInstance.EnumInstance, null);
                        curViewList.Insert(i, realView);
                    }
                }
            }
        }
    }

    private bool CheckAccountForView(MetraTech.DomainModel.BaseTypes.Account acc, string viewName, string keyPropName, int position, object value)
    {
        PropertyInfo pi = acc.GetType().GetProperty(viewName);
        if (pi.GetValue(acc, null) == null)
        {
            return false;
        }

        //check if count is available, if not, it is not a list of views
        if (pi.GetValue(acc, null).GetType().GetProperty("Count") == null)
        {
            return false;
        }

        //get the list of views
        object curViewList = acc.GetType().GetProperty(viewName).GetValue(acc, null);
        int count = (int)pi.GetValue(acc, null).GetType().GetProperty("Count").GetValue(curViewList, null);

        bool bFound = false;

        //iterate through each view in the list of views
        for (int i = 0; i < count; i++)
        {
            // get the indexed view, e.g. LDAP[n]
            object curView = curViewList.GetType().GetMethod("get_Item").Invoke(curViewList, new object[] { i });

            // get the value of the key property, e.g. LDAP[n].ContactView
            object keyPropValue = curView.GetType().GetProperty(keyPropName).GetValue(curView, null);

            if (EnumHelper.GetValueByEnum(value).ToString() == EnumHelper.GetValueByEnum(keyPropValue).ToString())
            {
                bFound = true;
                break;
            }
        }

        return bFound;

    }

    private void FixAccount(MetraTech.DomainModel.BaseTypes.Account account)
    {
        List<PropertyInfo> props = account.GetMTProperties();
        foreach (PropertyInfo pi in props)
        {
            string viewType;
            string className;

            if (IsView(pi, out viewType, out className))
            {
                //create placeholder
                Assembly ass = account.GetType().Assembly;
                object views = CreateGenericObject(typeof(List<>), ass.GetType(account.GetType().Namespace + "." + className), null);
                IList viewList = (IList)views;

                bool isList = (pi.PropertyType == views.GetType()) ? true : false;

                if (isList)
                {
                    FixView(account, pi.Name, viewType, viewList);
                }

                else
                {
                    if (pi.GetValue(account, null) == null)
                    {
                        pi.SetValue(account, MetraTech.DomainModel.BaseTypes.View.CreateView(viewType), null);
                    }
                }
            }
        }
    }

    /// <summary>
    /// Get account informantion by <paramref name="invoiceID"/>. Uses exact match.
    /// See \RMP\config\Queries\Account\CommonQueries.xml
    /// </summary>
    /// <param name="invoiceID"></param>
    /// <returns></returns>
    private static MetraTech.Interop.Rowset.IMTSQLRowset GetAccountByInvoice(string invoiceID)
    {
        MetraTech.Interop.Rowset.IMTSQLRowset myrowset = new MetraTech.Interop.Rowset.MTSQLRowset();
        myrowset.Init(@"queries\account");
        myrowset.SetQueryTag("__SEARCH_ACCOUNT_BY_INVOICE__");
        myrowset.AddParam("%%INVOICE_ID%%", invoiceID, false);
        myrowset.Execute();
        return myrowset;
    }
}
