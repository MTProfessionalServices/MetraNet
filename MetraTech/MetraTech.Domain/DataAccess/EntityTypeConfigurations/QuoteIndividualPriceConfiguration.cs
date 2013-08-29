using MetraTech.Domain.Quoting;
using System.Data.Entity.ModelConfiguration;

namespace MetraTech.Domain.DataAccess.EntityTypeConfigurations
{
    /// <summary>
    /// Entity Framework Code-First configuration that maps an entity or complex type to the database
    /// </summary>
    public class QuoteIndividualPriceConfiguration : EntityTypeConfiguration<QuoteIndividualPrice>
    {
        /// <summary>
        /// Default constructor
        /// </summary>
        public QuoteIndividualPriceConfiguration()
        {
            Map(t =>
            {
                t.ToTable("QuoteIndividualPrice");
                t.MapInheritedProperties();
            });
            Property(t => t.RateSchedulesXml).HasColumnName("RateSchedules");
        }
    }
}
