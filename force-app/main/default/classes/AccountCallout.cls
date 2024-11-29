public class AccountCallout 
{
    public static void sendRecords(List<Account> accountJSON) 
    {
        String requestBody = JSON.serialize(accountJSON);
        String targetEndpoint = 'callout: TestCreds/services/apexrest/AccountInt';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(targetEndpoint);
        req.setMethod('POST');
       // req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');       
        System.debug('accountsJson====>' + requestBody);
        req.setBody(requestBody);
        System.debug(requestBody);
        
        // To fetch the response from the Source
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 200){
            System.debug('Error sending accounts: ' + res.getBody());
        }else {
            System.debug('Accounts sent successfully: ' +res.getBody());
        }

            }
}