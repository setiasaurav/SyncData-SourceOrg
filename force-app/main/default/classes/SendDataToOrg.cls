public class SendDataToOrg 
{
    @future(callout=true)
    public static void sendRecordsToInsert(String requestBody) 
    {
        String targetEndpoint = 'callout:TestCreds/services/apexrest/RecordInsert';
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(targetEndpoint);
        req.setMethod('POST');
        req.setBody(requestBody);

        Http http = new Http();
        try 
        {
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) 
            {
                System.debug('Records sent successfully! Response: ' + res.getBody());
            } 
            else 
            {
                System.debug('Error sending records. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } 
        catch (Exception e) 
        {
            System.debug('Exception during HTTP callout: ' + e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void sendRecordsToUpdate(String requestBody) 
    {
        String targetEndpoint = 'callout:TestCreds/services/apexrest/RecordUpdate';
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(targetEndpoint);
        req.setMethod('POST');
        req.setBody(requestBody);

        Http http = new Http();
        try 
        {
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) 
            {
                System.debug('Records sent successfully! Response: ' + res.getBody());
            } 
            else 
            {
                System.debug('Error sending records. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } 
        catch (Exception e) 
        {
            System.debug('Exception during HTTP callout: ' + e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void sendRecordsToDelete(String requestBody) 
    {
        String targetEndpoint = 'callout:TestCreds/services/apexrest/RecordDelete';
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(targetEndpoint);
        req.setMethod('POST');
        req.setBody(requestBody);

        Http http = new Http();
        try 
        {
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) 
            {
                System.debug('Records sent successfully! Response: ' + res.getBody());
            } 
            else 
            {
                System.debug('Error sending records. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } 
        catch (Exception e) 
        {
            System.debug('Exception during HTTP callout: ' + e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void sendRecordsToUndelete(String requestBody) 
    {
        String targetEndpoint = 'callout:TestCreds/services/apexrest/RecordUndelete';
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(targetEndpoint);
        req.setMethod('POST');
        req.setBody(requestBody);

        Http http = new Http();
        try 
        {
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) 
            {
                System.debug('Records sent successfully! Response: ' + res.getBody());
            } 
            else 
            {
                System.debug('Error sending records. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
            }
        } 
        catch (Exception e) 
        {
            System.debug('Exception during HTTP callout: ' + e.getMessage());
        }
    }
}