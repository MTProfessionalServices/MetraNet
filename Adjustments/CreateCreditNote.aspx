<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="CreateCreditNote.aspx.cs" Inherits="Adjustments_CreateCreditNote"
meta:resourcekey="PageResource1" Culture="auto" UICulture="auto"%>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
   <MT:MTPanel ID="MTPanel1" runat="server" Text="Create Credit Note" 
    Collapsed="False" Collapsible="True" 
    meta:resourcekey="MTPanel1Resource1" >
   <MT:MTDropDown ID="ddTemplateTypes" runat="server" Label="Credit Note Template To Use" 
      LabelWidth="170" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}"
      meta:resourcekey="ddTemplateTypesResource1" ReadOnly="False" Enabled="True">
    </MT:MTDropDown>
   <MT:MTDropDown ID="ddTimeIntervals" runat="server" Label="Adjustments issued in past" 
      LabelWidth="170" AllowBlank="False" HideLabel="False" LabelSeparator=":" Listeners="{}"
      meta:resourcekey="ddTimeIntervalsResource1" ReadOnly="False" Enabled="True" ControlWidth="100">
    </MT:MTDropDown>

    </MT:MTPanel>
</asp:Content>