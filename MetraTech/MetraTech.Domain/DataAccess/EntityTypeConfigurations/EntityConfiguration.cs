using System.Data.Entity.ModelConfiguration;

namespace MetraTech.Domain.DataAccess.EntityTypeConfigurations
{
  /// <summary>
  /// Entity Framework Code-First configuration that maps an entity or complex type to the database
  /// </summary>
  public class EntityConfiguration : EntityTypeConfiguration<Entity>
  {
    /// <summary>
    /// Default constructor
    /// </summary>
    public EntityConfiguration()
    {
      Property(t => t.NameXml).HasColumnName("Name");
      Property(t => t.DescriptionXml).HasColumnName("Description");
    }
  }
}
