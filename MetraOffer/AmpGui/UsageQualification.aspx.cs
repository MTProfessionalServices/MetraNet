using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.UsageServer;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;
using System.IO;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;

public partial class AmpUsageQualificationPage : AmpWizardBasePage
{
  private MTList<ProductViewNameInstance> prodViewNames;

  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    // Set the current, next, and previous AMP pages right away.
    AmpCurrentPage = "UsageQualification.aspx";
    AmpNextPage = "SelectUsageQualification.aspx";
    AmpPreviousPage = "SelectUsageQualification.aspx";

    RetrieveUsageQualificationAction();


    if (AmpUsageQualificationAction != "View")
    {
      MonitorChangesInControl(UsageQualificationName);
      MonitorChangesInControl(UsageQualificationDescription);
      MonitorChangesInControl(UsageQualificationFilter);
    }

    // Use one client for all Amp service calls on page load
    AmpServiceClient ampSvcClient = null;
    try
    {
      ampSvcClient = new AmpServiceClient();
      if (ampSvcClient.ClientCredentials != null)
      {
        ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }
      if (!IsPostBack)
      {
        DefaultActionSettings(ampSvcClient);
        setValueControls(FieldDropDown.SelectedValue);
      }
      else
      {
        setTableDropDown(ampSvcClient);
        // Set the drop down list hover text
        setTableDropDownHoverText();
        setFieldDropDownHoverText();
        setAnotherUQGDropDownHoverText();
        setAnotherUQGLogicDropDownHoverText();
      }

      // Clean up client.
      ampSvcClient.Close();
      ampSvcClient = null;
    }
    catch (Exception ex)
    {
      var errorMessage = GetLocalResourceObject("TEXT_ERROR_GETTING_DATA").ToString();
      SetError(errorMessage);
      logger.LogException("An error occurred while retrieving data for the page.", ex);
    }
    finally
    {
      if (ampSvcClient != null)
      {
        ampSvcClient.Abort();
      }
    }

    // The Continue button should NOT prompt the user if the controls have changed.
    //TBD However, we don't need to call IgnoreChangesInControl(btnContinue) here
    // because of how OnClientClick is defined for the button.
    //IgnoreChangesInControl(btnContinue);
  }

  #region DefaultActionSettings

  private void DefaultActionSettings(AmpServiceClient ampSvcClient)
  {
    setNavButtons();
    if (AmpUsageQualificationAction == "Create")
    {
      setTableDropDown(ampSvcClient);
      setLogicDropDown();
      setFieldDropDown(ampSvcClient, "t_acc_usage");
      setValueControls("id_sess:bigint::");
      SetAnotherUQGDropDown(ampSvcClient);
      SetAnotherUQGLogicDropDown();

      // Set the drop down list hover text
      setTableDropDownHoverText();
      setFieldDropDownHoverText();
      setAnotherUQGDropDownHoverText();
      setAnotherUQGLogicDropDownHoverText();

      editDescriptionDiv.Attributes.Add("style", "display: block;");
      viewDescriptionDiv.Attributes.Add("style", "display: none;");
      editUsageQualificationFilterDiv.Attributes.Add("style", "display: block;");
      viewUsageQualificationFilterDiv.Attributes.Add("style", "display: none;");
    }
    if (AmpUsageQualificationAction == "View")
    {
      string usageQualificationName = String.IsNullOrEmpty(Request["UsageQualificationName"])
                                        ? ""
                                        : Request["UsageQualificationName"];
      setViewDefaultActionSettings(ampSvcClient, usageQualificationName);
    }
  }

  private void SetAnotherUQGLogicDropDown()
  {
    string text = GetLocalResourceObject("LOGIC_MEETS_THIS_QUALIFICATION").ToString();
    AnotherUQGLogicDropDown.Items.Add(new ListItem { Text = text, Value = "LOGIC_MEETS_THIS_QUALIFICATION" });
    text = GetLocalResourceObject("LOGIC_DOES_NOT_MEET_THIS_QUALIFICATION").ToString();
    AnotherUQGLogicDropDown.Items.Add(new ListItem { Text = text, Value = "LOGIC_DOES_NOT_MEET_THIS_QUALIFICATION" });
  }

  private void SetAnotherUQGDropDown(AmpServiceClient ampSvcClient)
  {
    if (ampSvcClient == null)
      return;

    try
    {
      var uqgs = new MTList<UsageQualificationGroup>();
      ampSvcClient.GetUsageQualificationGroups(ref uqgs);
      if (uqgs.Items.Count > 0)
      {
        foreach (var uqg in uqgs.Items)
        {
          string name = uqg.Name;
          string value = name;
          AnotherUQGDropDown.Items.Add(new ListItem {Text = name, Value = value});
        }
      }
    }
    catch (Exception ex)
    {
      var errorMessage = GetLocalResourceObject("TEXT_ERROR_RETRIEVE_UQGS").ToString();
      SetError(errorMessage);
      logger.LogException("An error occurred while retrieving the list of usage qualification group names.", ex);
      throw (ex);
    }
  }

  private void setViewDefaultActionSettings(AmpServiceClient ampSvcClient, string name)
  {
    if (ampSvcClient == null)
      return;

    UsageFieldPanelDiv.Visible = false;
    editDescriptionDiv.Attributes.Add("style", "display: none;");
    viewDescriptionDiv.Attributes.Add("style", "display: block;");
    editUsageQualificationFilterDiv.Attributes.Add("style", "display: none;");
    viewUsageQualificationFilterDiv.Attributes.Add("style", "display: block;");

    // Get the Description and Filter for the current Usage Qualification
    try
    {
      UsageQualificationGroup usageQualificationGroup;
      ampSvcClient.GetUsageQualificationGroup(name, out usageQualificationGroup);

      // Set the text for the controls
      if (usageQualificationGroup != null)
      {
        UsageQualificationName.Text = usageQualificationGroup.Name;
        UsageQualificationDescription.Text = usageQualificationGroup.Description;
        ViewDescriptionText.Text = usageQualificationGroup.Description;

        if (usageQualificationGroup.UsageQualificationFilters != null && usageQualificationGroup.UsageQualificationFilters.Count > 0)
        {
          // Loop through the UsageQualificationFilters in the case that we are viewing a Usage Qualification with
          // multiple filters that may have been created outside of the Amp UI
          foreach (UsageQualificationFilter filter in usageQualificationGroup.UsageQualificationFilters)
          {
            UsageQualificationFilter.Text += filter.Filter;
            UsageQualificationFilter.Text += "\n";
            ViewUsageQualificationFilterText.Text += filter.Filter;
            ViewUsageQualificationFilterText.Text += "\n";
          }
        }
      }
    }
    catch (Exception ex)
    {
      var errorMessage = String.Format(GetLocalResourceObject("TEXT_ERROR_RETRIEVE_USAGE_QUALIFICATION_FILTER").ToString() + "{0}", name);
      SetError(errorMessage);
      logger.LogException("An error occurred while retrieving the filter for usage qualification: " + name, ex);
      throw (ex);
    }

    // Set the controls to ReadOnly = true
    UsageQualificationName.ReadOnly = true;
    UsageQualificationDescription.ReadOnly = true;
    UsageQualificationFilter.ReadOnly = true;
  }

  private void RetrieveUsageQualificationAction()
  {
    AmpUsageQualificationAction = String.IsNullOrEmpty(Request["UsgAction"]) ? "" : Request["UsgAction"];

    if (String.IsNullOrEmpty(AmpUsageQualificationAction))
    {
      var errorMessage = GetLocalResourceObject("TEXT_ERROR_RETRIEVE_USAGE_QUALIFICATION_ACTION").ToString();
      SetError(errorMessage);
      logger.LogException(errorMessage, new Exception(errorMessage));
    }
  }

  private void setNavButtons()
  {
    // If we are only Viewing a decision, show the "Continue" button.
    if (AmpUsageQualificationAction == "View")
    {
      btnContinue.Visible = true;
      btnSaveAndContinue.Visible = false;
    }
    else // If we are editing a decision, show the "Save & Continue" button
    {
      btnContinue.Visible = false;
      btnSaveAndContinue.Visible = true;
    }
  }

  private void setLogicDropDown()
  {
    ListItem item0 = new ListItem();
    item0.Text = item0.Value = "";
    LogicDropDown.Items.Add(item0);
    ListItem item1 = new ListItem();
    item1.Text = item1.Value = "==";
    item1.Selected = true;
    LogicDropDown.Items.Add(item1);
    ListItem item2 = new ListItem();
    item2.Text = item2.Value = "!=";
    LogicDropDown.Items.Add(item2);
  }

  private void setTableDropDown(AmpServiceClient ampSvcClient)
  {
    if (prodViewNames == null)
    {
      if (ampSvcClient == null)
        return;

      try
      {
        prodViewNames = new MTList<ProductViewNameInstance>();
        ampSvcClient.GetProductViewNamesWithLocalizedNames(ref prodViewNames);
          if (TableDropDown.Items.Count > 0) return;
        TableDropDown.Items.Add(new ListItem {Text = "t_acc_usage", Value = "t_acc_usage"});
        if (prodViewNames.Items.Count > 0)
        {
          foreach (var productViewName in prodViewNames.Items)
          {
            string name = "";
            if (productViewName.LocalizedDisplayNames.ContainsKey(GetLanguageCode()))
            {
              name = productViewName.TableName + " (" + productViewName.LocalizedDisplayNames[GetLanguageCode()] + ")";
            }
            else
            {
              name = productViewName.TableName + " " + productViewName.DisplayName;
            }
            string value = productViewName.TableName;
            TableDropDown.Items.Add(new ListItem {Text = name, Value = value});
          }
        }
      }
      catch (Exception ex)
      {
        var errorMessage = GetLocalResourceObject("TEXT_ERROR_RETRIEVE_PRODUCT_VIEWS").ToString();
        SetError(errorMessage);
        logger.LogException("An error occurred while retrieving the list of product view table names.", ex);
        throw (ex);
      }
    }
  }

  private void setValueControls(string fieldName)
  {
    char[] delimiterChars = { ':' };
    string[] words = fieldName.Split(delimiterChars);
    if (words.Length == 1) return;
    string name = words[0];
    string type = words[1];
    string nm_space = words[2];
    string nm_enum = words[3];

    StringValue.Visible = false;
    NumberValue.Visible = false;
    EnumDropDownValue.Visible = false;
    DateValue.Visible = false;

    switch (type.ToLower())
    {
      case "int":
      case "bigint":
      case "int32":
        NumberValue.Visible = true;
        NumberValue.AllowDecimals = false;
        NumberValue.AllowNegative = true;
        NumberValue.AllowBlank = true;
        NumberValue.Text = "";
        break;
      case "double precision":
      case "numeric(22,10)":
      case "decimal":
        NumberValue.Visible = true;
        NumberValue.AllowDecimals = true;
        NumberValue.AllowNegative = true;
        NumberValue.AllowBlank = true;
        NumberValue.DecimalPrecision = "10";
        NumberValue.DecimalSeparator = GetGlobalResourceObject("JSConsts", "DECIMAL_SEPARATOR").ToString();
        NumberValue.Text = "";
        break;
      case "datetime":
        DateValue.Visible = true;
        break;
      case "enum":
        EnumDropDownValue.Items.Clear();
        EnumDropDownValue.Visible = true;
        var enumType = MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(nm_space, nm_enum, Path.GetDirectoryName(new Uri(this.GetType().Assembly.CodeBase).AbsolutePath));
        if (enumType != null)
        {
          List<MetraTech.DomainModel.BaseTypes.EnumData> enums = BaseObject.GetEnumData(enumType);

          foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enums)
          {
            string value = "#" + nm_space + @"/" + nm_enum + @"/" + enumData.EnumInstance.ToString() + "#";
            ListItem itm = new ListItem(enumData.DisplayName /*localized*/, value);
            EnumDropDownValue.Items.Add(itm);
          }
        }
        EnumDropDownValue.SelectedIndex = -1;
        setEnumDropDownValueHoverText();
        break;
      case "idviewdropdown":
        EnumDropDownValue.Items.Clear();
        EnumDropDownValue.Visible = true;
        // Get the list of valid id_views to show here
        if (prodViewNames != null)
        {
          foreach(var pv in prodViewNames.Items)
          {
            string value = pv.ID.ToString();
            string myName = "";
            if (pv.LocalizedDisplayNames.ContainsKey(GetLanguageCode()))
            {
              myName = pv.TableName + " (" + pv.LocalizedDisplayNames[GetLanguageCode()] + ")";
            }
            else
            {
              myName = pv.TableName + " " + pv.DisplayName;
            }
            ListItem itm = new ListItem(myName, value);
            EnumDropDownValue.Items.Add(itm);
          }
          setEnumDropDownValueHoverText();
        }
        break;
      case "char":
      case "varchar":
      case "string":
      case "timestamp":
      default:
        StringValue.Visible = true;
        StringValue.Text = "";
        break;
    }
  }

  private void setFieldDropDown(AmpServiceClient ampSvcClient, string tableName)
  {
    if (ampSvcClient == null)
      return;

    if (tableName == null)
      return;
    
    var tableColumnNames = new MTList<ProductViewPropertyInstance>();

    FieldDropDown.Items.Clear();

    /*special handling for t_acc_usage table, just hard code all the fields in the drop down for now*/
    if (tableName == "t_acc_usage")
    {
      FieldDropDown.Items.Add(new ListItem { Text = "id_sess", Value = "id_sess:bigint::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_acc", Value = "id_acc:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_payee", Value = "id_payee:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_view", Value = "id_view:idviewDropDown::", Selected = true });
      FieldDropDown.Items.Add(new ListItem { Text = "id_usage_interval", Value = "id_usage_interval:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_parent_sess", Value = "id_parent_sess:bigint::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_prod", Value = "id_prod:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_svc", Value = "id_svc:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "dt_session", Value = "dt_session:datetime::" });
      FieldDropDown.Items.Add(new ListItem { Text = "amount", Value = "amount:numeric(22,10)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "am_currency", Value = "am_currency:nvarchar(3)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "dt_crt", Value = "dt_crt:datetime::" });
      FieldDropDown.Items.Add(new ListItem { Text = "tax_federal", Value = "tax_federal:numeric(22,10)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "tax_state", Value = "tax_state:numeric(22,10)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "tax_county", Value = "tax_county:numeric(22,10)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "tax_local", Value = "tax_local:numeric(22,10)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "tax_other", Value = "tax_other:numeric(22,10)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_pi_instance", Value = "id_pi_instance:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_pi_template", Value = "id_pi_template:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "id_se", Value = "id_se:int::" });
      FieldDropDown.Items.Add(new ListItem { Text = "div_currency", Value = "div_currency:nvarchar(3)::" });
      FieldDropDown.Items.Add(new ListItem { Text = "div_amount", Value = "div_amount:numeric(22,10)::" });
    }
    else
    {
      try
      {
        ampSvcClient.GetProductViewColumnNamesWithTypes(tableName, ref tableColumnNames);

        if (tableColumnNames.Items.Count > 0)
        {
          foreach (var column in tableColumnNames.Items)
          {
            string text = "";
            if (column.LocalizedDisplayNames.ContainsKey(GetLanguageCode()))
            {
              text = column.ColumnName + " (" + column.LocalizedDisplayNames[GetLanguageCode()] + ")";
            }
            else
            {
              text = column.ColumnName;
            }

            string value = column.ColumnName + ":" + column.DataType + ":" + column.NmSpace + ":" + column.NmEnum;
            FieldDropDown.Items.Add(new ListItem { Text = text, Value = value });
          }
        }
      }
      catch (Exception ex)
      {
        SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_RETRIEVE_TABLE_COLUMN_NAMES, tableName));
        logger.LogException(String.Format("An error occurred while retrieving column names for database table '{0}'", tableName), ex);
        throw (ex);
      }
    }
  }
  #endregion

  protected void setTableDropDownHoverText()
  {
    foreach (ListItem _listItem in TableDropDown.Items)
    {
      _listItem.Attributes.Add("title", _listItem.Text);
    }
  }

  protected void setFieldDropDownHoverText()
  {
    foreach (ListItem _listItem in FieldDropDown.Items)
    {
      _listItem.Attributes.Add("title", _listItem.Text);
    }
  }

  protected void setAnotherUQGDropDownHoverText()
  {
    foreach (ListItem _listItem in AnotherUQGDropDown.Items)
    {
      _listItem.Attributes.Add("title", _listItem.Text);
    }
  }

  protected void setAnotherUQGLogicDropDownHoverText()
  {
    foreach (ListItem _listItem in AnotherUQGLogicDropDown.Items)
    {
      _listItem.Attributes.Add("title", _listItem.Text);
    }
  }

  protected void setEnumDropDownValueHoverText()
  {
    foreach (ListItem _listItem in EnumDropDownValue.Items)
    {
      _listItem.Attributes.Add("title", _listItem.Text);
    }
  }

  protected void TableDropDown_SelectedIndexChanged(object sender, EventArgs e)
  {
    AmpServiceClient ampSvcClient = null;
    try
    {
      FieldDropDown.SelectedIndex = -1;
      ampSvcClient = new AmpServiceClient();
      if (ampSvcClient.ClientCredentials != null)
      {
        ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }
      setFieldDropDown(ampSvcClient, TableDropDown.SelectedItem.Value);
      setValueControls(FieldDropDown.SelectedItem.Value);

      // Set the drop down list hover text
      setTableDropDownHoverText();
      setFieldDropDownHoverText();
      setAnotherUQGDropDownHoverText();
      setAnotherUQGLogicDropDownHoverText();

      // Clean up client.
      ampSvcClient.Close();
      ampSvcClient = null;
    }
    catch (Exception ex)
    {
      var errorMessage = GetLocalResourceObject("TEXT_ERROR_RETRIEVE_UQGS").ToString();
      SetError(errorMessage);
      logger.LogException("An error occurred while retrieving data for the page.", ex);
    }
    finally
    {
     if (ampSvcClient != null)
     {
       ampSvcClient.Abort();
     }
    }
  }

  protected void FieldDropDown_SelectedIndexChanged(object sender, EventArgs e)
  {
    setValueControls(FieldDropDown.SelectedValue);
  }

  protected void btnInsertFilterTextButton_Click(object sender, EventArgs e)
  {
    int index = Convert.ToInt16(UsageQualificationFilterCursorLocation.Value);

    char[] delimiterChars = { ':' };
    string[] words = FieldDropDown.SelectedItem.Value.Split(delimiterChars);
    string field = words[0];
    string type = words[1];
    string value = "";

    switch (type.ToLower())
    {
      case "int":
      case "bigint":
      case "int32":
        value = NumberValue.Text;
        break;
      case "double precision":
      case "numeric(22,10)":
      case "decimal":
        value = NumberValue.Text;
        break;
      case "datetime":
        value = DateValue.Text;
        break;
      case "enum":
      case "idviewdropdown":
        value = EnumDropDownValue.SelectedItem.Value;
        break;
      case "char":
      case "varchar":
      case "string":
      case "timestamp":
      default:
        value = StringValue.Text;
        break;
    }


    string filter = "";
    filter += "OBJECT." + field + " " + LogicDropDown.SelectedItem.Text + " " + value;
    string newValue = UsageQualificationFilter.Text.Insert(index, filter);
    // Remove double spaces to help reduce accidental sql injection detection by MetraTech.SecurityFramework
    newValue = newValue.Replace("  ", " ");
    UsageQualificationFilter.Text = newValue;
  }

  protected void btnInsertAnotherUsageQualificationTextButton_Click(object sender, EventArgs e)
  {
    int index = Convert.ToInt16(UsageQualificationFilterCursorLocation.Value);

    string logic = "";
    switch(AnotherUQGLogicDropDown.SelectedValue.ToString())
    {
      case "LOGIC_DOES_NOT_MEET_THIS_QUALIFICATION":
        logic = "!";
        break;
    }

    string anotherUQG = "";
    anotherUQG += logic + "GROUP." + AnotherUQGDropDown.SelectedValue.ToString();
    string newValue = UsageQualificationFilter.Text.Insert(index, anotherUQG);
    // Remove double spaces to help reduce accidental sql injection detection by MetraTech.SecurityFramework
    newValue = newValue.Replace("  ", " ");
    UsageQualificationFilter.Text = newValue;
  }

  protected bool validateUsageQualificationName(string name)
  {
    if (String.IsNullOrEmpty(name))
      return false;

    Regex regex = new Regex("^[a-zA-Z0-9_]*$");
    if (!regex.IsMatch(name))
    {
      return false;
    }

    return true;
  }

  protected void btnContinue_Click(object sender, EventArgs e)
  {
    if (AmpUsageQualificationAction != "View")
    {
      string name = UsageQualificationName.Text;
      if (!validateUsageQualificationName(name))
      {
        var errorMessage = String.Format(GetGlobalResourceObject("JSConsts", "TEXT_AMPWIZARD_INVALID_UQG_NAME").ToString(), name);
        SetError(errorMessage);
        return;
      }
      AmpServiceClient ampSvcStoreUsageQualificationClient = null;
      try
      {
        ampSvcStoreUsageQualificationClient = new AmpServiceClient();
        if (ampSvcStoreUsageQualificationClient.ClientCredentials != null)
        {
          ampSvcStoreUsageQualificationClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcStoreUsageQualificationClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        if (AmpUsageQualificationAction == "Create")
        {
          // For "Create", create the new usage qualification.
          UsageQualificationGroup usageQualificationGroup;
          string description = UsageQualificationDescription.Text;
          ampSvcStoreUsageQualificationClient.CreateUsageQualificationGroup(name, description,
                                                                            out usageQualificationGroup);

          // Next, save the filter for this new usage qualification
          UsageQualificationFilter filter = new UsageQualificationFilter();
          filter.Filter = UsageQualificationFilter.Text;
          usageQualificationGroup.UsageQualificationFilters.Add(filter);
          ampSvcStoreUsageQualificationClient.SaveUsageQualificationGroup(usageQualificationGroup);
          // TODO: What if the SaveUsageQualificationGroup fails after the CreateUsageQualificationGroup succeeded? How do we rollback?

          var message = String.Format(GetLocalResourceObject("TEXT_SUCCESS_CREATE_USAGE_QUALIFICATION").ToString(), name);
          logger.LogInfo(message);

          logger.LogDebug(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(),
                                        AmpDecisionName));
        }

        // Clean up client.
        ampSvcStoreUsageQualificationClient.Close();
        ampSvcStoreUsageQualificationClient = null;

        // Advance to next page in wizard.  Set EndResponse parameter to false
        // to prevent Response.Redirect from throwing ThreadAbortException.
        Response.Redirect(AmpNextPage, false);
      }
      catch (System.ServiceModel.FaultException ex1)
      {
        var errorMessage = String.Format(
          GetLocalResourceObject("TEXT_ERROR_MUST_USE_UNIQUE_NAME_FOR_NEW_UQ").ToString(), name);
        SetError(errorMessage);
        logger.LogException(errorMessage, ex1);

        // Stay on current page.
      }
      catch (Exception ex)
      {
        var errorMessage = String.Format(GetLocalResourceObject("TEXT_ERROR_ADD_USAGE_QUALIFICATION").ToString(), name);
        SetError(errorMessage);
        logger.LogException(errorMessage, ex);

        // Stay on current page.
      }
      finally
      {
        if (ampSvcStoreUsageQualificationClient != null)
        {
          ampSvcStoreUsageQualificationClient.Abort();
        }
      }
    } else
    {
      // Advance to next page in wizard.  Set EndResponse parameter to false
      // to prevent Response.Redirect from throwing ThreadAbortException.
      Response.Redirect(AmpNextPage, false);
    }
  } // btnContinue_Click

}