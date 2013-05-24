/**************************************************************************
* Copyright 1997-2010 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Viktor Grytsay <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Common.Configuration;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Engine of processor subsystem.
	/// </summary>
	public class ProcessorEngine : EngineBase
	{
		#region Constants

		private const string SecurityIssueMessage = "Security issue found";
		private const string ExceptionReasonFormat = "Worked processor engine: {0}\n{1}";

		#endregion

		#region Private fields

		object _syncRoot = new object();
		private ProcessorEngineCategory _category;
		private IList<string> _chainRules = new List<string>();

		#endregion

		#region Protected properties

		/// <summary>
		/// Gets current subsystem
		/// </summary>
		protected override Type SubsystemType
		{
			get
			{
				return typeof(MetraTech.SecurityFramework.Processor);
			}
		}

		#endregion

		#region Public properties

		/// <summary>
		/// Gets or sets rule id. This rule starts processing.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string IdFirstRule
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets maximum default number of positives rules
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public uint MaxExecution
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets rules collection.
		/// </summary>
		[SerializeCollectionAttribute(IsRequired = true, MappedName = "Rules", DefaultType = typeof(List<IRule>),
									ElementType = typeof(SequenceRule), ElementName = "Rule")]
		internal IList<IRule> RulesCollection
		{
			get;
			private set;
		}

		[SerializePropertyAttribute(IsRequired = true, MappedName = "Category")]
		public override string CategoryName
		{
			protected set
			{
				string val = value;
				try
				{
					_category = ((ProcessorEngineCategory)Enum.Parse(typeof(ProcessorEngineCategory), val));
				}
				catch
				{
					throw new SubsystemInputParamException(string.Format("Category {0} is not valid", val));
				}
			}
			get
			{
				return _category.ToString();
			}
		}

		/// <summary>
		/// Gets or private sets rules collection.
		/// </summary>
		public IDictionary<string, IRule> Rules
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets queue of worked rules
		/// </summary>
		public IList<string> ChainRules
		{
			get
			{
				return _chainRules;
			}
		}

		/// <summary>
		/// Gets a value indicating the engine has its own performance monitoring.
		/// </summary>
		protected override bool HasOwnPerformanceMonitoring
		{
			[DebuggerStepThrough]
			get
			{
				return true;
			}
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Checking input data.
		/// </summary>
		/// <param name="input"></param>
		/// <returns></returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (this.IsInitialized == false)
			{
				throw new SubsystemInputParamException("Processor engine is not initialized.");
			}

			if (input == null)
			{
				throw new NullInputDataException(
					ExceptionId.Processor.General.ToInt(),
					SubsystemName,
					this._category.ToString(),
					"Input string is null",
					SecurityEventType.InputDataProcessingEventType);
			}

			Stopwatch watch = new Stopwatch();
			watch.Start();

			try
			{
				lock (_syncRoot)
				{
					string inputStr = input.ToString();
					Dictionary<string, int> workedRules = new Dictionary<string, int>();

					_chainRules.Clear();
					ApiOutput output = null;

					//Initialization start rule
					IRule workedRule = Rules[IdFirstRule];

					string idNextRule;
					watch.Stop();
					try
					{
						idNextRule = workedRule.Execute(input, ref output);
						input = new ApiInput(output);
					}
					finally
					{
						watch.Start();
					}

					//Checked execution count for current rule and increment excecution count for current rule if it's less than MaxExecution of current rule
					CheckWorkedRule(workedRule, workedRules, inputStr, output != null ? output.Exceptions : null);
					_chainRules.Add(workedRule.Id);

					while (workedRule is StopRule == false)
					{
						//Initialization next rule in chain of rules processor 
						workedRule = Rules[idNextRule];

						//Checked execution count for current rule and increment excecution count for current rule if it's less than MaxExecution of current rule
						CheckWorkedRule(workedRule, workedRules, inputStr, output != null ? output.Exceptions : null);
						watch.Stop();
						try
						{
							idNextRule = workedRule.Execute(input, ref output);
							input = new ApiInput(output);
						}
						finally
						{
							watch.Start();
						}

						_chainRules.Add(workedRule.Id);
					}

					if (output != null && output.Exceptions.Count > 0)
					{
						throw new ProcessorException(
							this._category,
							SecurityIssueMessage,
							output.Exceptions,
							inputStr,
							string.Format(ExceptionReasonFormat, this.Id, ConcatErrorReasons(output.Exceptions)).Trim());
					}
					return output;
				}
			}
			finally
			{
				// Measure performance.
				watch.Stop();
				PerformanceMonitor.IncrementWorkTime(watch.ElapsedTicks);
			}
		}

		#endregion

		#region Public methods

		/// <summary>
		/// Initializes engine members.
		/// </summary>
		/// <param name="engineProps"></param>
		public override void Initialize()
		{
			//Check if current rule id is not null
			if (string.IsNullOrEmpty(Id))
			{
				string msg = "Processor engine id is null. Check configuration file processor subsystem.";
				throw new SubsystemInputParamException(msg);
			}

			//Check if rules collection is not null
			if (RulesCollection == null)
			{
				string msg = "Rules collection in properties for processor engine {0} is null. Check configuration file for processor subsystem.";
				throw new SubsystemInputParamException(string.Format(msg, Id));
			}

			//Check if first rule is not null
			if (string.IsNullOrEmpty(IdFirstRule))
			{
				string msg = "First rule in properties for processor engine {0} is null. Check configuration file for processor subsystem.";
				throw new SubsystemInputParamException(string.Format(msg, Id));
			}

			if (MaxExecution == 0)
			{
				string msg = "MaxExecution field in properties for processor engine {0} is null. Check configuration file for processor subsystem.";
				throw new SubsystemInputParamException(string.Format(msg, Id));
			}

			Rules = new Dictionary<string, IRule>();

			//Adding initialized rules to dictionary in current engine
			foreach (IRule rule in RulesCollection)
			{
				rule.Initialize();

				if (rule is RuleBase)
				{
					((RuleBase)rule).MaxExecution = MaxExecution;
				}

				if (Rules.ContainsKey(rule.Id))
				{
					throw new ConfigurationException(string.Format("Rule with id {0} in processor engine {1} already initialized. Check configuration file for processor subsystem.",
																	rule.Id, Id));
				}

				Rules.Add(rule.Id, rule);
			}

			IEnumerable<IRule> switchRules = RulesCollection.Where(p => p is SwitchRule);
			foreach (IRule iRule in switchRules)
			{
				SwitchRule rule = iRule as SwitchRule;
				foreach (Case key in rule.Cases)
				{
					if (!Rules.ContainsKey(key.IdNextRule))
					{
						string msg = "True in cases collection for rule {0} is not declared or declared with an error. Check configuration file for processor subsystem.";
						throw new SubsystemInputParamException(string.Format(msg, rule.Id));
					}
				}
			}

			if (Rules.Values.Count(p => p is StopRule) == 0)
			{
				throw new ConfigurationException(string.Format("Processor engine {0} not contains stop rule!",
																Id));
			}

			if (Rules.ContainsKey(IdFirstRule) == false)
			{
				string msg = "Start rule in properties for processor engine {0} is not declared or declared with an error. Check configuration file for processor subsystem.";
				throw new SubsystemInputParamException(string.Format(msg, Id));
			}

			base.Initialize();
		}

		#endregion

		#region Private methods

		/// <summary>
		/// Checks execution count in processor chain and adding worked rule id to worked rules collection.
		/// </summary>
		/// <param name="rule">A rule to be executed.</param>
		/// <param name="workedRules">A list of rules have already worked at the current call.</param>
		/// <param name="inputData">An inpet data.</param>
		/// <param name="errors">A list of gathered errors.</param>
		private void CheckWorkedRule(IRule rule, IDictionary<string, int> workedRules, string inputData, IEnumerable<Exception> errors)
		{
			if (workedRules.ContainsKey(rule.Id) == false)
			{
				workedRules.Add(rule.Id, 1);
			}
			else if (rule is RuleBase && workedRules[rule.Id] >= ((RuleBase)rule).MaxExecution)
			{
				throw new ProcessorException(
					this._category,
					SecurityIssueMessage,
					errors,
					inputData,
					string.Format(ExceptionReasonFormat, this.Id, ConcatErrorReasons(errors, "The processor came in a closed cycle")).Trim());
			}
			else
			{
				workedRules[rule.Id]++;
			}
		}

		private static string ConcatErrorReasons(IEnumerable<Exception> errors, params string[] additional)
		{
			StringBuilder sb = new StringBuilder();

			// Concat reasons from security excertions.
			foreach (Exception ex in errors)
			{
				BadInputDataException error = ex as BadInputDataException;
				if (error != null)
				{
					AppendMessage(sb, error.Reason);
				}
			}

			foreach (string message in additional)
			{
				AppendMessage(sb, message);
			}

			return sb.ToString();
		}

		private static void AppendMessage(StringBuilder sb, string message)
		{
			if (sb.Length > 0)
			{
				sb.AppendLine(";");
			}

			sb.Append(message);
		}

		#endregion
	}
}
