using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;

using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.ImportExport
{
  public class EntityExporter : EntityImportExportBase
  {
    private string dir;

    public EntityExporter() : base()
    {
      Logger = new MetraTech.Logger("[EntityExporter]");
    }

    /// <summary>
    /// Export business entities added with calls to AddEntity to the output directory
    /// </summary>
    /// <param name="directory">output directory</param>
    public void Export(string directory)
    {
      Logger.LogInfo("Exporting entities to directory {0}", directory);
      try
      {
        if (!System.IO.Directory.Exists(directory))
          System.IO.Directory.CreateDirectory(directory);
        dir = directory;

        if (entities.Count == 0 && relationshipEntities.Count == 0)
          throw new Exception("Nothing to export. Did you forget to call AddEntity?");

        // Open transaction so that nobody can change what is being exported
        // may be I should just lock the table which is being exported?..
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          foreach (Entity entity in entities.Values)
          {
            ExportEntity(entity);
          }
          foreach (Entity entity in relationshipEntities.Values)
          {
            ExportEntity(entity);
          }
        }
      }
      catch (Exception ex)
      {
        Logger.LogException("Export failed", ex);
        throw;
      }
    }

    private void ExportEntity(Entity entity)
    {
      Persistence.TableExporter exporter = new MetraTech.BusinessEntity.ImportExport.Persistence.TableExporter();
      Logger.LogInfo("exporting entity {0}", entity.FullName);
      Metadata.TableMetadata table = Metadata.TableMetadata.ReadMetadataFromEntity(entity);
      exporter.ExportTable(table, dir);
    }

  }
}
