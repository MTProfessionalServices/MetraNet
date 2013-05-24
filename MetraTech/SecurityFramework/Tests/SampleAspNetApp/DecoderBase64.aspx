<%@ Page Title="Base64 group decoder test" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="DecoderBase64.aspx.cs" Inherits="SampleAspNetApp.DecoderBase64" ValidateRequest="False" EnableEventValidation="False"%>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h2>Tests for Base64 group decoders</h2>
    <asp:UpdatePanel runat="server" ID="pnlMain">
        <ContentTemplate>
            <fieldset>
                <legend>Complex 'Base64' </legend>
                <asp:Panel ID="PanelComplexBase64" runat="server" DefaultButton="btnComplexBase64Decode">
                    <p>
                        <asp:TextBox ID="txtComplexBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="textResultComplexBase64Decode" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnComplexBase64Decode" runat="server" Text="Decode" OnClick="btnComplexBase64Decode_Click" />
                </asp:Panel>
            </fieldset>            
            <fieldset>
                <legend>Standard 'Base64' encoding for RFC 3548or RFC 4648; char62 = '+'; char63 = '/'</legend>
                <asp:Panel ID="pnlBase64" runat="server" DefaultButton="btnStandartBase64Decode">
                    <p>
                        <asp:TextBox ID="txtStandartBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultStandartBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True" ></asp:TextBox>
                    </p>
                    <asp:Button ID="btnStandartBase64Decode" runat="server" Text="Decode" OnClick="btnStandartBase64Decode_Click" />
                </asp:Panel>
            </fieldset>
            <fieldset>
                <legend>Modified Base64 for filenames (non standard); char62 = '+'; char63 = '-'</legend>
                <asp:Panel ID="PanelModifiedForFilenamesBase64" runat="server" DefaultButton="btnModifiedForFilenames64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForFilenamesBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForFilenamesBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForFilenames64Decode" runat="server" Text="Decode" OnClick="btnModifiedForFilenamesBase64Decode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Modified Base64 for URL applications; char62 = '-'; char63 = '_'</legend>
                <asp:Panel ID="PanelModifiedForURLBase64" runat="server" DefaultButton="btnModifiedForURLBase64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForURLBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForURLBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForURLBase64Decode" runat="server" Text="Decode" OnClick="btnModifiedForURLBase64Decode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Modified Base64 for XML name tokens (Nmtoken); char62 = '.'; char63 = '-'</legend>
                <asp:Panel ID="PanelModifiedForXmlNmtokeBase64" runat="server" DefaultButton="btnModifiedForXmlNmtokeBase64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForXmlNmtokeBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForXmlNmtokeBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForXmlNmtokeBase64Decode" runat="server" Text="Decode" OnClick="btnModifiedForXmlNmtokeBase64Decode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Modified Base64 for XML identifiers (Name); char62 = '_'; char63 = ':'</legend>
                <asp:Panel ID="PanelModifiedForXmlNameBase64" runat="server" DefaultButton="btnModifiedForXmlNameBase64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForXmlNameBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForXmlNameBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForXmlNameBase64Decode" runat="server" Text="Decode" OnClick="btnModifiedForXmlNameBase64Decode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Modified Base64 for Program identifiers(variant 1, non standard); char62 = '_'; char63 = '-'</legend>
                <asp:Panel ID="PanelModifiedForProgramIdentofiersV1Base64" runat="server" DefaultButton="btnModifiedForProgramIdentofiersV1Base64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForProgramIdentofiersV1Base64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForProgramIdentofiersV1Base64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForProgramIdentofiersV1Base64Decode" runat="server" Text="Decode" OnClick="btnModifiedForProgramIdentofiersV1Base64Decode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Modified Base64 for Program identifiers(variant 1, non standard); char62 = '_'; char63 = '-'</legend>
                <asp:Panel ID="PanelModifiedForProgramIdentofiersV2Base64" runat="server" DefaultButton="btnModifiedForProgramIdentofiersV2Base64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForProgramIdentofiersV2Base64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForProgramIdentofiersV2Base64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForProgramIdentofiersV2Base64Decode" runat="server" Text="Decode" OnClick="btnModifiedForProgramIdentofiersV2Base64Decode_Click" />
                </asp:Panel>
            </fieldset>

            <fieldset>
                <legend>Modified Base64 for Regular expressions(non standard); char62 = '!'; char63 = '-'</legend>
                <asp:Panel ID="PanelModifiedForRegularExpressionsBase64" runat="server" DefaultButton="btnModifiedForRegularExpressionsBase64Decode">
                    <p>
                        <asp:TextBox ID="txtModifiedForRegularExpressionsBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%"></asp:TextBox>
                    </p>
                    <p>
                        Result:
                    </p>
                    <p>
                        <asp:TextBox ID="txtResultModifiedForRegularExpressionsBase64" runat="server" Height="55px" TextMode="MultiLine" 
                            Width="90%" ReadOnly="True"></asp:TextBox>
                    </p>
                    <asp:Button ID="btnModifiedForRegularExpressionsBase64Decode" runat="server" Text="Decode" OnClick="btnModifiedForRegularExpressionsBase64Decode_Click" />
                </asp:Panel>
            </fieldset>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>