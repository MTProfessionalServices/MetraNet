dim rpt
set rpt = CreateObject("MetraTech.Reports.ReportConfigurationProxy")
wscript.echo rpt.DatabasePrefix

dim reportdef
dim reports
set reports = rpt.EOPReports
for each  reportdef in rpt.EOPReports
wscript.echo reportdef.UniqueName
wscript.echo"GOt HERE"
wscript.echo rpt.GetDisplayName("invoice.pdf")

Next