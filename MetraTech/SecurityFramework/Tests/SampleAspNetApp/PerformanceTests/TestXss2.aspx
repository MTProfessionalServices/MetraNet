<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="TestXss2.aspx.cs" Inherits="SampleAspNetApp.PerformanceTests.TestXss2" ValidateRequest="false" %>

<%@ Register src="../Controls/XssDecoderTest.ascx" tagname="XssDecoderTest" tagprefix="sf" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <sf:XssDecoderTest ID="xssDecoderTest" runat="server" TestForXss="true" />
</asp:Content>
