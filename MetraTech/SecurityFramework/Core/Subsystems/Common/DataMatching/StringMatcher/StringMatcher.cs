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
using System.Collections;

//
// C# Aho-Corasick string matching algorithm implementation
//

namespace MetraTech.SecurityFramework
{
    public class StringMatcher
    {
        public StringMatcher()
        {
            mId = Guid.NewGuid().ToString() + "." + this.ToString();
        }

        public StringMatcher(string[] keywords)
        {
            this.Keywords = keywords;
        }

        private void BuildTree()
        {
            if (AppDomain.CurrentDomain.GetData(mId) != null)
                mRoot = (TreeNode)AppDomain.CurrentDomain.GetData(mId);
            else  // no tree in Cache, generate it and store in Cache
            {
                mRoot = new TreeNode(null, ' ');
                TreeNode node1 = null;
                foreach (string str in mKeywords)
                {
                    node1 = mRoot;
                    foreach (char ch in str)
                    {
                        TreeNode node2 = null;
                        foreach (TreeNode node3 in node1.Transitions)
                        {
                            if (node3.Char == ch)
                            {
                                node2 = node3;
                                break;
                            }
                        }
                        if (node2 == null)
                        {
                            node2 = new TreeNode(node1, ch);
                            node1.AddTransition(node2);
                        }
                        node1 = node2;
                    }
                    node1.AddResult(str);
                }
                ArrayList list = new ArrayList();
                foreach (TreeNode node in mRoot.Transitions)
                {
                    node.Failure = mRoot;
                    foreach (TreeNode node3 in node.Transitions)
                    {
                        list.Add(node3);
                    }
                }
                while (list.Count != 0)
                {
                    ArrayList list2 = new ArrayList();
                    Char ch;
                    foreach (TreeNode node in list)
                    {
                        TreeNode failure = node.Parent.Failure;
                        ch = node.Char;
                        while ((failure != null) && !failure.ContainsTransition(ch))
                        {
                            failure = failure.Failure;
                        }
                        if (failure == null)
                        {
                            node.Failure = mRoot;
                        }
                        else
                        {
                            node.Failure = failure.GetTransition(ch);
                            foreach (string str2 in node.Failure.Results)
                            {
                                node.AddResult(str2);
                            }
                        }
                        foreach (TreeNode node5 in node.Transitions)
                        {
                            list2.Add(node5);
                        }
                    }
                    list = list2;
                }
                mRoot.Failure = mRoot;
                System.AppDomain.CurrentDomain.SetData(mId, mRoot);
            }
        }

        public bool ContainsAny(string text)
        {
            TreeNode failure = mRoot;
            for (int i = 0; i < text.Length; i++)
            {
                TreeNode transition = null;
                while (transition == null)
                {
                    transition = failure.GetTransition(text[i]);
                    if (failure == mRoot)
                    {
                        break;
                    }
                    if (transition == null)
                    {
                        failure = failure.Failure;
                    }
                }
                if (transition != null)
                {
                    failure = transition;
                }
                if (failure.Results.Length > 0)
                {
                    return true;
                }
            }
            return false;
        }

        public StringMatchResult[] FindAll(string text)
        {
            ArrayList list = new ArrayList();
            TreeNode failure = mRoot;
            for (int i = 0; i < text.Length; i++)
            {
                TreeNode transition = null;
                while (transition == null)
                {
                    transition = failure.GetTransition(text[i]);
                    if (failure == mRoot)
                    {
                        break;
                    }
                    if (transition == null)
                    {
                        failure = failure.Failure;
                    }
                }
                if (transition != null)
                {
                    failure = transition;
                }
                foreach (string str in failure.Results)
                {
                    list.Add(new StringMatchResult((i - str.Length) + 1, str));
                }
            }
            return (StringMatchResult[])list.ToArray(typeof(StringMatchResult));
        }

        public StringMatchResult FindFirst(string text)
        {
            ArrayList list = new ArrayList();
            TreeNode failure = mRoot;
            for (int i = 0; i < text.Length; i++)
            {
                TreeNode transition = null;
                while (transition == null)
                {
                    transition = failure.GetTransition(text[i]);
                    if (failure == mRoot)
                    {
                        break;
                    }
                    if (transition == null)
                    {
                        failure = failure.Failure;
                    }
                }
                if (transition != null)
                {
                    failure = transition;
                }
                string[] results = failure.Results;
                int index = 0;
                while (index < results.Length)
                {
                    string keyword = results[index];
                    return new StringMatchResult((i - keyword.Length) + 1, keyword);
                }
            }
            return StringMatchResult.Empty;
        }

        public string[] Keywords
        {
            get
            {
                return mKeywords;
            }
            set
            {
                mKeywords = value;
                this.BuildTree();
            }
        }

        #region Private Data

        private string[] mKeywords;
        private TreeNode mRoot;
        private string mId;

        #endregion

        #region Private Classes

        private class TreeNode
        {
            private char mChar;
            private StringMatcher.TreeNode mFailure;
            private StringMatcher.TreeNode mParent;
            private ArrayList mResults;
            private string[] mResultsAr;
            private Hashtable mTransHash;
            private StringMatcher.TreeNode[] mTransitionsAr;

            public TreeNode(StringMatcher.TreeNode parent, char c)
            {
                mChar = c;
                mParent = parent;
                mResults = new ArrayList();
                mResultsAr = new string[0];
                mTransitionsAr = new StringMatcher.TreeNode[0];
                mTransHash = new Hashtable();
            }

            public void AddResult(string result)
            {
                if (!mResults.Contains(result))
                {
                    mResults.Add(result);
                    mResultsAr = (string[])mResults.ToArray(typeof(string));
                }
            }

            public void AddTransition(StringMatcher.TreeNode node)
            {
                mTransHash.Add(node.Char, node);
                StringMatcher.TreeNode[] array = new StringMatcher.TreeNode[mTransHash.Values.Count];
                mTransHash.Values.CopyTo(array, 0);
                mTransitionsAr = array;
            }

            public bool ContainsTransition(char c)
            {
                return (this.GetTransition(c) != null);
            }

            public StringMatcher.TreeNode GetTransition(char c)
            {
                return (StringMatcher.TreeNode)mTransHash[c];
            }

            public char Char
            {
                get {return mChar;}
            }

            public StringMatcher.TreeNode Failure
            {
                get {return mFailure;}
                set {mFailure = value;}
            }

            public StringMatcher.TreeNode Parent
            {
                get{return mParent;}
            }

            public string[] Results
            {
                get {return mResultsAr;}
            }

            public StringMatcher.TreeNode[] Transitions
            {
                get {return mTransitionsAr;}
            }
        }

        #endregion
    }
}
