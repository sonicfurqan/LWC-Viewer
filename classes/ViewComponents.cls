public class ViewComponents {
    
    @AuraEnabled(cacheable=true)
    public static String allMetadaType(){
        List<ToolingAPIService.SObjectType> allMetadata=ToolingAPIService.SObjectType.values();
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
        ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.queryMetadata(ToolingAPIService.getENUMforString.get((metadataType)));
            return response.getBody();
    }
    
     @AuraEnabled
    public static String getWebComponentList(){
       
        ToolingAPIService service=new ToolingAPIService();
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
    @AuraEnabled
    public static string createWebComponent(String fileName,Boolean isRecordPage,Boolean ishomePage,Boolean isallPage){
        ToolingAPIService service=new ToolingAPIService();
        return service.createWebComponent(fileName,isRecordPage,ishomePage,isallPage);
    }
    
    
    
}