using System.Runtime.InteropServices;

[assembly: GuidAttribute("420A266A-3110-4136-BF53-1B80583C9896")]
namespace MetraTech.UI.DifferenceViewer
{
  using System;
  using System.Diagnostics;
  using System.Reflection;
  using System.Runtime.InteropServices;
  using System.Management;
  using System.IO;

  using System.Collections;
  using System.Web;
  using System.Text;
  using System.Text.RegularExpressions;

  using System.Xml;
  
  using MetraTech.Interop.MTRuleSet;
  using MetraTech.DifferenceEngine;

  //RulesetDifferenceGenerator is passed the rulesets and it generates and returns a RulesetDifference which encapsulates the
  //differences between the two rulesets.

  //using MetraTech.Interop.MTUsageServer;
  [Guid("4602349B-9E71-4380-B653-A9E8927C7D92")]
  public interface IRulesetDifference
  {
    int GetDifferenceSpanCount();
    string GetDifferenceSpanStatus(int iSpan);
    int GetDifferenceSpanLength(int iSpan);
    int GetDifferenceSpanSourceIndex(int iSpan);
    int GetDifferenceSpanDestinationIndex(int iSpan);
    bool DifferenceDetected();
    //Because our rulesets are collections without an exact way to reference items from the original rulesets passed in,
    //I have added these methods to get the specific rules referenced by the DifferenceSpan
    IMTRule GetSourceItem(int index);
    IMTRule GetDestinationItem(int index);
  }

  [Guid("D2168E98-6883-46ed-A01F-F639419D041E")]
  public class RulesetDifference : IRulesetDifference
  {

    private ArrayList _DiffSpans;
    private DiffList_Ruleset _srcDiffList;
    private DiffList_Ruleset _dstDiffList;

    public RulesetDifference(DiffList_Ruleset srcDiffList,DiffList_Ruleset dstDiffList,ArrayList DiffSpans)
    {
      _srcDiffList = srcDiffList;
      _dstDiffList = dstDiffList;
      _DiffSpans = DiffSpans;
    }

    public int GetDifferenceSpanCount() {return _DiffSpans.Count;}
    public string GetDifferenceSpanStatus(int iSpan) {return ConvertSpanStatusToString(((DiffResultSpan)_DiffSpans[iSpan]).Status);}
    public int GetDifferenceSpanLength(int iSpan) {return ((DiffResultSpan)_DiffSpans[iSpan]).Length;}
    public int GetDifferenceSpanSourceIndex(int iSpan) {return ((DiffResultSpan)_DiffSpans[iSpan]).SourceIndex;}
    public int GetDifferenceSpanDestinationIndex(int iSpan) {return ((DiffResultSpan)_DiffSpans[iSpan]).DestIndex;}

    public IMTRule GetSourceItem(int index)
    {
      return _srcDiffList.GetRuleByIndex(index)._sourceMTRule;
    }

    public IMTRule GetDestinationItem(int index)
    {
      return _dstDiffList.GetRuleByIndex(index)._sourceMTRule;
    }

    public bool DifferenceDetected()
    {
      if ((_DiffSpans.Count==0) || ((_DiffSpans.Count==1 && (((DiffResultSpan)_DiffSpans[0]).Status==DiffResultSpanStatus.NoChange))))
      {
        return false;
      }
      else
      {
        return true;
      }
    }

    private string ConvertSpanStatusToString(DiffResultSpanStatus status)
    {
      switch (status)
      {
        case DiffResultSpanStatus.NoChange:
          return "NoChange";
        case DiffResultSpanStatus.Replace:
          return "Replace";
        case DiffResultSpanStatus.DeleteSource:
          return "DeleteSource";
        case DiffResultSpanStatus.AddDestination:
          return "AddDestination";
      }
      
      return "UnknownStatus";
    }

  }

  [Guid("904AE3C7-F1B1-48b4-BEC2-AB4F22BD1DDA")]
  public interface IRulesetDifferenceGenerator
  {
    IRulesetDifference GetDifference(IMTRuleSet srcRuleset,IMTRuleSet dstRuleset);
  }

  [Guid("3DB54BE5-6BC4-47fd-9D8B-FCA01F131DD6")]
  public class RulesetDifferenceGenerator : IRulesetDifferenceGenerator
  {
    private DiffEngineLevel _level;

    public RulesetDifferenceGenerator()
    {
      _level = DiffEngineLevel.SlowPerfect; 		//FastImperfect, Medium, SlowPerfect
    }

    public IRulesetDifference GetDifference(IMTRuleSet srcRuleset, IMTRuleSet dstRuleset)
    {

        DiffList_Ruleset sLF = null;
        DiffList_Ruleset dLF = null;
        try
        {
          sLF = new DiffList_Ruleset(srcRuleset);
          dLF = new DiffList_Ruleset(dstRuleset);
        }
        catch (Exception ex)
        {
          throw ex;
        }
        
        
        try
        {
          double time = 0;
          DiffEngine de = new DiffEngine();
          time = de.ProcessDiff(sLF,dLF,_level);

          ArrayList DiffLines = de.DiffReport();

          return new RulesetDifference(sLF,dLF,DiffLines);

        }
        catch (Exception ex)
        {
          string tmp = string.Format("{0}{1}{1}***STACK***{1}{2}",
            ex.Message,
            Environment.NewLine,
            ex.StackTrace); 
          throw ex;
        }
  
    }
  }
}

