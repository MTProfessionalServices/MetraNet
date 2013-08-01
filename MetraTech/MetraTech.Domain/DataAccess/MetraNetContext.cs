using System.Data.Common;
using MetraTech.Domain.Notifications;
using System;
using System.Data.Entity;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Reflection;

namespace MetraTech.Domain.DataAccess
{
  public class MetraNetContext : DbContext, IMetraNetContext
  {
    public IDbSet<Entity> Entities { get; set; }
    public IDbSet<NotificationConfiguration> NotificationConfigurations { get; set; }
    public IDbSet<NotificationEndpoint> NotificationEndpoints { get; set; }

    /// <summary>
    /// The constructor for MetraNet context
    /// </summary>
    /// <param name="connection">The exists connection to DataBase</param>
    public MetraNetContext(DbConnection connection) : base(connection, false)
    {
    }

      /// <summary>
    /// Returns a DbSet instance for access to entities of the given type in the context, the ObjectStateManager, and the underlying store.
    /// </summary>
    /// <typeparam name="TEntity">The type entity for which a set should be returned.</typeparam>
    /// <returns>A set for the given entity type.</returns>
    public new IDbSet<TEntity> Set<TEntity>() where TEntity : class
    {
      return base.Set<TEntity>();
    }

    /// <summary>
    /// Modifies the mapping from CLR objects to database table by overriding
    /// convention rules. This is invoked when the MetangaDbContext is first
    /// initialized.
    /// </summary>
    /// <param name="modelBuilder">Provides access to the model builder to override convention rules</param>
    protected override void OnModelCreating(DbModelBuilder modelBuilder)
    {
      if (modelBuilder == null) throw new ArgumentNullException("modelBuilder");

      var typesToRegister = Assembly.GetExecutingAssembly().GetTypes()
                                    .Where(
                                      type =>
                                      type.BaseType != null && type.BaseType.IsGenericType &&
                                      type.BaseType.GetGenericTypeDefinition() == typeof(EntityTypeConfiguration<>));

      modelBuilder.Ignore<LocalizationDictionary>();
      modelBuilder.Ignore<NotificationEndpointConfiguration>();
      modelBuilder.Ignore<AuthenticationConfiguration>();
      modelBuilder.Ignore<MessageTemplate>();
      foreach (var type in typesToRegister)
      {
        dynamic configurationInstance = Activator.CreateInstance(type);
        modelBuilder.Configurations.Add(configurationInstance);
      }
    }
  }
}
