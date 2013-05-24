using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;


namespace MetraTech.DomainModel.Billing
{
#region Public Enums
  
 public enum ReportOutputTypeEnum
  {
    CSV,
    TXT,
    XML
  }

 public enum ReportDeliveryTypeEnum
 {
   Disk,
   FTP
 }

 public enum CompressReportEnum
 {
   No,
   Yes
 }

 public enum PreventAdhocExecutionEnum
 {
   No,
   Yes
 }
  
  public enum UseQuotedIdentifiersEnum
 {
   No,
   Yes
 }

 public enum WriteExecParamsToReportEnum
 {
   No,
   Yes
 }

 public enum SkipThisDayEnum
 {
   No,
   Yes
 }

 public enum SkipThisMonthEnum
 {
   No,
   Yes
 }


 public enum ExecuteThisDayEnum
 {
   No,
   Yes
 }

 public enum ExecuteThisMonthEnum
 {
   No,
   Yes
 }
  public enum ReportTitleEnum
 {
   MyTestReport,
   YourTestReport
 }

 public enum ReportExecutionTypeEnum
 {
   //AdHoc,
   EOP,
   Scheduled
 }

 public enum GenerateControlFileEnum
 {
   No,
   Yes
 }

 public enum ShowReportOnlineEnum
 {
   No,
   Yes
 }

 public enum SkipFirstDayOfMonthEnum
 {
   No,
   Yes
 }
 
  public enum SkipLastDayOfMonthEnum
 {
   No,
   Yes
 }

  public enum ExecuteFirstDayOfMonthEnum
  {
    No,
    Yes
  }

  public enum ExecuteLastDayOfMonthEnum
  {
    No,
    Yes
  }

  public enum MonthToDateEnum
  {
    No,
    Yes
  }

  public enum ExecuteWeekDaysEnum
  {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
  }

  public enum SkipWeekDaysEnum
  {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
  }

  public enum ExecuteMonthsEnum
  {
    January,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
  }

  public enum SkipMonthsEnum
  {
    January,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
  }

  public enum ScheduleTypeEnum
  {
    Daily,
    Weekly,
    Monthly
  }

#endregion

}

