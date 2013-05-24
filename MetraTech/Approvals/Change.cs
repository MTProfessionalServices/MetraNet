using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Approvals
{
  public enum ChangeState { Pending, ApprovedWaitingToBeApplied, FailedToApply, Approved, Denied };

  public class ChangeSummary
  {
    public int Id { get; set; }
    public int SubmitterId { get; set; }
    public string SubmitterDisplayName { get; set; }
    public DateTime SubmittedDate { get; set; }
    public ChangeState CurrentState { get; set; }
    public string ChangeType { get; set; }
    public string UniqueItemId { get; set; }
    public string ItemDisplayName { get; set; }
    public string Comment { get; set; }
  }

  public class Change : ChangeSummary
  {
    public string ChangeDetailsBlob { get; set; }
  }

  public class ChangeHistoryItem
  {
    public int User { get; set; }
    public string UserDisplayName { get; set; }
    public DateTime Date { get; set; }
    public string Event { get; set; } //To be determined if this a string or a fixed set
    public string Details { get; set; }
  }



}
