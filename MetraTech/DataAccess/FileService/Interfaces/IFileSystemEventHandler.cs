namespace MetraTech.FileService
{
  /// <summary>
  /// Interface that should be implemented by any class wishing to handle file landing events.
  /// </summary>
  public interface IFileLandingEventHandler
  {
    /// <summary>
    /// Handler function that is called whenever a filesystem event occurs.
    /// </summary>
    /// <param name="e">
    /// Arguments (file name, directory, event type, etc.) associated with the event.
    /// </param>
    /// <param name="wo">
    /// cWorkOrder definition (file name, file group, service defitition, etc)
    /// </param>
    /*
    void OnFileLandingEvent(WatcherExtEventArgs e, WorkOrder wo); */
  }
}
