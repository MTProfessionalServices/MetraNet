#if false
namespace MetraTech.FileService
{
  using System.IO;
  using Core.FileLandingService;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;

  public class cDirectory : acConfigurationEntity
  {
    private string m_FullName = "";

    public cDirectory(IStandardRepository db, DirectoryBE f)
      :base(db, f)
    {
      m_FullName = System.IO.Path.Combine(f._Path, f._Name);
      if (!Directory.Exists(m_FullName))
        Directory.CreateDirectory(m_FullName);

    }
    public EDirectoryType Type
    {
      get
      {
        return (Instance as DirectoryBE)._Type;
      }
    }

    public string Name
    {
      get
      {
        return (Instance as DirectoryBE)._Name;
      }
    }
    public string Path
    {
      get
      {
        return (Instance as DirectoryBE)._Path;
      }
    }
    public string FullName
    {
      get
      {
        return m_FullName;
      }
    }
  }
}
#endif