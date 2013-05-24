/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using MetraTech.SecurityFramework.Core.Common;
using Microsoft.Data.Schema.ScriptDom.Sql;
using System.IO;
using Microsoft.Data.Schema.ScriptDom;
using MetraTech.SecurityFramework.Core.Detector;


namespace MetraTech.SecurityFramework
{
    internal sealed class DefaultSqlDetectorEngine : DetectorEngineBase
    {
		public DefaultSqlDetectorEngine():base(DetectorEngineCategory.Sql)
		{}

        /// <summary>
        /// Detects SQL injections.
        /// </summary>
        /// <param name="input">A data to be checked for SQL injections.</param>
        /// <returns>Execution result.</returns>
        protected override ApiOutput DetectInternal(ApiInput input)
        {
            bool foundSql = false;
            string reason = null;
            
            try
            {
                foundSql = CheckForSqlStatement(input, out reason);

                if (!foundSql)
                    foundSql = CheckForSqlParts(input, out reason);

                if (!foundSql)
                    foundSql = CheckForSqlLogic(input, out reason);
            }
            catch (Exception x)
            {
                string xmsg = x.Message;
                //KCQ:
                //When we send ugly data to the SQL parser it may throw exceptions
                //because the input data doesn't look like SQL. We'll simply ignore it.
                foundSql = false;
            }

            if (foundSql)
                throw new DetectorInputDataException(ExceptionId.Detector.DetectSqlInjection, Category, "SQL injection detected.", input.ToString(), reason);

            ApiOutput result = new ApiOutput(input);
            return result;
        }

        private bool CheckForSqlLogic(ApiInput input, out string reason)
        {
            reason = null;
            int index = input.ToString().IndexOf("'");
            if (index == -1)
            {
                return false;
            }
            int num2 = input.ToString().LastIndexOf("'");
            if (index == num2)
            {
                return false;
            }

            string str = input.ToString().Substring(0, index + 1);
            string str2 = input.ToString().Substring(index + 1).Replace("'", "");
            string str3 = str + str2;

            TSql100Parser sqlParser = new TSql100Parser(false);
            string sqlPrefix = "SELECT * FROM TEST WHERE X='";

            IList<ParseError> errorList;
            IScriptFragment fragment;

            using(StringReader reader = new StringReader(sqlPrefix + str3))
            {
                fragment = sqlParser.Parse(reader, out errorList);
            }

            if ((errorList == null || errorList.Count == 0) && ValidateScriptFragment(fragment))
            {
                reason = "SQL predicate logic found.";
                return true; 
            }

            return false;
        }

        private bool CheckForSqlStatement(ApiInput input, out string reason)
        {
            reason = null;
            string inputValue = input.ToString().Trim();
            string[] splitted = inputValue.Split(new char[] { ' ', '\t', '\n' });
            if (splitted.Length < 3)
            {
                return false;
            }
            //fix for the problem, where the possible query has 3 words and the first word ends with a dot
            //for example "Corp. Company Username" would be parsed as correct SQL query by TSql100Parser
            string toCheck = inputValue;
            if (splitted.Length == 3 && splitted[0].EndsWith("."))
            {
                toCheck = toCheck.Remove(splitted[0].Length - 1, 1);
            }

            TSql100Parser sqlParser = new TSql100Parser(false);

            IList<ParseError> errorList;
            IScriptFragment fragment;

            using(StringReader reader = new StringReader(toCheck))
            {
                fragment = sqlParser.Parse(reader, out errorList);
            }

            if ((errorList == null || errorList.Count == 0) && ValidateScriptFragment(fragment))
            {
                reason = "SQL statement found.";
                return true;
            }
            
            return false;
        }

        private bool CheckForSqlParts(ApiInput input, out string reason)
        {
            reason = null;
            if (input.ToString().Length < 3)
            {
                return false;
            }
            TSql100Parser sqlParser = new TSql100Parser(false);
            string sqlPrefix = "SELECT * FROM TEST WHERE X='";

            IList<ParseError> errorList;
            IScriptFragment fragment;

            using(StringReader reader = new StringReader(sqlPrefix + input))
            {
              fragment = sqlParser.Parse(reader, out errorList);
            }

            if ((errorList == null || errorList.Count == 0) && ValidateScriptFragment(fragment))
            {
                reason = "SQL fragment found.";
                return true;
            }

            return false;
        }

        /// <summary>
        /// Checks if the fragment contains any statement different from ExecuteStatement
        /// </summary>
        /// <param name="fragment">A SQL fragment to check</param>
        /// <returns>true if there is any non-ExecuteStatement statement in the fragment and false otherwise</returns>
        private bool ValidateScriptFragment(IScriptFragment fragment)
        {
          bool lastStatementIsExec = true;
          TSqlScript script = fragment as TSqlScript;

          if (script != null)
          {
            for (int i = 0; i < script.Batches.Count && lastStatementIsExec; i++)
            {
              for (int j = 0; j < script.Batches[i].Statements.Count && lastStatementIsExec; j++)
              {
                lastStatementIsExec = script.Batches[i].Statements[j] as ExecuteStatement != null;
              }
            }
          }

          return !lastStatementIsExec;
        }
    }
}
