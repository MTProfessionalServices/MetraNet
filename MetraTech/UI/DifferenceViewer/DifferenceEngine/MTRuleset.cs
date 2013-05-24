using System;
using System.Collections;
using System.Text;

using System.Runtime.InteropServices;
using MetraTech.Interop.MTRuleSet;


namespace MetraTech.DifferenceEngine
{
  public class RuleHelper
  {
    //We need to be able to determine if one rule is the same as another.
    //This helper method converts (serializes) a rule to a string which can be used for comparison
    public static string SerializeRuleToString(MTRule rule)
    {
      StringBuilder sb = new StringBuilder("Conditions[");
      foreach (MTSimpleCondition condition in rule.Conditions)
      {
        sb.Append(condition.PropertyName + " " + condition.Test + " " + condition.Value + " ");
      }
      sb.Append("] Actions[");
      foreach (MTAssignmentAction action in rule.Actions)
      {
        sb.Append(action.PropertyName + "=" + action.PropertyValue + " ");
      }
      sb.Append("]");

      return sb.ToString();
    }
  }

  public class Rule : IComparable
  {
    public string Line;
    public int _hash;
    public MTRule _sourceMTRule; //Used to save the original rule only so it can be explicitly referenced later

    public Rule(MTRule rule)
    {
      _sourceMTRule = rule; //Save the original rule only so it can be explicitly referenced later
      Line = RuleHelper.SerializeRuleToString(rule);
      _hash = Line.GetHashCode(); 
    }
    #region IComparable Members

    public int CompareTo(object obj)
    {
      return _hash.CompareTo(((Rule)obj)._hash);
    }

    #endregion
  }

	public class DiffList_Ruleset : IDiffList
	{
		private IMTRuleSet _ruleSet;
    private ArrayList _rules;

		public DiffList_Ruleset(IMTRuleSet ruleSet)
		{
			_ruleSet = ruleSet;

      _rules = new ArrayList();
      int iRuleCount = ruleSet.Count;
      for (int i=1;i<=iRuleCount;i++)
      {
        _rules.Add(new Rule((MTRule) ruleSet[i]));
      }
		}
		
		#region IDiffList Members

		public int Count()
		{
			return _rules.Count;
		}

		public IComparable GetByIndex(int index)
		{
			return (Rule)_rules[index];
		}

		#endregion

    public Rule GetRuleByIndex(int index)
    {
      return (Rule)_rules[index];
    }

	}
}