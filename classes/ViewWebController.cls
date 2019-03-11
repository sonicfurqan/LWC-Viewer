public class ViewWebController {
    @AuraEnabled
    public static String getWebComponentList(){
        
        ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.queryMetadata(ToolingAPIService.SObjectType.LightningComponentBundle);
        return response.getBody();
    }
    @AuraEnabled
    public static String getWebComponent(String id){
        
        ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.queryWebBundle(id);
        return response.getBody();
    }
    
    
    @AuraEnabled
    public static string setWebComponent(String id,String sourceString){
        
        ToolingAPIService service=new ToolingAPIService();
        HttpResponse response=service.updateWebDefinition(sourceString,id);
        return response.getBody();
    }
}