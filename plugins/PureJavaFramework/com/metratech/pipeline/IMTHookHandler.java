package com.metratech.pipeline;

/**
 * COM Interface 'IMTHookHandler'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTHookHandler Interface</B>'
 *
 * Generator Options:
 * PromptForTypeLibraries = True
 * AttemptNonDual = True
 * ClashPrefix = zz_
 * LowerCaseMemberNames = True
 * IDispatchOnly = False
 * RetryOnReject = True
 * GenerateDeprecatedConstructors = True
 * ArraysAsObjects = False
 * DontGenerateDisp = False
 * DontRenameSameMethods = False
 * IgnoreConflictingInterfaces = True
 */
public interface IMTHookHandler {
  /**
   * read. method Read
   *
   * @param     pPropSet An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void read  (
              IMTConfigPropSet pPropSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * first. method First
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void first  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * next. method Next
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void next  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * executeAll. method ExecuteAll
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void executeAll  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * firstHook. method FirstHook
   *
   * @param     var A Variant (in)
   * @param     pVal The pVal (in/out: use single element array)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void firstHook  (
              Object var,
              int[] pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextHook. method NextHook
   *
   * @param     var A Variant (in)
   * @param     pVal The pVal (in/out: use single element array)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void nextHook  (
              Object var,
              int[] pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * executeAllHooks. method ExecuteAllHooks
   *
   * @param     var A Variant (in)
   * @param     val The val (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void executeAllHooks  (
              Object var,
              int val) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * clearHooks. method ClearHooks
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void clearHooks  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getHookCount. property HookCount
   *
   * @return    return value.  The count
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getHookCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID3a58b7d4_00da_11d3_a59c_00c04f579c39 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTHookHandlerProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "3a58b7d4-00da-11d3-a59c-00c04f579c39";
  String DISPID_1_NAME = "read";
  String DISPID_2_NAME = "first";
  String DISPID_3_NAME = "next";
  String DISPID_4_NAME = "executeAll";
  String DISPID_5_NAME = "firstHook";
  String DISPID_6_NAME = "nextHook";
  String DISPID_7_NAME = "executeAllHooks";
  String DISPID_8_NAME = "clearHooks";
  String DISPID_1610743816_GET_NAME = "getHookCount";
}
