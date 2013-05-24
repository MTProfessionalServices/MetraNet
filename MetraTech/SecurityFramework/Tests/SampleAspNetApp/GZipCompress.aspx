<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="GZipCompress.aspx.cs" Inherits="SampleAspNetApp.GZipCompress" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <p>
        <asp:FileUpload ID="file" runat="server" />
    </p>
    <p>
        <asp:Button ID="btnEncode" runat="server" Text="Compress" OnClick="btnEncode_Click" />
    </p>
    <p>
        <asp:Label ID="lblCompressed" runat="server"></asp:Label>
    </p>
    <p>
        <asp:Repeater ID="repCompressed" runat="server">
            <HeaderTemplate>{ </HeaderTemplate>
            <ItemTemplate>
                <asp:Label runat="server" Text='<%# DataBinder.Eval(Container, "DataItem") %>'></asp:Label>,&nbsp;
            </ItemTemplate>
            <FooterTemplate>}</FooterTemplate>
        </asp:Repeater>
    </p>
</asp:Content>
