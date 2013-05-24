using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;

using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.ImportExport
{
  public class EntityImporter : EntityImportExportBase
  {
    private string dir;
    
    public EntityImporter() : base()
    {
      Logger = new MetraTech.Logger("[EntityImporter]");
    }
    
    /// <summary>
    /// Import entities previously added with AddEntity calls from output directory.
    /// Will do following things:
    /// 1) check that metadata in the Metadata repository matches with Metadata stored in the output directory.
    /// If you want to skip this check set Options.IgnoreMetadataDifferences = true
    /// 2) Check that CSV files are found and don't have any format errors.
    /// 3) start transaction
    /// 4) Truncate relationship tables, then entities tables to avoid FK constraints violations
    /// if you want to append the data - set Options.ImportMode == Options.ImportModeEnum.Append.
    /// 5) Import data from csv files. First enities, then relationships to avoid FK constraints violations
    /// 6) Close transactions.
    /// </summary>
    /// <param name="Directory">Directory where to look for </param>
    public void Import(string Directory)
    {
      Logger.LogInfo("Importing entities from directory {0}", Directory);
      try
      {
        dir = Directory;
        if (!System.IO.Directory.Exists(Directory))
          throw new System.IO.DirectoryNotFoundException(string.Format("Import directory {0} not found", Directory));

        // Check metadata first. We don't want to truncate any tables
        // also check that we have no problems with CSV files.
        CheckMetadata();

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                       new TransactionOptions(),
                                                       EnterpriseServicesInteropOption.Full))
        {
          if (Options.ImportMode == Options.ImportModeEnum.Replace)
          {
            TruncateEntities();
          }

          ImportEntities();
          scope.Complete();
        }
      }
      catch (Exception ex)
      {
        Logger.LogException("Unable to Import Enitities", ex);
        throw;
      }
    }

    private void ImportEntities()
    {
      // populate first entity then relationship, to avoid FK constrains violation
      List<Entity> entitiesToImport = entities.Values.ToList<Entity>();
      // Now that we have the relationships between BMEs we need to sort 
      // them based on the order of relationship. So if entities are A->B->C
      // I need to truncate in order A,B,C and insert in order C->B->A
      metadataRepository.PerformTopologicalSort(entitiesToImport);
      foreach (Entity entity in entitiesToImport)
      {
        ImportEntity(entity);
      }
      foreach (Entity entity in relationshipEntities.Values)
      {
        ImportEntity(entity);
      }
    }

    private void TruncateEntities()
    {
      // truncate first relationship then entities, to avoid FK constrains violation
      foreach (Entity entity in relationshipEntities.Values)
      {
        TruncateEntity(entity);
      }
      List<Entity> entitiesToTruncate = entities.Values.ToList<Entity>();
      // Now that we have the relationships between BMEs we need to sort 
      // them based on the order of relationship. So if entities are A->B->C
      // I need to truncate in order A,B,C and insert in order C->B->A
      metadataRepository.PerformReverseTopologicalSort(entitiesToTruncate);
      foreach (Entity entity in entitiesToTruncate)
      {
        TruncateEntity(entity);
      }
    }

    private void CheckMetadata()
    {
      foreach (Entity entity in entities.Values)
      {
        CheckMetadata(entity);
      }
      foreach (Entity entity in relationshipEntities.Values)
      {
        CheckMetadata(entity);
      }
    }

    private void TruncateEntity(Entity entity)
    {
      Persistence.TableImporter importer = new MetraTech.BusinessEntity.ImportExport.Persistence.TableImporter();
      Metadata.TableMetadata table = Metadata.TableMetadata.ReadMetadataFromEntity(entity);
      importer.TruncateTable(table, dir);
    }

    private void CheckMetadata(Entity entity)
    {
      Persistence.TableImporter importer = new MetraTech.BusinessEntity.ImportExport.Persistence.TableImporter();
      Metadata.TableMetadata table = Metadata.TableMetadata.ReadMetadataFromEntity(entity);
      importer.CheckTableMetadata(table, dir);
      importer.TestDataFile(table, dir);
    }

    private void ImportEntity(Entity entity)
    {
      Persistence.TableImporter importer = new MetraTech.BusinessEntity.ImportExport.Persistence.TableImporter();
      Metadata.TableMetadata table = Metadata.TableMetadata.ReadMetadataFromEntity(entity);
      importer.ImportTable(table, dir); 
    }

  }
}
