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
using System.Text;

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinProcessorQualifier
    {
        private string _appPath = "/";
        private bool _useResourceQualifiers = false;
        private bool _excludeResourceMode = true;
        //private bool _isExtResource = false;
        private HashSet<string> _resourceQualifiers = new HashSet<string>(new CaseInsensitiveStringComparer());
        private HashSet<string> _extQualifiers = new HashSet<string>(new CaseInsensitiveStringComparer());
        private WinProcessor _processor = null;

        public string AppPath
        { get { return _appPath; } }

        public bool UseResourceQualifiers
        { get { return _useResourceQualifiers; } }

        public bool ExcludeResourceMode
        { get { return _excludeResourceMode; } }

        //public bool IsExtResource
        //{ get { return _isExtResource; } }

        public bool HasExt(string name)
        {
            if (string.IsNullOrEmpty(name))
                return false;

            return _extQualifiers.Contains(name);
        }

        public bool HasResource(string name)
        {
            if (string.IsNullOrEmpty(name))
                return false;

            return _resourceQualifiers.Contains(name);
        }

        public bool IsMatch(string appPath, string ext, string resource)
        {
            if (!_useResourceQualifiers)
                return true;

            if (string.IsNullOrEmpty(appPath) || string.Compare(appPath, _appPath, StringComparison.CurrentCultureIgnoreCase) == 0)
            {
                if (string.IsNullOrEmpty(ext))
                {
                    if (string.IsNullOrEmpty(resource))
                    {
                        return true;
                    }
                    else
                    {
                        if (_excludeResourceMode)
                        {
                            if (_resourceQualifiers.Contains(resource))
                            {
                                return false;
                            }
                            else
                            {
                                return true;
                            }
                        }
                        else
                        {
                            //In the "include" mode we can still report a match when the qualifier set is empty!
                            if ((0 == _resourceQualifiers.Count) || _resourceQualifiers.Contains(resource))
                            {
                                return true;
                            }
                            else
                            {
                                return false;
                            }
                        }
                    }
                }
                else
                {
                    if (_extQualifiers.Contains(ext))
                    {
                        if (string.IsNullOrEmpty(resource))
                        {
                            return true;
                        }
                        else
                        {
                            if (_excludeResourceMode)
                            {
                                if (_resourceQualifiers.Contains(resource))
                                {
                                    return false;
                                }
                                else
                                {
                                    return true;
                                }
                            }
                            else
                            {
                                //In the "include" mode we can still report a match when the qualifier set is empty!
                                if ((0 == _resourceQualifiers.Count) || _resourceQualifiers.Contains(resource))
                                {
                                    return true;
                                }
                                else
                                {
                                    return false;
                                }
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }
                }
            }

            return false;
        }

        public WinProcessor Processor
        { get { return _processor; } }

        public static WinProcessorQualifier CreateQualifier(WinQualifierInfo info, WinProcessor processor)
        {
            WinProcessorQualifier obj = new WinProcessorQualifier(info,processor);
            return obj;
        }

        private WinProcessorQualifier(WinQualifierInfo info, WinProcessor processor)
        {
            _processor = processor;
            _appPath = info.AppPath.ToLower();
            _useResourceQualifiers = info.UseResourceQualifiers;
            _excludeResourceMode = info.ExcludeResourceMode;
            //_isExtResource = info.IsExtResource;
            if (null != info.Resources)
            {
                foreach (string r in info.Resources)
                {
                    string val = r.ToLower();
                    if (!_resourceQualifiers.Contains(val))
                    {
                        _resourceQualifiers.Add(val);
                    }
                }
            }
            if (null != info.Extensions)
            {
                foreach (string r in info.Extensions)
                {
                    string val = r.ToLower();
                    if (!_extQualifiers.Contains(val))
                    {
                        _extQualifiers.Add(val);
                    }
                }
            }
        }
    }
}

