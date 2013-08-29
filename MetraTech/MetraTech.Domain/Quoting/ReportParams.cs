using System;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MetraTech.DomainModel.Common;

namespace MetraTech.Domain.Quoting
{
  [DataContract]
  [Serializable]
  public class ReportParams
  {
    #region PDFReport

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isPDFReportDirty = false;
    private bool m_PDFReport;
    [MTDataMember(Description = "Quote PDF report")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public bool PDFReport
    {
      get { return m_PDFReport; }
      set
      {
        m_PDFReport = value;
        isPDFReportDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsPDFReportDirty
    {
      get { return isPDFReportDirty; }
    }

    #endregion

    #region ReportTemplateName

    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isReportTemplateNameDirty = false;
    private string m_ReportTemplateName;
    [MTDataMember(Description = "Quote report template name")]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ReportTemplateName
    {
      get { return m_ReportTemplateName; }
      set
      {
        m_ReportTemplateName = value;
        isReportTemplateNameDirty = true;
      }
    }

    [ScriptIgnore]
    public bool IsReportTemplateNameDirty
    {
      get { return isReportTemplateNameDirty; }
    }

    #endregion
  }
}