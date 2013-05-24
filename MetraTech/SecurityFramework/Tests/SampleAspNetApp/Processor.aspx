<%@ Page Title="" Language="C#" MasterPageFile="~/Master.Master" AutoEventWireup="true" CodeBehind="Processor.aspx.cs" Inherits="SampleAspNetApp.Processor" ValidateRequest="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <h2>
        Tests for processor</h2>
    <asp:UpdatePanel runat="server" ID="pnlMain">
        <ContentTemplate>

            <fieldset>
                <legend>Processor</legend>
                <div style="width:100%; text-align:center;">
                    <asp:Label runat="server" ID="lblError" ForeColor="Red" Font-Size="14"></asp:Label>
                </div>
                <table style="width:100%;" cellspacing="0" cellpadding="0" border="1">
                    <tr>
                        <td style="vertical-align:top; text-align:left; width:320px;">
                            <p>
                                <asp:Label ID="Label1" runat="server" Width="200">Select processor-pipeline: </asp:Label>
                            </p>
                            <p>
                                <asp:DropDownList runat="server" Width="200" ID="ddlProc" AutoPostBack="true" OnSelectedIndexChanged="ddlProc_IChange" ></asp:DropDownList>
                            </p>

                            <asp:Panel runat="server" ID="pnlInclude" Visible="false" >
                                <p>
                                    <asp:Label runat="server" Width="200">Includes rules: </asp:Label>
                                </p>
                                <p>
                                    <asp:ListBox runat="server" ID="listIncRules" Width="300"></asp:ListBox>
                                </p>
                                <p>
                                    <asp:Label ID="lblStartRule" runat="server" Width="200">Start rule: </asp:Label>
                                </p>
                            </asp:Panel>

                        </td>

                        <td style="vertical-align:top; text-align:left;">
                            <asp:Panel runat="server" ID="pnlProc" DefaultButton="btnProc">                          
                                <p>
                                    <asp:Label ID="Label3" runat="server">Insert testing text:</asp:Label>
                                </p>
                                <p>
                                    <asp:TextBox style="width:100%; height:150px;" ID="txtProc" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </p>
                                <p>
                                    <asp:Button ID="btnProc" runat="server" Text="Check" 
                                        OnClick="btnProcClick" />
                                </p>
                                <p>
                                    <asp:Label ID="lblResult" ForeColor="Green" runat="server" EnableViewState="false">Result:</asp:Label>
                                    (in <asp:Label ID="lblTicks" runat="server" EnableViewState="false"></asp:Label> &micro;s)
                                </p>
                                <p>
                                    <asp:Label ID="lblProc" runat="server" EnableViewState="false"></asp:Label>
                                </p>
                                <p>
                                    
                                    <table>
                                        <tr>
                                            <td style="vertical-align:top;">
                                                <asp:Label ForeColor="Red" runat="server"> Indicate engines:</asp:Label>
                                                 <asp:DataGrid runat="server" ID="Engines"></asp:DataGrid>
                                            </td>
                                            <td style="vertical-align:top;">
                                                <asp:Label runat="server" ID="lblWorkedRules">Worked rules: </asp:Label>
                                                <asp:DataGrid runat="server" ID="ChainRules"></asp:DataGrid>
                                            </td>
                                            <td style="vertical-align:top;">
                                                <asp:Label runat="server" >Count executions: </asp:Label>
                                                <asp:DataGrid runat="server" ID="Rules"></asp:DataGrid>
                                            </td>
                                        </tr>
                                    </table>
                                    
                                    
                                </p>
                            </asp:Panel>
                        </td>
                    </tr>
                </table>
                
            </fieldset>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
