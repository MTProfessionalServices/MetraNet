using System;
using NHibernate.Cfg.MappingSchema;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class HbmMappingWrapper
  {
    public HbmMapping HbmMapping { get; set; }
    public string MappingFile { get; set; }
    public string MappingFileWithPath { get; set; }
    public string CodeFile { get; set; }
    public string CodeFileWithPath { get; set; }
  }
}
