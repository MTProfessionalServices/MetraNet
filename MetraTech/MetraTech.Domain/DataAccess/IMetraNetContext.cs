using MetraTech.Domain.Notifications;
using MetraTech.Domain.Quoting;
using System.Data.Entity;

namespace MetraTech.Domain.DataAccess
{
  /// <summary>
  /// Interface for Entity Framework database context for MetraNet
  /// </summary>
  public interface IMetraNetContext
  {
    IDbSet<Entity> Entities { get; set; }
    IDbSet<NotificationConfiguration> NotificationConfigurations { get; set; }
    IDbSet<NotificationEndpoint> NotificationEndpoints { get; set; }

    /// <summary>
    /// Returns a DbSet instance for access to entities of the given type in the context, the ObjectStateManager, and the underlying store.
    /// </summary>
    /// <typeparam name="TEntity">The type entity for which a set should be returned.</typeparam>
    /// <returns>A set for the given entity type.</returns>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", MessageId = "Set", Justification = "Mario: Required to mock DbContext")]
    IDbSet<TEntity> Set<TEntity>() where TEntity : class;
  }
}
