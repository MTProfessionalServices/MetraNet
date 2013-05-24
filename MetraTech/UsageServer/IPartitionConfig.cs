namespace MetraTech.UsageServer
{
    public interface IPartitionConfig
    {
        /// <summary>
        /// Shows whether partition is enabled on current DB
        /// </summary>
        bool IsPartitionEnabled { get; }

        /// <summary>
        /// Synchronizes the database with partition settings in any given file
        /// </summary>
        void Synchronize();
    }
}