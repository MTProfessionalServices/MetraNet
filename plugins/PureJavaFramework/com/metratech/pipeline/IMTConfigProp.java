package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfigProp'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigProp Interface</B>'
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
public interface IMTConfigProp {
  /**
   * getName. property Name
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setName. property Name
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getValue. property Value
   *
   * @param     apType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (out: use single element array)
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getValue  (
              int[] apType) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getPropValue. property PropValue
   *
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropValue  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getPropType. property PropType
   *
   * @return    return value.  A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef) 
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getPropType  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getValueAsString. property ValueAsString
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getValueAsString  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getAttribSet. property AttribSet
   *
   * @return    return value.  An reference to a IMTConfigAttribSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigAttribSet getAttribSet  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setAttribSet. property AttribSet
   *
   * @param     ppAttribSet An reference to a IMTConfigAttribSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setAttribSet  (
              IMTConfigAttribSet ppAttribSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addProp. method AddProp
   *
   * @param     aType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (in)
   * @param     aVal A Variant (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addProp  (
              int aType,
              Object aVal) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID9adcd81c_35fd_11d2_a1c4_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigPropProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "9adcd81c-35fd-11d2-a1c4-006008c0e24a";
  String DISPID_1_GET_NAME = "getName";
  String DISPID_1_PUT_NAME = "setName";
  String DISPID_2_GET_NAME = "getValue";
  String DISPID_3_GET_NAME = "getPropValue";
  String DISPID_4_GET_NAME = "getPropType";
  String DISPID_5_GET_NAME = "getValueAsString";
  String DISPID_6_GET_NAME = "getAttribSet";
  String DISPID_6_PUT_NAME = "setAttribSet";
  String DISPID_7_NAME = "addProp";
}
