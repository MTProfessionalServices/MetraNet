package com.metratech.pipeline;

/**
 * COM Interface 'IMTExecutionInfo'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTExecutionInfo Interface</B>'
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
public interface IMTExecutionInfo {
  /**
   * getSessionSet. property SessionSet
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet getSessionSet  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setSessionSet. property SessionSet
   *
   * @param     pVal An reference to a IMTSessionSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setSessionSet  (
              IMTSessionSet pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getStageName. property StageName
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getStageName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setStageName. property StageName
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setStageName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getPlugInName. property PlugInName
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getPlugInName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setPlugInName. property PlugInName
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setPlugInName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IIDce4382ef_de71_11d3_a3fe_00c04f484788 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTExecutionInfoProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "ce4382ef-de71-11d3-a3fe-00c04f484788";
  String DISPID_1_GET_NAME = "getSessionSet";
  String DISPID_1_PUT_NAME = "setSessionSet";
  String DISPID_2_GET_NAME = "getStageName";
  String DISPID_2_PUT_NAME = "setStageName";
  String DISPID_3_GET_NAME = "getPlugInName";
  String DISPID_3_PUT_NAME = "setPlugInName";
}
