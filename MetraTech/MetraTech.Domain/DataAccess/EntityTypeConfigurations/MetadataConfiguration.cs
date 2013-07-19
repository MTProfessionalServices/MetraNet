using System.Data.Entity.ModelConfiguration;

namespace MetraTech.Domain.DataAccess.EntityTypeConfigurations
{
  /// <summary>
  /// Entity Framework Code-First configuration that maps an entity or complex type to the database
  /// </summary>
  public class MetadataConfiguration : EntityTypeConfiguration<Metadata>
  {
    /// <summary>
    /// Default constructor
    /// </summary>
    public MetadataConfiguration()
    {
      Map(t =>
      {
        t.ToTable("t_metadata");
        t.MapInheritedProperties();
      });
      HasKey(t => t.TimeCreate);
    }
  }
}
