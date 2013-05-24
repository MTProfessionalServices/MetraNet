using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Globalization;
using System.Reflection;
using System.Resources;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Core.Services.ClientProxies;
using System.Text;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.IO;

public partial class ApprovalFrameworkManagement_DefaultViewChangeDetails : MTPage
{

    public int iChangeId { get; set; }

    protected override void OnLoadComplete(EventArgs e)
    {
      Response.Write("<div id='xmlPretty' class='x-hide-display'>" + PrettyFormatXmlForHtml(GetChangeDetails(iChangeId)) + "</div>");
      Response.Write("<div id='xmlRaw' class='x-hide-display'><textarea rows='20' cols='80'>" + GetChangeDetails(iChangeId) + "</textarea>" + "</div>");

      base.OnLoadComplete(e);
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        iChangeId = Convert.ToInt32(Request.QueryString["changeid"]);
    }

    protected string GetChangeDetails(int changeId)
    {
      ApprovalManagementServiceClient client = null;
      string detailsOfThisParticularChange = "";
      try
      {
        client = new ApprovalManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;


        client.GetChangeDetails(changeId, ref detailsOfThisParticularChange);

        client.Close();
      }
      catch (Exception ex)
      {
        client.Abort();
        return "An unknown exception occurred.  Please check system logs: " + ex;
        throw;
      }

      return detailsOfThisParticularChange;
    }

    protected string PrettyFormatXmlForHtml(string xml)
    {
      try
      {
        string xlstFilePath = Server.MapPath(@"\Res\Xslt\xmlverbatim.xsl");
        StringReader rdr = new StringReader(xml);
        XPathDocument myXPathDoc = new XPathDocument(rdr);
        XslCompiledTransform myXslTrans = new XslCompiledTransform();
        myXslTrans.Load(xlstFilePath);

        StringBuilder sb = new StringBuilder();
        XmlWriterSettings xmlWriterSettings = new XmlWriterSettings();
        xmlWriterSettings.OmitXmlDeclaration = true;
        xmlWriterSettings.ConformanceLevel = ConformanceLevel.Fragment;
        XmlWriter myWriter = XmlWriter.Create(sb, xmlWriterSettings);
        myXslTrans.Transform(myXPathDoc, null, myWriter);

        return sb.ToString();
      }
      catch (Exception ex)
      {
        return string.Format("[Contents could not be formatted as xml: {0}]", ex.Message);
      }
    }

}