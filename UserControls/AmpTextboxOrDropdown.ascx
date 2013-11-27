<%@ Control Language="C#" AutoEventWireup="true" CodeFile="AmpTextboxOrDropdown.ascx.cs" Inherits="UserControls_AmpTextboxOrDropdown"  %>
<%@ Register TagPrefix="MT" Namespace="MetraTech.UI.Controls" Assembly="MetraTech.UI.Controls" %>

<!-- ddSourceType is a dropdown that lets the user choose whether to use a textbox (index 0 in ddSourceType)
     or a dropdown (index 1 in ddSourceType) to specify the control's value.
     Displayed to the right of ddSourceType is either tbNumericSource, tbTextSource, or ddSource,
     depending on what the user selected in ddSourceType and other properties of the user control. -->

<table style="padding-left:0px; padding-top:0px;" valign="top">
  <tr>
    <td>
      <MT:MTDropDown ID="ddSourceType" runat="server" ControlWidth="165"
          HideLabel="True" AllowBlank="False" Editable="True" TabIndex="20"
       />
       <!-- NOTE: We are listening for 'select' instead of 'change' because the 'change'
         -- event doesn't get triggered! -->
    </td>
    <td>
      <div id="divNumericSource" runat="server" style="display:'none'" >
        <MT:MTNumberField ID="tbNumericSource" runat="server" ControlWidth="80"
          AllowDecimals="True" AllowNegative="True" 
          HideLabel="True" AllowBlank="True" TabIndex="40"
          XType="LargeNumberField" XTypeNameSpace="ux.form"
         />
      </div>
      <div id="divTextSource" runat="server" style="display:'none'" >
        <MT:MTTextBoxControl ID="tbTextSource" runat="server" ControlWidth="160"
          HideLabel="True" AllowBlank="True" TabIndex="50"
         />
      </div>
      <div id="divDropdownSource" runat="server" style="display:'none'" >
        <MT:MTDropDown ID="ddSource" runat="server" ControlWidth="160" ListWidth="200"
          HideLabel="True" AllowBlank="True" Editable="True" TabIndex="60"
         />
      </div>
    </td>
  </tr>
</table>


<script type="text/javascript" language="javascript">

  ChangeControlStateAction_<%=this.ClientID%> = function(bEnabled)
  {
    var ddtype = Ext.getCmp('<%=ddSourceType.ClientID %>');
    var tbnum = Ext.getCmp('<%=tbNumericSource.ClientID %>');
    var tbtxt = Ext.getCmp('<%=tbTextSource.ClientID %>');
    var ddsrc = Ext.getCmp('<%=ddSource.ClientID %>');

    if (ddtype != null)
    {
      if (bEnabled)
      {
        ddtype.enable();
      }
      else
      {
        ddtype.disable();
        //ddtype.selectedIndex = -1;
        //ddtype.setValue(null);
      }
    }
    if (tbnum != null)
    {
      if (bEnabled)
      {
        tbnum.enable();
      }
      else
      {
        tbnum.disable();
        //tbnum.setValue('');
      }
    }
    if (tbtxt != null)
    {
      if (bEnabled)
      {
        tbtxt.enable();
      }
      else
      {
        tbtxt.disable();
        //tbtxt.setValue('');
      }
    }
    if (ddsrc != null)
    {
      if (bEnabled)
      {
        ddsrc.enable();
      }
      else
      {
        ddsrc.disable();
        //ddsrc.selectedIndex = -1;
        //ddsrc.setValue(null);
      }
    }

  };
    
    
  //JCTBD Try to eliminate this (used by SelectDecisionAction.aspx).
  function DisabledControl_<%=this.ClientID%>() {
    var ddtype = Ext.getCmp('<%=ddSourceType.ClientID %>');
    var tbnum = Ext.getCmp('<%=tbNumericSource.ClientID %>');
    var tbtxt = Ext.getCmp('<%=tbTextSource.ClientID %>');
    var ddsrc = Ext.getCmp('<%=ddSource.ClientID %>');

    if (ddtype != null)
    {
      ddtype.disable();
      //ddtype.selectedIndex = -1;
      //ddtype.setValue(null);
    }
    if (tbnum != null)
    {
      tbnum.disable();
      tbnum.setValue('');
    }
    if (tbtxt != null)
    {
      tbtxt.disable();
      tbtxt.setValue('');
    }
    if (ddsrc != null)
    {
      ddsrc.disable();
      //ddsrc.selectedIndex = -1;
      //ddsrc.setValue(null);
    }
  }
  

</script>
