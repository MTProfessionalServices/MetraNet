package com.metratech.pipeline;

/**
 * COM Interface 'IMTSessionSet'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTSessionSet Interface</B>'
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
public interface IMTSessionSet {
  /**
   * addSession. method AddSession
   *
   * @param     aSessionId The aSessionId (in)
   * @param     aServiceId The aServiceId (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSession  (
              int aSessionId,
              int aServiceId) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getCount. property Count
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getItem. property Item
   *
   * @param     aIndex The aIndex (in)
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getItem  (
              int aIndex) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * get_NewEnum. property _NewEnum
   *
   * @return    return value.  An enumeration.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Enumeration get_NewEnum  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getId. property ID
   *
   * @return    return value.  The id
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getId  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IIDc8757978_20e5_11d2_a1c1_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTSessionSetProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "c8757978-20e5-11d2-a1c1-006008c0e24a";
  String DISPID_3_NAME = "addSession";
  String DISPID_4_GET_NAME = "getCount";
  String DISPID_0_GET_NAME = "getItem";
  String DISPID__4_GET_NAME = "get_NewEnum";
  String DISPID_6_GET_NAME = "getId";
}
