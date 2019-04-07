public class ToolingAPIService {
    private final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm();
    private final String TOOLING_API_URI = '/services/data/v45.0/tooling' ;
    private final String SESSION_ID{
        private set;get{
            if(Test.isRunningTest()){
                return '';
            }
            
            PageReference visualforcePage=Page.generateSessionId;
            String content = visualforcePage.getContent().toString();
            Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
            return content.substring(s, e);
        }
    }
    private Http http;
    public ToolingAPIService(){
        http=new Http();
    }
    public enum SObjectType { ApexClass,ApexPage,AuraDefinitionBundle,AuraDefinition,LightningComponentBundle,LightningComponentResource}
    public HttpResponse queryAuraBundle(String bundleId){
        bundleId=String.escapeSingleQuotes(bundleId);
        HttpRequest request=createHttpRequest('GET');
        String queryFields=genrateSearchQuery(SObjectType.AuraDefinition);
        queryFields+=' WHERE AuraDefinitionBundleId=\''+bundleId+'\'';
        String query='/query/?q=' + EncodingUtil.urlEncode(queryFields, 'UTF-8');
        request.setEndpoint(BASE_URL+TOOLING_API_URI+query);
        return sendRequest(request);
    }
    public HttpResponse queryWebBundle(String bundleId){
        bundleId=String.escapeSingleQuotes(bundleId);
        HttpRequest request=createHttpRequest('GET');
        String queryFields=genrateSearchQuery(SObjectType.LightningComponentResource);
        queryFields+=' WHERE LightningComponentBundleId=\''+bundleId+'\'';
        String query='/query/?q=' + EncodingUtil.urlEncode(queryFields, 'UTF-8');
        request.setEndpoint(BASE_URL+TOOLING_API_URI+query);
        return sendRequest(request);
    }
    public HttpResponse queryMetadata(SObjectType metaType){
        HttpRequest request=createHttpRequest('GET');
        String queryFields=genrateSearchQuery(metaType);
        String query='/query/?q=' + EncodingUtil.urlEncode(queryFields+' WHERE masterLabel!=\'viewweb\'  ORDER By LastModifiedDate Desc', 'UTF-8');//
        request.setEndpoint(BASE_URL+TOOLING_API_URI+query);
        return sendRequest(request);
        
    }
    public HttpResponse updateAuraDefinition(String body,string id){
        HttpRequest request=createHttpRequest('POST');
        request.setBody('{"source":'+body+'}');
        request.setEndpoint(BASE_URL+TOOLING_API_URI+'/sobjects/AuraDefinition/'+id+'?_HttpMethod=PATCH');
        return sendRequest(request);
    }
    public HttpResponse updateWebDefinition(String body,string id){
        HttpRequest request=createHttpRequest('POST');
        request.setBody('{"source":'+body+'}');
        request.setEndpoint(BASE_URL+TOOLING_API_URI+'/sobjects/LightningComponentResource/'+id+'?_HttpMethod=PATCH');
        return sendRequest(request);
    }
    public String createWebComponent(String fileName,Boolean isRecordPage,Boolean ishomePage,Boolean isallPage){
        HttpRequest request=createHttpRequest('POST');
        String body='{"FullName" : "'+fileName+'","Metadata" : {"masterLabel" : "'+fileName+'"}}';
        request.setEndpoint(BASE_URL+TOOLING_API_URI+'/sobjects/LightningComponentBundle');
        request.setBody(body);
        HttpResponse response=sendRequest(request);
        system.debug('KING 1'+response.getStatusCode());
        system.debug('KING 1'+response.getBody());
        if(response.getStatusCode()==201){
            
            map<String,object> idMap=(map<String,object>) JSON.deserializeUntyped(response.getBody());
            String id=(String) idMap.get('id');
            System.debug('id'+id);
            createjsComponent(id,fileName);
            createhtmlComponent(id,fileName);
            createxmlComponent(id,fileName,isallPage,ishomePage,isRecordPage);
            return 'true';
        }
        return response.getBody();
        
    }
    
    private void createjsComponent(String id,String filename){
        HttpRequest request=createHttpRequest('POST');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        
        gen.writeStringField('LightningComponentBundleId', id);
        gen.writeStringField('FilePath', 'lwc/'+filename+'/'+filename+'.js');
        gen.writeStringField('Format', 'js');
        gen.writeStringField('Source', 'import { LightningElement } from \'lwc\';\nexport default class '+filename+' extends LightningElement {\n}');
        gen.writeEndObject();
        request.setEndpoint(BASE_URL+TOOLING_API_URI+'/sobjects/LightningComponentResource');
        request.setBody(gen.getAsString());
        HttpResponse response=sendRequest(request);
        System.debug('KING 2'+response.getBody());
        System.debug('KING 2'+response.getStatusCode());
    }
    private void createhtmlComponent(String id,String filename){
        HttpRequest request=createHttpRequest('POST');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('LightningComponentBundleId', id);
        gen.writeStringField('FilePath', 'lwc/'+filename+'/'+filename+'.html');
        gen.writeStringField('Format', 'html');
        gen.writeStringField('Source', '<template></template>');
        gen.writeEndObject();
        request.setEndpoint(BASE_URL+TOOLING_API_URI+'/sobjects/LightningComponentResource');
        request.setBody(gen.getAsString());
        HttpResponse response=sendRequest(request);
        System.debug('KING 3'+response.getBody());
        System.debug('KING 3'+response.getStatusCode());
    }
    private void createxmlComponent(String id,String filename,Boolean a,Boolean b,Boolean c){
        HttpRequest request=createHttpRequest('POST');
         JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('LightningComponentBundleId', id);
        gen.writeStringField('FilePath', 'lwc/'+filename+'/'+filename+'.js-meta.xml');
        gen.writeStringField('Format', 'js');
        String s='<?xml version="1.0" encoding="UTF-8"?>\n<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata" fqn="'+filename+'">\n<apiVersion>45.0</apiVersion><isExposed>true</isExposed>\n';
        
        
        if(a||b||c){
            s+='<targets>\n';
        }
        
        if(a){
            s+='<target>lightning__AppPage</target>\n';
        }
        if(b){
            s+='<target>lightning__HomePage</target>\n';
        }
        if(c){
            s+='<target>lightning__RecordPage</target>\n';  
        }
        
        if(a||b||c){
            s+='</targets>\n';
        }
        
        s+='</LightningComponentBundle>';
        
        gen.writeStringField('Source',s);
        gen.writeEndObject();
        request.setEndpoint(BASE_URL+TOOLING_API_URI+'/sobjects/LightningComponentResource');
        request.setBody(gen.getAsString());
        HttpResponse response=sendRequest(request);
         System.debug('KING 4'+response.getBody());
        System.debug('KING 4'+response.getStatusCode());
    }
    
    private String genrateSearchQuery(SObjectType metaType){
        String queryFields=queryfieldsList.get(metaType);
        return 'SELECT '+queryFields+' FROM '+metaType;
    }
    private HttpResponse sendRequest(HttpRequest request){
        return http.send(request);
    }
    private HttpRequest createHttpRequest(String requestType){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod(requestType);
        return request;
    }
    public static Map<String,SObjectType> getENUMforString=new  Map<String,SObjectType>{
        'ApexClass'=>SObjectType.ApexClass,
            'ApexPage'=>SObjectType.ApexPage,
            'AuraDefinition'=>SObjectType.AuraDefinition,
            'AuraDefinitionBundle'=>SObjectType.AuraDefinitionBundle,
            'LightningComponentBundle'=>SObjectType.LightningComponentBundle,
            'LightningComponentResource'=>SObjectType.LightningComponentResource
            };
                private static Map<SObjectType,String> queryfieldsList=new Map<SObjectType,String>{
                    SObjectType.ApexClass => 'Id,Name,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,Body',
                        SObjectType.ApexPage  =>'Id,Name,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,Markup',
                        SObjectType.AuraDefinitionBundle  =>'DeveloperName,MasterLabel,LastModifiedDate, LastModifiedById,LastModifiedBy.Name,Id',
                        SObjectType.AuraDefinition  =>'Id,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,AuraDefinitionBundleId,DefType,Format,Source',
                        SObjectType.LightningComponentBundle  =>'description,masterLabel,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,Id',
                        SObjectType.LightningComponentResource  =>'Id,FilePath,LastModifiedDate,LastModifiedById,LastModifiedBy.Name,Format,LightningComponentBundleId,Source'
                        };
                            }