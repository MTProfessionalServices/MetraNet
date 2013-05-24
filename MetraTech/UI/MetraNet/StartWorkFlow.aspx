<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="StartWorkFlow" Title="MetraNet" CodeFile="StartWorkFlow.aspx.cs" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<br />
<div class="CaptionBar">Additional Information:</div><br />
<b>Workflow Name:  </b> <%= Utils.EncodeForHtml(WorkflowName) %>  <br />
<b>Request:  </b> <%=  Utils.EncodeForHtml(Request.Url.ToString()) %>
</asp:Content>

