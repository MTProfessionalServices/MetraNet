package com.metratech.pipeline;

/**
 * COM Interface 'IMTSessionProp'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTSessionProp Interface</B>'
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
public interface IMTSessionProp {
  /**
   * getName. property Name
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getNameID. property NameID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getNameID  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getType. property Type
   *
   * @return    return value.  A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0229_0001 constant (A  COM typedef) 
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getType  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID295fd850_f5ad_11d2_a1e3_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTSessionPropProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "295fd850-f5ad-11d2-a1e3-006008c0e24a";
  String DISPID_1610743808_GET_NAME = "getName";
  String DISPID_1610743809_GET_NAME = "getNameID";
  String DISPID_1610743810_GET_NAME = "getType";
}
