<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<!-- #INCLUDE FILE="../../auth.asp" --> 
<html>
  <head>
	  <title>Online Bill</title>
    
    <link rel="stylesheet" href="/newsamplesite/us/styles/ReportStyles.css">
    
    <script language="Javascript">
      //Global script for the page
      var hWin;
      
      //UpdateInterval -- Select a new usage interval
      function UpdateInterval() {
        var i = 0;
        var intLen = document.all('usage_interval').options.length;
        
        for(i=0; i < intLen; i++) {
          if(document.all('usage_interval').options[i].selected)
            document.location.href='ShowReport.asp?Action=UPDATEINTERVAL&amp;date_type=INTERVAL&amp;interval_id=' + document.all('usage_interval').options[i].value + '&amp;startDate=6/2/2002&amp;endDate=7/1/2002&amp;ReportHelper=ReportHelper';
        }
      }
    
      //UpdateViewType -- Select a new view type
      function UpdateViewType() {
        var i = 0;

        var intLen = document.all('view_type').options.length;
        
        for(i=0; i < intLen; i++) {
          if(document.all('view_type').options[i].selected)
            document.location.href='ShowReport.asp?Action=UPDATEVIEWTYPE&amp;view_type=' + document.all('view_type').options[i].value + '&amp;date_type=INTERVAL&amp;interval_id=22758&amp;startDate=6/2/2002&amp;endDate=7/1/2002&amp;ReportHelper=ReportHelper';
        }
      }

      //Open window for estimate my bill
      function OpenBillEstimateWindow() {
        hWin = window.open('ShowReport.asp?Action=ESTIMATEBILL&amp;date_type=INTERVAL&amp;interval_id=22758&amp;startDate=6/2/2002&amp;endDate=7/1/2002', 'Estimate','height=500, width=600, resizable=yes, scrollbars=yes, status=yes');
      }
      
      //Refresh Estimate
      function RefreshEstimate() {
        document.location.href = 'ShowReport.asp?Action=REFRESHESTIMATE&amp;date_type=INTERVAL&amp;interval_id=22758&amp;startDate=6/2/2002&amp;endDate=7/1/2002&amp;ReportHelper=ReportEstimateHelper';
      }
    </script>
    
  </head>
  <body bgcolor="#CFDBE5" text="BLACK" link="#658A16" alink="#658A16" vlink="blue">
    <font face="Arial" size="2">

<map name="backMap">
<area shape="rect" coords="11, 5, 24, 21" href="">
</map>
<SCRIPT LANGUAGE="JavaScript">function openHelpWindow(){window.open('help/helpUsageSummary.asp','','status,scrollbars,resizable,height=400,width=600')}</script>
<map name="helpMap">
<area shape="rect" coords="11, 3, 25, 24" href="javascript:openHelpWindow()">
</map>
<TABLE BORDER="0" WIDTH="100%" BGCOLOR="#CFDBE5" CELLPADDING="0" CELLSPACING="0">
<TR ALIGN=LEFT VALIGN=TOP>
<TD ALIGN=LEFT WIDTH="1%" BACKGROUND="/newsamplesite/us/images/fadetoolbar/gridTile.gif">
<img src="/newsamplesite/us/images/fadetoolbar/gridBackBlank.gif" border=0></TD>
<TD VALIGN=MIDDLE BACKGROUND="/newsamplesite/us/images/fadetoolbar/gridTile.gif" NOWRAP>
<TABLE width='100%' cellpadding='0' cellspacing='0'><TR><TD>
<font face='Arial' size='4' color='WHITE'><b>&nbsp;&nbsp;Online Bill</b></font>
</TD><TD align='right'>
<IMG align='center' src='/newsamplesite/us/images/misc/pb_MT.gif'>
</TD></TR></TABLE>
</TD>
<TD ALIGN=RIGHT WIDTH="1%" BACKGROUND="/newsamplesite/us/images/fadetoolbar/gridHelpBlank.gif"><img src="/newsamplesite/us/images/fadetoolbar/gridHelp.gif" usemap="#helpMap" border=0 alt="Help"></TD>
</TR></TABLE>
<img src="/newsamplesite/us/images/misc/bg_trans.gif" width="100%" height="3" border="0" hspace="0" vspace="0">
    <table border="0" width="100%" bgcolor="#CFDBE5" cellpadding="0" cellspacing="0" style="padding-left:20px;padding-right:20px;">
      <tr>
        <td align="left">
<b>Billing Period: </b><select name="usage_interval" onChange="javascript:UpdateInterval();" size="1" style="font-family:Arial;font-size:8pt;">
<option value="22758" selected>6/2/2002 through Today</option>
</select>

        </td>
        <td align="left">
<b>View Type: </b><select name="view_type" onChange="javascript:UpdateViewType();"  size="1" style="font-family:Arial;font-size:8pt;">
<option value="0" selected>By Folder</option>
<option value="1">By Product</option>
</select>
        </td>
        <td align="right">
          <a href="history.asp?Action=Dummy&date_type=INTERVAL&interval_id=22758&startDate=6/2/2002&endDate=7/1/2002&ReportHelper=ReportHelper&usageIntervalText=6/2/2002 through Today"><img border="0" src="/newsamplesite/us/images/greenbuttons/History.gif" alt="Billing History"></a>
        </td>
      </tr>
    </table>

    <br><br>
  <div class="clsReportDiv" align="center">
    <table class="clsReportTable" cellspacing="0" cellpadding="0" border="0" width="98%">
      <tr>
        <td class="clsReportHeader" align="left">Products and Services</td>
        <td class="clsReportHeader" align="right" width="1%">Amount</td>
      </tr>
      <tr>
        <td colspan="2">
          <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
              <td class="clsReportCharges">
    <table cellspacing="0" cellpadding="0" border="0" width="100%" class="clsReportPO">
      <tr>
        <td class="clsReportPOLabel" align="left">Audio Conferencing Product Offering 6/21/2002 10:58:57 AM</td>
        <td class="clsReportPOAmount" align="right"></td>
      </tr>
      <tr>
        <td colspan="3" class="clsReportSubLevel">
    <table cellspacing="0" cellpadding="0" border="0" width="100%" class="clsReportPI">
      <tr>
        <td width="1%"><a class="clsReportPVLink" href="products/metratech/audioConfCall.asp?pViewAmount=240&pViewAmountUOM=USD&usageIntervalID=22758&usageIntervalText=6/2/2002 through Today&ddl=1&accountSlice=PayerPayee/156/156&timeSlice=And/DateRange/37428/50406/Interval/22758&productSlice=Instance/104/4&ReportHelper=ReportHelper&sessionSlice=ROOT"><img border="0" src="/newsamplesite/us/images/icons/genericProduct.gif"></a></td>
        <td class="clsReportPILabel" align="left"><a class="clsReportPVLink" href='DefaultPVBAdjustment<%=Request.QueryString("s")%>.asp'>AudioConfCall</a></td>
        <td id="AudioConfCall.Amount" class="clsReportPIAmount" align="right"><NOBR>$ 240</NOBR></td>
      </tr>
    </table>
        </td>
      </tr>
    </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td colspan="2"><br><hr size="1" class="clsReportDivider"></td>
      </tr>
      <tr>
        <td align="left" class="clsReportChargeLabel">Sub-Total</td>
        <td nowrap align="right" class="clsReportChargeAmount"><NOBR>$ 240.00</NOBR></td>
      </tr>
      <tr>
        <td align="left" class="clsReportChargeLabel">Tax</td>
        <td nowrap align="right" class="clsReportChargeAmount"><NOBR>$ 0.00</NOBR></td>
      </tr>
      <tr>
        <td align="left" class="clsReportLevelLabel">Total</td>
        <td id="idTotalBill" nowrap align="right" class="clsReportLevelAmount"><NOBR>$ 240.00</NOBR></td>
      </tr>
    </table>
  </div>

    </font>
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;<a name="SubscriberCreditRequest" href="SubscriberCreditRequest.asp"><img src="/newsamplesite/us/images/greenbuttons/RequestCredit.gif" border="0" alt="Request Credit"></a>   
  </body>
</html>
