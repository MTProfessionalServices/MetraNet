using MetraTech.Domain.Notifications;
using System.Data.Entity.ModelConfiguration;

namespace MetraTech.Domain.DataAccess.EntityTypeConfigurations
{
  /// <summary>
  /// Entity Framework Code-First configuration that maps an entity or complex type to the database
  /// </summary>
  public class NotificationConfigurationConfiguration : EntityTypeConfiguration<NotificationConfiguration>
  {
    /// <summary>
    /// Default constructor
    /// </summary>
    public NotificationConfigurationConfiguration()
    {
      Map(t =>
      {
        t.ToTable("NotificationConfiguration");
        t.MapInheritedProperties();
      });
      Property(t => t.MessageTemplateXml).HasColumnName("MessageTemplate");
    }
  }
}
