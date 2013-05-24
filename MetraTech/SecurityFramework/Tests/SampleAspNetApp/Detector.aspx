<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Detector.aspx.cs" Inherits="SampleAspNetApp.Detector" ValidateRequest="False" EnableEventValidation="False"%>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h2>
        Tests for detectors</h2>
    <asp:UpdatePanel runat="server" ID="pnlMain">
        <ContentTemplate>

            <fieldset>
                <legend>XSS</legend>
                <asp:Panel runat="server" ID="pnlXss" DefaultButton="btnXssDetect">
                    <p>
                        <asp:TextBox ID="txtXss" runat="server"></asp:TextBox>
                        <asp:CheckBox ID="chbXssNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    
                    <asp:Panel runat="server">
                        <asp:Literal ID="ltrText" runat="server" Visible="False" Mode="PassThrough"></asp:Literal>
                        
                    </asp:Panel>
                    <p>
                    </p>
                    <asp:Button ID="btnXssDetect" runat="server" onclick="btnXssDetect_Click" 
                        Text="Detect" />
                    <p>
                    </p>
                    <p>
                    </p>
                    <p>
                    </p>
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Sql</legend>
                <asp:Panel runat="server" ID="pnlSql" DefaultButton="btnSqlDetect">
                    <p>
                        <asp:TextBox ID="txtSql" runat="server"></asp:TextBox>
                        <asp:CheckBox ID="chbSqlNull" runat="server" AutoPostBack="true" Text="Set to NULL" />
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:Label ID="lblSqlDetect" runat="server"></asp:Label>
                    </p>
                    <asp:Button ID="btnSqlDetect" runat="server" Text="Detect" 
                        onclick="btnSqlDetect_Click" />
                </asp:Panel>
            </fieldset>

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
