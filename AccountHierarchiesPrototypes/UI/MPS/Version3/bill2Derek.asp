<%
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Bill.asp -- Prototype for hierarchical bill in MPS.                     '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Option Explicit
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Global Variables                                                        '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Dim mstrDisplayType             'View of the bill to show

  mstrDisplayType = request.form("DisplayType")
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' RenderPage -- Transform XML data to the page.                           '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Function RenderPage(strType)
    Dim objXML      'XML object
    Dim objXSL      'XSL object
  
    'Create objects  
    Set objXSL = server.CreateObject("Msxml2.DOMDocument.3.0")
    Set objXML = server.CreateObject("Msxml2.DOMDocument.3.0")  

    'Init the objects
    objXSL.async             = false
    objXSL.validateOnParse   = false
    objXSL.resolveExternals  = false
  
    objXML.async             = false
    objXML.validateOnParse   = false
    objXML.resolveExternals  = false
    
    if UCase(mstrDisplayType) = "MYCHARGES" then
      Call objXSL.Load(server.MapPath("/prototypes/UI/MPS/Version3/MyChargesDerek.xsl"))
      Call objXML.Load(server.MapPath("/prototypes/UI/MPS/Version3/Charges.xml"))
    else
      Call objXSL.Load(server.MapPath("/prototypes/UI/MPS/Version3/OnlineBillDerek.xsl"))
      Call objXML.Load(server.MapPath("/prototypes/UI/MPS/Version3/Charges.xml"))
    end if
    
    RenderPage = objXML.transformNode(objXSL)    
    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
    <title>MPS Bill View for Hierarchies</title>
    <style>
      A{text-decoration:none};
    </style>
    
  </head>
  
  <body alink="darkgoldenrod">
    <form name="frmDisplay" action="bill2Derek.asp" method="POST">
    <table width="100%" cellpadding="0" cellspacing="0">
      <tr valign="top">
        <td align="left" width="1%" background="/samplesite/us/images/toolbar/gridTile.gif"><img src="/samplesite/us/images/toolbar/gridBackBlank.gif"></td>
        <td valign="middle" background="/samplesite/us/images/toolbar/gridTile.gif" nowrap><font face="Arial" size="2" color="white">&nbsp;&nbsp;&nbsp;Bill Summary</font></td>
        <td align="right" width="1%" background="/samplesite/us/images/toolbar/gridTile.gif"><img src="/samplesite/us/images/toolbar/gridHelp.gif"></td>
      </tr>
    </table>
    <table width="100%" cellspacing="0" cellpadding="0" style="padding-top:3px;">
      <tr>
        <td align="left"><b>Billing Period:</b> <select style="font-size:8pt"><option>9/1/2001 through Today</option></select></td>
        <td align="right"><b>View:</b></td>
        <td align="left">
          <select name="DisplayType" style="font-size:8pt" onChange="javascript:submit();">
<%
          if UCase(mstrDisplayType) = "MYCHARGES" then
%>
            <option value="AllCharges">All Charges I Pay For</option>
            <option selected value="MyCharges">Charges I Incurred</option></select>
<%
          else
%>
            <option selected value="AllCharges">All Charges I Pay For</option>
            <option value="MyCharges">Charges I Incurred</option></select>

<%
          end if
%>

          </select>
        </td>

        <td align="right"><a href="#"><img src="/samplesite/us/images/buttons/History.gif" border="0"></a></td>
        <td width="40">&nbsp;</td>
      </tr>
    </table>
    <br>
    
    <%=RenderPage(mstrDisplayType)%>
   <% if UCase(mstrDisplayType) = "MYCHARGES" then %>
    <table cellspacing="0" cellpadding="2" width="100%">
      <tr>
        <td bgcolor="seashell" align="left" width="100%" colspan="2" style="padding-top:10px;padding-bottom:10px"><font face="Arial" size="1" color="navy"><img src="/samplesite/us/images/misc/horzline.gif" width="100%" height="1"></font></td>
      </tr>
      <tr>
        <td bgcolor="seashell" align="left" width="75%"><font face="Arial" size="1" color="navy"><b>Sub-Total</b></font></td>
        <td bgcolor="seashell" align="right" width="25%"><b><font face="Arial" size="1" color="navy">$</font><font face="Courier New" style="font-size:8pt;" color="navy"><nobr>&nbsp2,916.93</nobr></font></b></td>
      </tr>
      <tr>
        <td bgcolor="seashell" align="left" width="75%"><font face="Arial" size="1" color="navy"><b>Tax</b></font></td>
        <td bgcolor="seashell" align="right" width="25%"><b><font face="Arial" size="1" color="navy">$</font><font face="Courier New" style="font-size:8pt;" color="navy"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;14.57</nobr></font></b></td>
      </tr>
      <tr>
        <td bgcolor="seashell" align="left" width="75%"><font face="Arial" size="1" color="navy"><b>Total</b></font></td>
        <td bgcolor="seashell" align="right" width="25%"><b><font face="Arial" size="1" color="navy">$</font><font face="Courier New" style="font-size:8pt;" color="navy"><nobr>&nbsp;2,931.50</nobr></font></b></td>
      </tr>
    </table>
    <%end if %>
    <br><br>
    <A href="#"><img src="/samplesite/us/images/buttons/RequestCredit.gif" border=0 alt="Request Credit"></A>
    <br><br><br>
    <b>Notes:</b><br>
    This view represents the bill as seen by Derek, a drone from sector 7G (he'll know what that means!).  His charges are redirected to Herb.
    
    </form>
  </body>
</html>
