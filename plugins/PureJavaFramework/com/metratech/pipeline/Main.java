package com.metratech.pipeline;


public class Main implements com.linar.jintegra.Instanciator {

  public static void main(String[] args)  throws Exception {
    
    com.linar.jintegra.AuthInfo.setDefault("METRATECH", "boris", "");
	com.linar.jintegra.Jvm.register("Sun118", new Main());
	


   System.out.println("Started dummy main");
   Thread.sleep(10000000000);
   
  }
  
  public Object instanciate(String javaClass)
            throws com.linar.jintegra.AutomationException {
    try {
      System.out.println("In Instanciator");
      return Class.forName(javaClass).newInstance();
    } catch(Exception e) {
      e.printStackTrace();
      throw new com.linar.jintegra.AutomationException(e);
    }
  }


  
}

