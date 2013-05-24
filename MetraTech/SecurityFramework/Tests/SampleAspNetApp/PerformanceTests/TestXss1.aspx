<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="TestXss1.aspx.cs" Inherits="SampleAspNetApp.PerformanceTests.TestXss1" ValidateRequest="false" %>

<%@ Register src="../Controls/XssDecoderTest.ascx" tagname="XssDecoderTest" tagprefix="sf" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <sf:XssDecoderTest ID="xssDecoderTest" runat="server" TestForXss="true" />
</asp:Content>
