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
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.DomainModel.ProductCatalog;


public partial class AmpChargeCreditDirectivePage : AmpWizardBasePage
{
  private string _directiveAction = String.Empty;
  private string _directiveID = String.Empty;


  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    if (!String.IsNullOrEmpty(Request["DirectiveAction"]))
    {
      _directiveAction = Request["DirectiveAction"];
    }
    if (!String.IsNullOrEmpty(Request["DirectiveID"]))
    {
      _directiveID = Request["DirectiveID"];
    }

    if (!IsPostBack)
    {
      // Set the current, next, and previous AMP pages right away.
      AmpCurrentPage = "ChargeCreditDirective.aspx";
      AmpNextPage = "ChargeCreditDirectives.aspx";
      AmpPreviousPage = "ChargeCreditDirectives.aspx";

      DirectiveMonitorChanges();

      CurrentGeneratedChargeInstance = GetGeneratedChargeWithClient();

      ChargeCreditDirectivePageSettings();
    }

  }
  protected void btnContinue_Click(object sender, EventArgs e)
  {
    if (_directiveAction != "View")
    {
      CurrentGeneratedChargeInstance.GeneratedChargeDirectives.Add(SetDomainModelObjectFromControls());
      if (!SaveGeneratedChargeWithClient())
      {
        return;
      }
    }
    Response.Redirect(AmpNextPage, false);

  }

  private void ChargeCreditDirectivePageSettings()
  {
    btnSaveAndContinue.Text = ((_directiveAction != "View")
                                ? Resources.Resource.TEXT_SAVE_AND_CONTINUE
                                : Resources.Resource.TEXT_CONTINUE);

    if (!String.IsNullOrEmpty(AmpChargeCreditName) && !String.IsNullOrEmpty(CurrentGeneratedChargeInstance.ProductViewName))
    {
      tbChargeCreditName.Text = AmpChargeCreditName;
      tbProductView.Text = CurrentGeneratedChargeInstance.ProductViewName;
    }

    SetControlsFromDatabase();
    if (_directiveAction == "View")
    {
      SetViewMode();
    }
  }

  private void SetViewMode()
  {
    btnSaveAndContinue.CausesValidation = false;
    btnSaveAndContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
    RBL_DirectiveType.Enabled = false;
    tbFilter.ReadOnly = true;
    tbIncludeTableName.ReadOnly = true;
    tbSourceValue.ReadOnly = true;
    tbTargetField.ReadOnly = true;
    tbIncludePredicate.ReadOnly = true;
    tbIncludedFieldPrefix.ReadOnly = true;
    tbFieldName.ReadOnly = true;
    tbPopulationString.ReadOnly = true;
    tbDefaultValue.ReadOnly = true;
    tbMvmProcedure.ReadOnly = true;
  }

  private void SetControlsFromDatabase()
  {
    GeneratedChargeDirective _generatedChargeDirective = GetChargeDirective();

    if (_generatedChargeDirective != null)
    {
      tbFilter.Text = _generatedChargeDirective.Filter ?? String.Empty;

      if (IsTableInclusionType(_generatedChargeDirective))
      {
        tbIncludeTableName.Text = _generatedChargeDirective.IncludeTableName ?? String.Empty;
        tbSourceValue.Text = _generatedChargeDirective.SourceValue ?? String.Empty;
        tbTargetField.Text = _generatedChargeDirective.TargetField ?? String.Empty;
        tbIncludePredicate.Text = _generatedChargeDirective.IncludePredicate ?? String.Empty;
        tbIncludedFieldPrefix.Text = _generatedChargeDirective.IncludedFieldPrefix ?? String.Empty;

        RBL_DirectiveType.Items[0].Selected = true;
      }

      else if (IsFieldPopulationType(_generatedChargeDirective))
      {
        tbFieldName.Text = _generatedChargeDirective.FieldName ?? String.Empty;
        tbPopulationString.Text = _generatedChargeDirective.PopulationString ?? String.Empty;
        tbDefaultValue.Text = _generatedChargeDirective.DefaultValue ?? String.Empty;

        RBL_DirectiveType.Items[1].Selected = true;

      }

      else 
      {
        tbMvmProcedure.Text = _generatedChargeDirective.MvmProcedure ?? String.Empty;
        RBL_DirectiveType.Items[2].Selected = true;
      }
    }

    else
    {
      //For create directive
      //Set Selected true to "Table Inclusion" directive type
      RBL_DirectiveType.Items[0].Selected = true;
    }
  }


  // Finds and returns the directive identified by _directiveID in the list of directives for the CurrentGeneratedChargeInstance.
  // Returns null if that directive does not exist.
  private GeneratedChargeDirective GetChargeDirective()
  {
    return CurrentGeneratedChargeInstance.GeneratedChargeDirectives.Find(directive => Convert.ToString(directive.UniqueId) == _directiveID);
  }

  // set properties for directive
  private GeneratedChargeDirective SetDomainModelObjectFromControls()
  {
    GeneratedChargeDirective _generatedChargeDirective = GetChargeDirective();
    if (_generatedChargeDirective != null)
    {
      // Clear all properties, but don't change Priority.
      ClearDirectiveProperties(_generatedChargeDirective);
    }
    else
    {
      _generatedChargeDirective = new GeneratedChargeDirective();

      // Set the new directive's priority to 0
      // so that it will be first in the order of execution.
      // (The Insert trigger will automatically increment the priority
      // of ALL of the directives for this generated charge.)
      _generatedChargeDirective.Priority = 0;
    }

    if (!String.IsNullOrEmpty(tbFilter.Text))
    {
      _generatedChargeDirective.Filter = tbFilter.Text;
    }
    switch(RBL_DirectiveType.SelectedValue)
    {
      case "Table Inclusion":

        if (!String.IsNullOrEmpty(tbIncludeTableName.Text))
        {
          _generatedChargeDirective.IncludeTableName = tbIncludeTableName.Text;
        }
        if (!String.IsNullOrEmpty(tbSourceValue.Text))
        {
          _generatedChargeDirective.SourceValue = tbSourceValue.Text;
        }
        if (!String.IsNullOrEmpty(tbTargetField.Text))
        {
          _generatedChargeDirective.TargetField = tbTargetField.Text;
        }
        if (!String.IsNullOrEmpty(tbIncludePredicate.Text))
        {
          _generatedChargeDirective.IncludePredicate = tbIncludePredicate.Text;
        }
        if (!String.IsNullOrEmpty(tbIncludedFieldPrefix.Text))
        {
          _generatedChargeDirective.IncludedFieldPrefix = tbIncludedFieldPrefix.Text;
        }
        break;
      case "Field Population":
        if (!String.IsNullOrEmpty(tbFieldName.Text))
        {
          _generatedChargeDirective.FieldName = tbFieldName.Text;
        }
        if (!String.IsNullOrEmpty(tbPopulationString.Text))
        {
          _generatedChargeDirective.PopulationString = tbPopulationString.Text;
        }
        if (!String.IsNullOrEmpty(tbDefaultValue.Text))
        {
          _generatedChargeDirective.DefaultValue = tbDefaultValue.Text;
        }

        break;
      case "Procedure Execution":
        if (!String.IsNullOrEmpty(tbMvmProcedure.Text))
        {
          _generatedChargeDirective.MvmProcedure = tbMvmProcedure.Text;
        }
        break;
    }
    return _generatedChargeDirective;
  }


  private bool IsTableInclusionType(GeneratedChargeDirective directive)
  {
    return (directive.IncludeTableName != null ||
            directive.SourceValue != null ||
            directive.TargetField != null ||
            directive.IncludePredicate != null ||
            directive.IncludedFieldPrefix != null);
  }

  private bool IsFieldPopulationType(GeneratedChargeDirective directive)
  {
    return (directive.FieldName != null ||
            directive.PopulationString != null ||
            directive.DefaultValue != null);
  }

  /// <summary>
  /// Clears all of the directive's properties EXCEPT FOR PRIORITY.
  /// </summary>
  /// <param name="_directive"></param>
  private void ClearDirectiveProperties(GeneratedChargeDirective _directive)
  {
    _directive.Filter = null;
    _directive.IncludeTableName = null;
    _directive.SourceValue = null;
    _directive.TargetField = null;
    _directive.IncludePredicate = null;
    _directive.IncludedFieldPrefix = null;
    _directive.FieldName = null;
    _directive.PopulationString = null;
    _directive.DefaultValue = null;
    _directive.MvmProcedure = null;
  }

  private void DirectiveMonitorChanges()
  {
    MonitorChangesInControl(tbDefaultValue);
    MonitorChangesInControl(tbFieldName);
    MonitorChangesInControl(tbFilter);
    MonitorChangesInControl(tbIncludePredicate);
    MonitorChangesInControl(tbIncludeTableName);
    MonitorChangesInControl(tbIncludedFieldPrefix);
    MonitorChangesInControl(tbMvmProcedure); 
    MonitorChangesInControl(tbPopulationString);
    MonitorChangesInControl(tbSourceValue);
    MonitorChangesInControl(tbTargetField);
    MonitorChangesInControl(RBL_DirectiveType);
  }
}