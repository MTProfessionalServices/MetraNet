using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Controls;
using System.Collections.Generic;
using MetraTech.DataAccess;
using MetraTech.UI.Common;
using MetraTech.Accounts.Type;
using MetraTech.Core.Services.ClientProxies;

/// <summary>
/// Summary description for GridRenderer
/// </summary>
public static class GridRenderer
{
  /// <summary>
  /// Helper method to add a dropdown list to a grid filter element from a dictionary.
  /// Note: the dictionary should be something like myValues.Add("Value Display Name", 0) or myValues.Add("My Value", "My Value")
  /// </summary>
  /// <param name="MyGrid1">gridlayoutcontrol</param>
  /// <param name="idElement">id of the element to add the list to</param>
  /// <param name="values">dictionary/map of "Display Name" (key) and "Value"</param>
  public static void AddFilterListToElement(MTFilterGrid MyGrid1, string idElement, Dictionary<string, string> values)
  {
    MTGridDataElement gridElement = GridRenderer.FindElementByID(MyGrid1, idElement);
    if (gridElement == null)
    {
      return;
    }

    //May want to add code to sort the list based on an argument passed

    foreach (string name in values.Keys)
    {
      MTFilterDropdownItem filterItem = new MTFilterDropdownItem();
      filterItem.Key = values[name].ToString();
      filterItem.Value = name;
      gridElement.FilterDropdownItems.Add(filterItem);
    }
  }

  public static MTGridDataElement FindElementByID(MTFilterGrid MyGrid1, string elementID)
  {
    foreach (MTGridDataElement element in MyGrid1.Elements)
    {
      if (element.ID.ToLower() == elementID.ToLower())
      {
        return element;
      }
    }

    return null;
  }

  public static void RemoveArchivedStatusFilter(MTFilterGrid MyGrid1)
  {
    MTGridDataElement accountTypeElement = FindElementByID(MyGrid1, "AccountStatus");
    if (accountTypeElement == null)
    {
      return;
    }
  }

  public static void AddPriceListFilter(MTFilterGrid MyGrid1, UIManager UI)
  {
    MTGridDataElement priceListTypeElement = FindElementByID(MyGrid1, "Internal.PriceList");
    if (priceListTypeElement == null)
    {
      return;
    }

    using (IMTConnection conn = ConnectionManager.CreateConnection())
    {

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_PRICELISTS__"))
      {
        stmt.AddParam("%%RS_WHERE%%", "");
        // ESR-3879 filter for only NON ICB price lists
        stmt.AddParam("%%FILTER%%", "n_Type=1");
        stmt.AddParam("%%ID_LANG%%", UI.SessionContext.LanguageID);

        using (IMTDataReader reader = stmt.ExecuteReader())
        {
          while (reader.Read())
          {
            MTFilterDropdownItem filterItem = new MTFilterDropdownItem();

            if (!reader.IsDBNull("id_prop"))
            {
              filterItem.Key = reader.GetInt32("id_prop").ToString();
            }

            if (!reader.IsDBNull("nm_name"))
            {
              filterItem.Value = reader.GetString("nm_name");
            }

            priceListTypeElement.FilterDropdownItems.Add(filterItem);
           
          }
        }
      }
    }
  }

  public static void AddAccountTypeFilter(MTFilterGrid MyGrid1)
  {
    MTGridDataElement accountTypeElement = FindElementByID(MyGrid1, "AccountTypeID");
    if (accountTypeElement == null)
    {
      return;
    }

    MetraTech.Accounts.Type.AccountTypeCollection col = new MetraTech.Accounts.Type.AccountTypeCollection();
    List<string> sortList = new List<string>();
    Dictionary<string, int> map = new Dictionary<string, int>();
    List<string> exList =  new List<string>();
    //Retrieve "Root" account type from web.config (excluded from display on account type dropdown on advanced find filter) 
    exList.Add(ConfigurationManager.AppSettings["ExcludeAccountType"].ToString());

    //Retrieve "AllTypes" account type from AccountTemplate service config (excluded from display on account type dropdown on advanced find filter) 
    AccountService_GetAllAccountsTypeName_Client client = new AccountService_GetAllAccountsTypeName_Client();
    UserData userData = ((MTPage)MyGrid1.Page).UI.User;
    client.UserName = userData.UserName;
    client.Password = userData.SessionPassword;
    client.Invoke();
    exList.Add(client.InOut_typeName);
              
    foreach (AccountType accType in col.AccountTypes)
    {
      if(!exList.Contains(accType.Name))
      {       
          sortList.Add(accType.Name);
          map[accType.Name] = accType.ID;
      }
    }    
    sortList.Sort();

    foreach (string sortedItem in sortList)
    {
      MTFilterDropdownItem filterItem = new MTFilterDropdownItem();
      filterItem.Key = map[sortedItem].ToString();
      filterItem.Value = sortedItem;
      accountTypeElement.FilterDropdownItems.Add(filterItem);
    }
  }
}




  




