using MetraTech.Domain.Notifications;
using System.Data.Entity.ModelConfiguration;

namespace MetraTech.Domain.DataAccess.EntityTypeConfigurations
{
  /// <summary>
  /// Entity Framework Code-First configuration that maps an entity or complex type to the database
  /// </summary>
  public class NotificationEndpointConfiguration : EntityTypeConfiguration<NotificationEndpoint>
  {
    /// <summary>
    /// Default constructor
    /// </summary>
    public NotificationEndpointConfiguration()
    {
      Map(t =>
      {
        t.ToTable("NotificationEndpoint");
        t.MapInheritedProperties();
      });
      Property(t => t.AuthenticationConfigurationXml).HasColumnName("AuthenticationConfiguration");
      Property(t => t.EndpointConfigurationXml).HasColumnName("EndpointConfiguration");
    }
  }
}
