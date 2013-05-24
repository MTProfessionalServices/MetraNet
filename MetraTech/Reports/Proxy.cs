using System;

namespace MetraTech.Reports
{
	using System.Diagnostics;
	using System.Xml.Serialization;
	using System;
	using System.Web.Services.Protocols;
	using System.ComponentModel;
	using System.Web.Services;
	using System.Collections;
	using System.Runtime.InteropServices;
    
    
	/// <remarks/>
	[System.Diagnostics.DebuggerStepThroughAttribute()]
	[System.Web.Services.WebServiceBindingAttribute(Name="LocalBinding", Namespace="http://www.metratech.com/webservices/")]
	[ComVisible(false)]
	public class ReportProxy : System.Web.Services.Protocols.SoapHttpClientProtocol 
	{
        
		public ReportProxy(string sURL) 
		{
			this.Url = sURL;
		}
		/// <remarks/>
		[System.Web.Services.Protocols.SoapDocumentMethodAttribute
			 ("http://www.metratech.com/webservices/DeleteFile", 
			 RequestNamespace="http://www.metratech.com/webservices/", 
			 ResponseNamespace="http://www.metratech.com/webservices/", 
			 Use=System.Web.Services.Description.SoapBindingUse.Literal, 
			 ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
		public void DeleteFile(string aFileName) 
		{
			object[] results = this.Invoke("DeleteFile", new object[] {aFileName});
			return ;
		}
		[System.Web.Services.Protocols.SoapDocumentMethodAttribute("http://www.metratech.com/webservices/DeleteFiles", 
			 RequestNamespace="http://www.metratech.com/webservices/", 
			 ResponseNamespace="http://www.metratech.com/webservices/", 
			 Use=System.Web.Services.Description.SoapBindingUse.Literal, 
			 ParameterStyle=System.Web.Services.Protocols.SoapParameterStyle.Wrapped)]
		public void DeleteFiles(ArrayList aFileNames) 
		{
			object[] results = this.Invoke("DeleteFiles", new object[] {aFileNames});
			return ;
		}

	}
}
