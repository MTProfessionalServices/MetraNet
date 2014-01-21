<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master"
  AutoEventWireup="true" CodeFile="ChargeCreditDirective.aspx.cs" Inherits="AmpChargeCreditDirectivePage" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <div class="CaptionBar">
    <asp:Label ID="lblTitleChargeCreditDirective" runat="server" Text="Charge/Credit: Directive" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
  <table>
    <tr>
      <td>
        <div style="padding-top: 20px">
          <MT:MTTextBoxControl ID="tbChargeCreditName" runat="server" AllowBlank="False" LabelSeparator="Charge/Credit"
            TabIndex="200" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbChargeCreditName" Listeners="{}" ReadOnly="True" 
            XType="TextField" XTypeNameSpace="form" />
          <MT:MTTextBoxControl ID="tbProductView" runat="server" AllowBlank="False" Label="Product View"
            TabIndex="210" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbProductView" Listeners="{}" ReadOnly="True" 
            XType="TextField" XTypeNameSpace="form" />
        </div>
      </td>
      <td style="padding-left: 20px">
        <span>
          <img id="imgChargeCreditDirective" src='/Res/Images/icons/cog_error_32x32.png' runat="server"
            title="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" />
        </span>
      </td>
    </tr>
  </table>
  <div style="padding-left: 70px; padding-top: 15px">
    <asp:Label ID="lblDirectiveType" runat="server" Font-Bold="False" ForeColor="DarkBlue"
      Font-Size="9pt" meta:resourcekey="lblDirectiveType" Text="What type of work will this directive do?"></asp:Label>
    <br />
    <div style="padding-top: 5px">
      <span style="color:blue; text-decoration:underline; cursor:pointer;"
        onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_MORE_CHARGE_CREDIT_DIRECTIVE, 450, 160)"
        id="DecisionCycleMoreLink">
        <asp:Literal ID="MoreInfoLiteral" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" Visible="True" />
      </span>
    </div>
  </div>
  <div style="padding-top: 10px; padding-left: 150px">
    <asp:RadioButtonList runat="server" ID="RBL_DirectiveType" TabIndex="220" CellSpacing="0" onClick="DisplayControlsForDirectiveType();">
      <asp:ListItem Value="Table Inclusion" meta:resourcekey="rblTableInclusion"></asp:ListItem>
      <asp:ListItem Value="Field Population" meta:resourcekey="rblFieldPopulation"></asp:ListItem>
      <asp:ListItem Value="Procedure Execution" meta:resourcekey="rblProcedureExecution"></asp:ListItem>
    </asp:RadioButtonList>
  </div>

  <div style="padding-top:15px;">
    <table>
      <tr>
        <td>
          <MT:MTTextBoxControl ID="tbFilter" runat="server" AllowBlank="False" Label="Condition for Execution"
            TabIndex="230" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbFilter" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
        </td>
        <td valign="top">
          <span style="color:blue;text-decoration:underline;cursor:pointer;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_FILTER, TEXT_AMPWIZARD_HELP_DIRECTIVE_FILTER, 450, 120)">
            <img id="ImgHelp1" src='/Res/Images/icons/help.png' />
          </span>
        </td>
      </tr>
    </table>
  </div>

  <div id="divTableInclusionControls" style="padding-top:10px">
    <table>
      <tr>
        <td>
          <MT:MTTextBoxControl ID="tbIncludeTableName" runat="server" AllowBlank="False" Label="Include Table Name"
            TabIndex="240" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbIncludeTableName" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
          <MT:MTTextBoxControl ID="tbSourceValue" runat="server" AllowBlank="False" Label="Source Value"
            TabIndex="250" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbSourceValue" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
          <MT:MTTextBoxControl ID="tbTargetField" runat="server" AllowBlank="False" Label="Target Field"
            TabIndex="260" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbTargetField" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
          <MT:MTTextBoxControl ID="tbIncludePredicate" runat="server" AllowBlank="True" Label="Include Predicate"
            TabIndex="270" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbIncludePredicate" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" Font-Bold="True" />
          <MT:MTTextBoxControl ID="tbIncludedFieldPrefix" runat="server" AllowBlank="True" 
            Label="Included Field Prefix" TabIndex="280" ControlWidth="200" ControlHeight="18"
            HideLabel="False" LabelWidth="150" meta:resourcekey="tbIncludedFieldPrefix" Listeners="{}"
            ReadOnly="False" XType="TextField" XTypeNameSpace="form" Font-Bold="True" />
        </td>
        <td valign="top">
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_INCLUDE_TABLE_NAME, TEXT_AMPWIZARD_HELP_DIRECTIVE_INCLUDE_TABLE_NAME, 450, 120)">
            <img id="ImgHelp2" src='/Res/Images/icons/help.png' />
          </span>
          <br style="line-height:4px" />
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_SOURCE_VALUE, TEXT_AMPWIZARD_HELP_DIRECTIVE_SOURCE_VALUE, 450, 120)">
            <img id="ImgHelp3" src='/Res/Images/icons/help.png' />
          </span>
          <br style="line-height:4px" />
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_TARGET_FIELD, TEXT_AMPWIZARD_HELP_DIRECTIVE_TARGET_FIELD, 450, 120)">
            <img id="ImgHelp4" src='/Res/Images/icons/help.png' />
          </span>
          <br style="line-height:4px" />
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_INCLUDE_PREDICATE, TEXT_AMPWIZARD_HELP_DIRECTIVE_INCLUDE_PREDICATE, 450, 120)">
            <img id="ImgHelp5" src='/Res/Images/icons/help.png' />
          </span>
          <br style="line-height:4px" />
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_INCLUDED_FIELD_PREFIX, TEXT_AMPWIZARD_HELP_DIRECTIVE_INCLUDED_FIELD_PREFIX, 450, 120)">
            <img id="ImgHelp6" src='/Res/Images/icons/help.png' />
          </span>
        </td>
      </tr>
    </table>
  </div>

  <div id="divFieldPopulationControls" style="padding-top: 10px">
    <table>
      <tr>
        <td>
          <MT:MTTextBoxControl ID="tbFieldName" runat="server" AllowBlank="False" Label="Field Name"
            TabIndex="290" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbFieldName" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
          <MT:MTTextBoxControl ID="tbPopulationString" runat="server" AllowBlank="False" Label="Population String"
            TabIndex="300" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbPopulationString" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
          <MT:MTTextBoxControl ID="tbDefaultValue" runat="server" AllowBlank="False" Label="Default Value"
            TabIndex="310" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbDefaultValue" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
        </td>
        <td valign="top">
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_FIELD_NAME, TEXT_AMPWIZARD_HELP_DIRECTIVE_FIELD_NAME, 450, 120)">
            <img id="ImgHelp7" src='/Res/Images/icons/help.png' />
          </span>
          <br style="line-height:4px" />
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_POPULATION_STRING, TEXT_AMPWIZARD_HELP_DIRECTIVE_POPULATION_STRING, 450, 120)">
            <img id="ImgHelp8" src='/Res/Images/icons/help.png' />
          </span>
          <br style="line-height:4px" />
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_DEFAULT_VALUE, TEXT_AMPWIZARD_HELP_DIRECTIVE_DEFAULT_VALUE, 450, 120)">
            <img id="ImgHelp9" src='/Res/Images/icons/help.png' />
          </span>
        </td>
      </tr>
    </table>
  </div>

  <div id="divProcedureExecutionControls" style="padding-top: 10px">
    <table>
      <tr>
        <td>
          <MT:MTTextBoxControl ID="tbMvmProcedure" runat="server" AllowBlank="False" Label="MVM Procedure"
            TabIndex="320" ControlWidth="200" ControlHeight="18" HideLabel="False" LabelWidth="150"
            meta:resourcekey="tbMvmProcedure" Listeners="{}" ReadOnly="False" XType="TextField"
            XTypeNameSpace="form" />
        </td>
        <td valign="top">
          <span style="color:blue;text-decoration:underline;cursor:pointer;display:none;" 
                onclick="displayInfoMultiple(TITLE_AMPWIZARD_HELP_DIRECTIVE_MVM_PROCEDURE, TEXT_AMPWIZARD_HELP_DIRECTIVE_MVM_PROCEDURE, 450, 120)">
            <img id="ImgHelp10" src='/Res/Images/icons/help.png' />
          </span>
        </td>
      </tr>
    </table>
  </div>

  <div style="padding-left: 0.85in; padding-top: 0.3in;">
    <table>
      <col style="width: 190px" />
      <col style="width: 190px" />
      <tr>
        <td align="left">
          <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
            OnClientClick="setLocationHref(ampPreviousPage); return false;" CausesValidation="false"
            TabIndex="330" />
        </td>
        <td align="right">
          <MT:MTButton ID="btnSaveAndContinue" runat="server" OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
            OnClick="btnContinue_Click" CausesValidation="true" TabIndex="340" />
        </td>
      </tr>
    </table>
  </div>


  <script type="text/javascript" language="javascript">


    // Display only those controls relevant to the selected directive type.
    // Disable the other controls so that they don't get validated.
    function DisplayControlsForDirectiveType()
    {
      var index = 0;
      var rblId = '<%= RBL_DirectiveType.ClientID %>';

      for (var j = 0; j < '<%= RBL_DirectiveType.Items.Count %>'; j++) {
        var item = document.getElementById(rblId + "_" + j.toString());
        if (item.checked) {
          index = j;
          break;
        }
      }

      var tbIncludeTableName = Ext.getCmp('<%=tbIncludeTableName.ClientID%>');
      var tbSourceValue = Ext.getCmp('<%=tbSourceValue.ClientID%>');
      var tbTargetField = Ext.getCmp('<%=tbTargetField.ClientID%>');
      var tbIncludePredicate = Ext.getCmp('<%=tbIncludePredicate.ClientID%>');
      var tbIncludeFieldPrefix = Ext.getCmp('<%=tbIncludedFieldPrefix.ClientID%>');
      var tbFieldName = Ext.getCmp('<%=tbFieldName.ClientID%>');
      var tbPopulatingString = Ext.getCmp('<%=tbPopulationString.ClientID%>');
      var tbDefaultValue = Ext.getCmp('<%=tbDefaultValue.ClientID%>');
      var tbMvmProcedure = Ext.getCmp('<%=tbMvmProcedure.ClientID%>');

      if (index == 0) //  Table Inclusion
      {
        tbIncludeTableName.enable();
        tbSourceValue.enable();
        tbTargetField.enable();
        tbIncludePredicate.enable();
        tbIncludeFieldPrefix.enable();
        document.getElementById('divTableInclusionControls').style.display = 'block';

        tbFieldName.disable();
        tbPopulatingString.disable();
        tbDefaultValue.disable();
        document.getElementById('divFieldPopulationControls').style.display = 'none';

        tbMvmProcedure.disable();
        document.getElementById('divProcedureExecutionControls').style.display = 'none';
      }

      else if (index == 1)  // Field Population
      {
        tbIncludeTableName.disable();
        tbSourceValue.disable();
        tbTargetField.disable();
        tbIncludePredicate.disable();
        tbIncludeFieldPrefix.disable();
        document.getElementById('divTableInclusionControls').style.display = 'none';

        tbFieldName.enable();
        tbPopulatingString.enable();
        tbDefaultValue.enable();
        document.getElementById('divFieldPopulationControls').style.display = 'block';

        tbMvmProcedure.disable();
        document.getElementById('divProcedureExecutionControls').style.display = 'none';
      }

      else  // Procedure Execution
      {
        tbIncludeTableName.disable();
        tbSourceValue.disable();
        tbTargetField.disable();
        tbIncludePredicate.disable();
        tbIncludeFieldPrefix.disable();
        document.getElementById('divTableInclusionControls').style.display = 'none';

        tbFieldName.disable();
        tbPopulatingString.disable();
        tbDefaultValue.disable();
        document.getElementById('divFieldPopulationControls').style.display = 'none';

        tbMvmProcedure.enable();
        document.getElementById('divProcedureExecutionControls').style.display = 'block';
      }
    }


    Ext.onReady(function () {
      DisplayControlsForDirectiveType();

      // Record the initial values of the page's controls.
      // (Note:  This is called here, and not on the master page,
      // because the call to document.getElementById() returns null
      // if executed on the master page.)
      MPC_assignInitialValues();
    });
  </script>
</asp:Content>
