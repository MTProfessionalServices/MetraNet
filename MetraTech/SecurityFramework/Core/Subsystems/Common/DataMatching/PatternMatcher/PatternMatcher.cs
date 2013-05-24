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
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Reflection;
using System.IO;

namespace MetraTech.SecurityFramework
{
    public class PatternMatcher
    {
        public PatternMatcher()
        {
            mPrecompile = false;
        }

        public PatternMatcher(Dictionary<string, string> search, Dictionary<string, string> exclude, bool precompile)
        {
            mPrecompile = precompile;
            mSearchPatterns = search;
            mExceptionPatterns = exclude;
        }

        public void Load()
        {
            if (mPrecompile)
            {
                PrecompileSearchPatterns();
                PrecompileExceptionPatterns();
                LoadPrecompiledSearchPatterns();
                LoadPrecompiledExceptionPatterns();
            }
            else
            {
                LoadDynamicPatterns();
            }
        }

        private void PrecompileSearchPatterns()
        {
            int max = mSearchPatterns.Count;
            if (max > 0)
            {
                RegexCompilationInfo[] ci = new RegexCompilationInfo[max];

                int cnt = 0;
                foreach (KeyValuePair<string, string> record in mSearchPatterns)
                {
                    RegexCompilationInfo current =
                     new RegexCompilationInfo(record.Value,
                                RegexOptions.Compiled,   // MS uses: RegexOptions.IgnoreCase | RegexOptions.CultureInvariant
                                record.Key,
                                "PatternMatcher.PrecompiledSearchPatterns",
                                true);

                    ci[cnt++] = current;
                }

                AssemblyName an = new System.Reflection.AssemblyName();
                an.Name = "PrecompiledSearchPatterns";
                //Alternatively could do:
                //AssemblyName an = new AssemblyName("PrecompiledSearchPatterns, Version=1.0.0.1001, Culture=neutral, PublicKeyToken=null");

                Regex.CompileToAssembly(ci, an);
            }
        }

        private void PrecompileExceptionPatterns()
        {
            int max = mSearchPatterns.Count;
            if (max > 0)
            {
                RegexCompilationInfo[] ci = new RegexCompilationInfo[max];

                int cnt = 0;
                foreach (KeyValuePair<string, string> record in mExceptionPatterns)
                {
                    RegexCompilationInfo current =
                     new RegexCompilationInfo(record.Value,
                                RegexOptions.Compiled,
                                record.Key,
                                "PatternMatcher.PrecompiledExceptionPatterns",
                                true);

                    ci[cnt++] = current;
                }

                AssemblyName an = new System.Reflection.AssemblyName();
                an.Name = "PrecompiledExceptionPatterns";

                Regex.CompileToAssembly(ci, an);
            }
        }

        private void LoadPrecompiledSearchPatterns()
        {
            string assemblyPath = "PrecompiledSearchPatterns.dll";

            if (Directory.Exists(assemblyPath))
            {
                Assembly pmAssembly = Assembly.LoadFrom(assemblyPath);

                foreach (Type type in pmAssembly.GetTypes())
                {
                    if ((type.IsClass == true) &&
                        (type.BaseType.FullName == "System.Text.RegularExpressions.Regex"))
                    {
                        PrecompiledRegex pcRegex = new PrecompiledRegex(type);
                        mPcSearchList.Add(pcRegex);
                    }
                }
            }
        }

        private void LoadPrecompiledExceptionPatterns()
        {
            string assemblyPath = "PrecompiledExceptionPatterns.dll";

            if (Directory.Exists(assemblyPath))
            {
                Assembly pmAssembly = Assembly.LoadFrom(assemblyPath);

                foreach (Type type in pmAssembly.GetTypes())
                {
                    if ((type.IsClass == true) &&
                        (type.BaseType.FullName == "System.Text.RegularExpressions.Regex"))
                    {
                        PrecompiledRegex pcRegex = new PrecompiledRegex(type);
                        mPcExceptionList.Add(pcRegex);
                    }
                }
            }
        }

        public void AddSearchPattern(string id, string pattern)
        {
            mSearchPatterns.Add(id, pattern);
        }

        public void AddExceptionPattern(string id, string pattern)
        {
            mExceptionPatterns.Add(id, pattern);
        }

        public void SetSearchPatterns(Dictionary<string, string> records)
        {
            mSearchPatterns = records;
        }

        public void SetExceptionPatterns(Dictionary<string, string> records)
        {
            mExceptionPatterns = records;
        }

        private void LoadDynamicPatterns()
        {
            foreach (KeyValuePair<string, string> record in mSearchPatterns)
            {
                Regex re = new Regex(record.Value);
                mSearchListRef.Add(record.Key, re);
                mSearchList.Add(re);
            }

            foreach (KeyValuePair<string, string> record in mExceptionPatterns)
            {
                Regex re = new Regex(record.Value);
                mExceptionListRef.Add(record.Key, re);
                mExceptionList.Add(re);
            }
        }

        public bool HasMatches(string text)
        {
            return HasMatchesAt(text, 0);
        }

        public bool HasMatchesAt(string text, int position)
        {
            bool result = false;

            if (string.IsNullOrEmpty(text))
            {
                return result;
            }

            foreach (Regex r in mSearchList)
            {
                if (r.IsMatch(text, position))
                {
                    result = true;
                    break;
                }
            }

            if (result)
            {
                foreach (Regex r in mExceptionList)
                {
                    if (r.IsMatch(text, position))
                    {
                        result = false;
                        break;
                    }
                }
            }

            return result;
        }

        public PatternMatchResult[] MatchAll(string text)
        {
            return MatchAllAt(text, 0);
        }

        public PatternMatchResult[] MatchAllAt(string text, int position)
        {
            List<PatternMatchResult> results = new List<PatternMatchResult>();
            bool hasMatches = false;

            foreach (Regex r in mSearchList)
            {
                MatchCollection matchList = r.Matches(text, position);
                foreach (Match m in matchList)
                {
                    if (m.Success)
                    {
                        PatternMatchResult mr = new PatternMatchResult(m.Index, m.Length, m.Value);
                        results.Add(mr);
                        hasMatches = true;
                    }
                }
            }

            if (hasMatches)
            {
                foreach (Regex r in mExceptionList)
                {
                    Match match = r.Match(text, position);
                    if (match.Success)
                    {
                        hasMatches = false;
                        results = null;
                        return null;
                    }
                }
            }

            return results.ToArray();
        }

        public void BeginMatching()
        {
        }

        public void EndMatching()
        {
        }

        #region Private Data

        private bool mPrecompile = false;

        private List<Regex> mSearchList = new List<Regex>();
        private List<Regex> mExceptionList = new List<Regex>();

        private List<PrecompiledRegex> mPcSearchList = new List<PrecompiledRegex>();
        private List<PrecompiledRegex> mPcExceptionList = new List<PrecompiledRegex>();

        private Dictionary<string, Regex> mSearchListRef = new Dictionary<string, Regex>();
        private Dictionary<string, Regex> mExceptionListRef = new Dictionary<string, Regex>();

        private Dictionary<string, string> mSearchPatterns = new Dictionary<string, string>();
        private Dictionary<string, string> mExceptionPatterns = new Dictionary<string, string>();

        #endregion
    }
}
