package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfigAttribSet'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigAttribSet Interface</B>'
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
public interface IMTConfigAttribSet {
  /**
   * getCount. property Count
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getAttrValue. property AttrValue
   *
   * @param     bstrKey The bstrKey (in)
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getAttrValue  (
              String bstrKey) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addPair. property AddPair
   *
   * @param     bstrKey The bstrKey (in)
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addPair  (
              String bstrKey,
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * initialize. method Initialize
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initialize  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * removeAttr. method RemoveAttr
   *
   * @param     key The key (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void removeAttr  (
              String key) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getAttrItem. property AttrItem
   *
   * @param     aIndex The aIndex (in)
   * @param     bKey The bKey (out: use single element array)
   * @param     pVal The pVal (out: use single element array)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void getAttrItem  (
              int aIndex,
              String[] bKey,
              String[] pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID88e54e75_b325_11d3_a604_00c04f579c39 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigAttribSetProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "88e54e75-b325-11d3-a604-00c04f579c39";
  String DISPID_1_GET_NAME = "getCount";
  String DISPID_2_GET_NAME = "getAttrValue";
  String DISPID_3_NAME = "addPair";
  String DISPID_4_NAME = "initialize";
  String DISPID_5_NAME = "removeAttr";
  String DISPID_6_NAME = "getAttrItem";
}
