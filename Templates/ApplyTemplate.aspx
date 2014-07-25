<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Templates_ApplyTemplate" Title="MetraNet" meta:resourcekey="PageResource1" CodeFile="ApplyTemplate.aspx.cs" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <MT:MTTitle ID="MTTitle1" runat="server" Text="Apply Account Template" meta:resourcekey="MTTitle1Resource1"/>
  <br />
  <div style="width:810px">
  
    <MTCDT:MTGenericForm ID="MTGenericFormAccountTemplate" runat="server" meta:resourcekey="MTGenericFormAccountTemplateResource1"></MTCDT:MTGenericForm>

    <MT:MTPanel ID="MTPanel1" runat="server" Text="Subscription Span" meta:resourcekey="SubscriptionSpanPanel" >
    <div id="leftColumn" style="float: left; width: 300px;padding-left:10px;">
      <MT:MTCheckBoxControl ID="cbStartNextBillingPeriod" runat="server" BoxLabel="Next start of payer's billing period after this date" Text="c1" Value="c1" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbStartNextBillingPeriodResource1" Name="cbStartNextBillingPeriod" OptionalExtConfig="boxLabel:'Next start of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c1',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />
      <div style="height:20px">&nbsp;</div>
      <MT:MTCheckBoxControl ID="cbEndNextBillingPeriod" runat="server" BoxLabel="Next end of payer's billing period after this date" Text="c2" Value="c2" AllowBlank="False" Checked="False" HideLabel="True" Listeners="{}" meta:resourcekey="cbEndNextBillingPeriodResource1" Name="cbEndNextBillingPeriod" OptionalExtConfig="boxLabel:'Next end of payer\'s billing period after this date',&#13;&#10;                                            inputValue:'c2',&#13;&#10;                                            checked:false" ReadOnly="False" TabIndex="0" XType="Checkbox" LabelSeparator=":" XTypeNameSpace="form" />
      <div style="height:20px">&nbsp;</div>
    </div>
    </MT:MTPanel>    
    
  <!-- BUTTONS -->
 
  <div  class="x-panel-btns-ct">
    <div style="width:725px" class="x-panel-btns x-panel-btns-center">
     <center>   
      <table cellspacing="0">
        <tr>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnOK" OnClientClick="if (checkButtonClickCount() == true && ValidateForm() == true) {return onOK();} else {return false;}" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_OK %>" />   
          </td>
          <td  class="x-panel-btn-td">
            <MT:MTButton ID="btnCancel" OnClientClick="return checkButtonClickCount();" Width="50px" runat="server" Text="<%$ Resources:Resource,TEXT_CANCEL %>" CausesValidation="False" OnClick="btnCancel_Click" />
          </td>
        </tr>
      </table> 
       </center>    
    </div>
  </div>
 
    <br />  
  </div>

  <script type="text/javascript">
  
    
     // Custom Renderers
    NameRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      if(record.data.GroupSubName != null)
      {
        str += record.data.GroupSubName;
      }
      else
      {
        str += record.data.PODisplayName;
      }
      
      return str;
    }; 
    
    IsGroupRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      if(record.data.GroupID == "" || record.data.GroupID  == null)
      {
         return "--";
      }
      else
      {
        return "<img border='0' src='/Res/Images/Icons/tick.png'>";
      }
      return str;
    };
  
    function getDisplayName(record)
    {
      var name = "";
      if(record.data.GroupSubName != null)
      {
        name += record.data.GroupSubName;
      }
      else
      {
        name += record.data.PODisplayName;
      }
      return name;
    }

    // HANDLE OK CLICK
    function onOK()
    {
      var subRecords = "";
      var subIds = "";
      var propertyIds = "";
      var args = "ApplySubscriptionsString=" + subIds + "**";
      args += "ApplyPropertiesString=" + propertyIds + "**";
      args += "ApplyDefaultSecurityString=" + Ext.get("ctl00_ContentPlaceHolder1_cbApplyDefaultSecurityPolicy").dom.checked + "**";
      args += "ApplyAllDescendentsString=" + "true" + "**";
/*
      args += "ApplyStartDateString=" + Ext.get("ctl00_ContentPlaceHolder1_StartDate").dom.value + "**";
      args += "ApplyEndDateString=" + Ext.get("ctl00_ContentPlaceHolder1_EndDate").dom.value + "**";
*/
      args += "ApplyStartNextBillingPeriodString=" + Ext.get("ctl00_ContentPlaceHolder1_cbStartNextBillingPeriod").dom.checked + "**";
      args += "ApplyEndNextBillingPeriodString=" + Ext.get("ctl00_ContentPlaceHolder1_cbEndNextBillingPeriod").dom.checked + "**";
      args += "ApplyEndConflictingSubscriptionsString=true";
      pageNav.Execute("TemplateEvents_OKApplyTemplate_Client", args, results);
      return false;
    }
    
    function results(response)
    {
      Ext.UI.msg(TEXT_ERROR, response);
    }

  </script>

  <MT:MTDataBinder ID="MTDataBinder1" runat="server"></MT:MTDataBinder>

</asp:Content>
