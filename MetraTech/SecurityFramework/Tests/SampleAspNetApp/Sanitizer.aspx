<%@ Page Title="Sanitizer test" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Sanitizer.aspx.cs" Inherits="SampleAspNetApp.Sanitizer" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<h2>Tests for Sanitizer</h2>
    <asp:UpdatePanel runat="server" ID="pnlMain">
        <ContentTemplate>
            <fieldset>
                <legend>Base64 sanitizer</legend>
                <asp:Panel ID="PanelBase64Sanitizer" runat="server" DefaultButton="btnBase64Sanitizer">
                    <p>
                        <asp:TextBox ID="txtBase64Sanitizer" runat="server" Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:Label ID="lbBase64Sanitizer" runat="server"></asp:Label>
                    </p>
                    <asp:Button ID="btnBase64Sanitizer" runat="server" Text="Sanitize" OnClick="btnBase64Sanitizer_Click" />
                </asp:Panel>
            </fieldset>   
            </ContentTemplate>
      </asp:UpdatePanel>
</asp:Content>

