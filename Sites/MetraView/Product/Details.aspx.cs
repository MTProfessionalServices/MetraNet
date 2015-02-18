using System;
using System.Threading;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;

public partial class Product_Details : MTPage
{
  AccountSlice accountSlice;
  SingleProductSlice productSlice;

  public string pvLayoutFilename { get; set; }
  public object pvObject { get; set; }

  public string AccountSliceString { get; set; }
  public string ProductSliceString { get; set; }
  public string ParentSessionID { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if(Request.QueryString["accountSlice"] != null)
    {
      accountSlice = SliceConverter.FromString<AccountSlice>(Request.QueryString["accountSlice"]);
      AccountSliceString = Request.QueryString["accountSlice"];
    }

    if (Request.QueryString["productSlice"] != null)
    {
      productSlice = SliceConverter.FromString<SingleProductSlice>(Request.QueryString["productSlice"]);
      ProductSliceString = Request.QueryString["productSlice"];
      if(productSlice == null)
      {
        Logger.LogWarning("No product slice provided.");
        Response.End();
      }
    }

    if (Request["parentSessionID"] != null)
    {
      ParentSessionID = Request["parentSessionID"];
    }

    var billManager = new BillManager(UI);
    if (productSlice != null)
    {
      string viewName = productSlice.ViewName();

      // Setup Layout
      pvLayoutFilename = billManager.GetProductViewLayout(viewName);
      MTFilterGrid1.XMLPath = pvLayoutFilename;
    
      // Setup ProductView to render
      pvObject = billManager.GetProductViewObjectByName(viewName);
      MTFilterGrid1.ProductViewObjectName = pvObject.GetType().FullName;
      MTFilterGrid1.ProductViewAssemblyName = pvObject.GetType().Assembly.Location;
    }
  }

  /// <summary>
  /// On Load Complete gives you a chance to change the default properties on the grid.
  /// </summary>
  /// <param name="e"></param>
  protected override void OnLoadComplete(EventArgs e)
  {
     // Setup DataSource
    if (String.IsNullOrEmpty(ParentSessionID))
    {
      MTFilterGrid1.DataSourceURL =
        String.Format("{0}/AjaxServices/ProductDetailSvc.aspx?productSlice={1}&accountSlice={2}",
                      Request.ApplicationPath,
                      SliceConverter.ToString(productSlice),
                      SliceConverter.ToString(accountSlice));
    }
    else
    {
      // Child usage has a parent session id that is used as a filter
      MTFilterGrid1.DataSourceURL =
        String.Format("{0}/AjaxServices/ProductDetailSvc.aspx?productSlice={1}&accountSlice={2}&parentSessionID={3}",
                      Request.ApplicationPath,
                      SliceConverter.ToString(productSlice),
                      SliceConverter.ToString(accountSlice),
                      ParentSessionID);
    }

    // Set Product View Defaults
    string viewName;
    try
    {
      viewName = GetLocalizedText(productSlice.ViewName());
    }
    catch (Exception exc)
    {
      Logger.LogError(exc.Message);
      viewName = productSlice.ViewID.Name;
    }
    MTFilterGrid1.Title = (string.IsNullOrEmpty(MTFilterGrid1.Title)) ? viewName : MTFilterGrid1.Title;  
    MTFilterGrid1.Width = 710;
    MTFilterGrid1.Height = 360;
    MTFilterGrid1.PageSize = 10;
    MTFilterGrid1.FilterLabelWidth = 170;
    MTFilterGrid1.FilterInputWidth = 220;
    MTFilterGrid1.FilterColumnWidth = 340;
    MTFilterGrid1.EnableFilterConfig = true;
    MTFilterGrid1.EnableColumnConfig = true;

    bool bUseSaveSearch = false;
    if(SiteConfig.Settings.BillSetting.AllowSavedReports.HasValue)
    {
      if(SiteConfig.Settings.BillSetting.AllowSavedReports.Value)
      {
        bUseSaveSearch  = true;
      }
    }
    MTFilterGrid1.EnableSaveSearch = bUseSaveSearch;
    MTFilterGrid1.EnableLoadSearch = bUseSaveSearch;
    MTFilterGrid1.FilterPanelCollapsed = true;
    MTFilterGrid1.Resizable = true;
    MTFilterGrid1.DisplayCount = true;
    MTFilterGrid1.ShowTopBar = false;
    MTFilterGrid1.AjaxTimeout = "180000";

    if(String.IsNullOrEmpty(MTFilterGrid1.CustomImplementationFilePath))
    {
      MTFilterGrid1.CustomImplementationFilePath = String.Format("{0}/JavaScript/Details.aspx.js", Request.ApplicationPath);
    }

    //MTFilterGrid1.NoRecordsText = "No records found.";  //

    // if using default layout, then add all the elements
    SetDefaultProperties();
  }

  #region Default Properties
  /// <summary>
  /// If we are using the default template for the product view we fill in the turn down with all the elements
  /// </summary>
  private void SetDefaultProperties()
  {
    if (pvLayoutFilename.ToLower().EndsWith("defaultproductviewlayout.xml"))
    {
      foreach (var prop in pvObject.GetType().GetProperties())
      {
        if (prop.Name.ToLower().StartsWith("is") &&
           prop.Name.ToLower().EndsWith("dirty"))
        {
          continue;
        }

        if (!prop.Name.ToLower().EndsWith("valuedisplayname"))
        {
          if (prop.Name.ToLower().EndsWith("displayname") &&
              prop.Name.ToLower() != "displayname")
          {
            continue;
          }
        }

        if (prop.PropertyType != typeof(int) &&
            prop.PropertyType != typeof(double) &&
            prop.PropertyType != typeof(decimal) &&
            prop.PropertyType != typeof(string) &&
            prop.PropertyType != typeof(DateTime) &&
            prop.PropertyType != typeof(bool)&&
            prop.PropertyType != typeof(int?) &&
            prop.PropertyType != typeof(double?) &&
            prop.PropertyType != typeof(decimal?) &&
            prop.PropertyType != typeof(DateTime?) &&
            prop.PropertyType != typeof(bool?)


          )
        {
          continue;
        }
        if (prop.Name.ToLower().EndsWith("valuedisplayname"))
        {
          continue;
        }

        if (MTFilterGrid1.FindElementByID(prop.Name) != null)
        {
          continue;
        }


        var element = new MTGridDataElement();
        element.DataIndex = prop.Name;
        element.ID = prop.Name;
        element.ShowInExpander = true;
        element.Exportable = true;

        // If you add new columns to t_acc_usage table, you will need to modify this "if" condition.
          if( prop.Name == "IntervalID" ||
              prop.Name == "ViewID" ||
              prop.Name == "Currency" ||
              prop.Name == "Amount" ||
              prop.Name == "PITemplate" ||
              prop.Name == "PIInstance" ||
              prop.Name == "TaxAmountAsString" ||
              prop.Name == "TaxAmount" ||
              prop.Name == "StateTaxAmountAsString" ||
              prop.Name == "StateTaxAmount" ||
              prop.Name == "FederalTaxAmountAsString" ||
              prop.Name == "FederalTaxAmount" ||
              prop.Name == "CountyTaxAmountAsString" ||
              prop.Name == "CountyTaxAmount" ||
              prop.Name == "LocalTaxAmountAsString" ||
              prop.Name == "LocalTaxAmount" ||
              prop.Name == "OtherTaxAmountAsString" ||
              prop.Name == "OtherTaxAmount" ||
              prop.Name == "AmountWithTaxAsString" ||
              prop.Name == "AmountWithTax" ||
              prop.Name == "IsPreBillTransaction" ||
              prop.Name == "IsAdjusted" ||
              prop.Name == "IsPreBillAdjusted" ||
              prop.Name == "IsPostBillAdjusted" ||
              prop.Name == "CanAdjust" ||
              prop.Name == "CanRebill" ||
              prop.Name == "CanManageAdjustments" ||
              prop.Name == "PreBillAdjustment" ||
              prop.Name == "PreBillAdjustmentID" ||
              prop.Name == "PostBillAdjustment" ||
              prop.Name == "PostBillAdjustmentID" ||
              prop.Name == "IsIntervalSoftClosed" ||
              prop.Name == "IsTaxInclusive" ||
              prop.Name == "IsTaxAlreadyCalculated"||
              prop.Name == "IsTaxInformational")
          {
              element.HeaderText = prop.Name;
          }
          else
          {
              if (productSlice.ViewID.ID.HasValue)
              {
                  BillManager billManager = new BillManager(UI);
                  string headerText;
                  try
                  {
                    headerText = GetLocalizedText(billManager.GetFQN(productSlice.ViewID.ID.Value) + "/" + prop.Name);
                  }
                  catch (Exception exc)
                  {
                    Logger.LogError(exc.Message);
                    headerText = productSlice.ViewName() + "/" + prop.Name;
                  }
                  element.HeaderText = headerText;
                      
              }
              else
              {
                  element.HeaderText = prop.Name;
              }

          }
          
        element.IsColumn = false;
        element.Filterable = false;

        if (prop.PropertyType == typeof(int) ||
           prop.PropertyType == typeof(double) ||
           prop.PropertyType == typeof(decimal) ||
            prop.PropertyType == typeof(int?) ||
           prop.PropertyType == typeof(double?) ||
           prop.PropertyType == typeof(decimal?)
          )
        {
          element.DataType = MTDataType.Numeric;
        }

        if ((prop.PropertyType == typeof(DateTime)) || (prop.PropertyType == typeof(DateTime?)))
        {
          element.DataType = MTDataType.Date;
        }

        if (prop.PropertyType == typeof(Enum))
        {
          element.DataType = MTDataType.List;
        }

        if (prop.PropertyType == typeof(string))
        {
          element.DataType = MTDataType.String;
        }

        if ((prop.PropertyType == typeof(bool)) || (prop.PropertyType == typeof(bool?)))
        {
          element.DataType = MTDataType.Boolean;
        }

        MTFilterGrid1.Elements.Add(element);
      }

    }

    //make a second pass through the elements and format the turndowns for Currency fields
    foreach (MTGridDataElement elt in MTFilterGrid1.Elements)
    {
      if (elt.ID.ToLower().EndsWith("asstring"))
      {
        string baseElementName = elt.ID.Substring(0, elt.ID.Length - "asstring".Length);
        MTGridDataElement decimalElement = MTFilterGrid1.FindElementByID(baseElementName);
        if (decimalElement != null)
        {
          decimalElement.ShowInExpander = false;
        }
      }
    }

  }
  #endregion

}
