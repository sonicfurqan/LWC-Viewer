public class ViewComponents {
    
    @AuraEnabled(cacheable=true)
    public static String allMetadaType(){
<<<<<<< HEAD
      	List<ToolingAPIService.SObjectType> allMetadata=ToolingAPIService.SObjectType.values();
=======
      List<ToolingAPIService.SObjectType> allMetadata=ToolingAPIService.SObjectType.values();
>>>>>>> c0ac79aa8a5e174fd08e2b78b52acd691715cec7
        List<String> mtadatatypes=new List<String>();
        for(ToolingAPIService.SObjectType md:allMetadata){
            if(md.name()=='LightningComponentBundle'){
                mtadatatypes.add(md.name());    
            }
                
           
            
        }
        return JSON.serialize(mtadatatypes);
    }
    
    @AuraEnabled
    public static String getMetadataValueList(String metadataType){
        System.debug('metadataType '+metadataType);
<<<<<<< HEAD
      	ToolingAPIService service=new ToolingAPIService();
=======
      ToolingAPIService service=new ToolingAPIService();
>>>>>>> c0ac79aa8a5e174fd08e2b78b52acd691715cec7
        HttpResponse response=service.queryMetadata(ToolingAPIService.getENUMforString.get((metadataType)));
            return response.getBody();
    }
    
     @AuraEnabled
    public static String getWebComponentList(){
       
<<<<<<< HEAD
      	ToolingAPIService service=new ToolingAPIService();
=======
      ToolingAPIService service=new ToolingAPIService();
>>>>>>> c0ac79aa8a5e174fd08e2b78b52acd691715cec7
        HttpResponse response=service.queryMetadata(ToolingAPIService.SObjectType.LightningComponentBundle);
            return response.getBody();
    }
    @AuraEnabled
    public static String getAuraComponent(String id){
        
        ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.queryAuraBundle(id);
        return response.getBody();
    }
    @AuraEnabled
    public static String getWebComponent(String id){
        
        ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.queryWebBundle(id);
        return response.getBody();
    }
    
    @AuraEnabled
    public static string setAuraComponent(String id,String sourceString){
       ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.updateAuraDefinition(sourceString,id);
        return response.getBody();
    }
    @AuraEnabled
    public static string setWebComponent(String id,String sourceString){
     
       ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.updateWebDefinition(sourceString,id);
        return response.getBody();
    }
<<<<<<< HEAD
    @AuraEnabled
    public static string createWebComponent(String fileName,Boolean isRecordPage,Boolean ishomePage,Boolean isallPage){
        ToolingAPIService service=new ToolingAPIService();
        return service.createWebComponent(fileName,isRecordPage,ishomePage,isallPage);
    }
    
    
    
}
=======
    
    
}
>>>>>>> c0ac79aa8a5e174fd08e2b78b52acd691715cec7
