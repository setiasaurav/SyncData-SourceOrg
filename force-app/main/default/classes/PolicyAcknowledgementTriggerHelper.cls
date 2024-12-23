/*********************************************************
Apex Class Name    : PolicyAcknowledgementTriggerHelper
Test Class Name    : 
Code Coverage      : 
@description       : This class is used to handle the trigger operation policy acknowlegement object
@author            : Saurav Setia
*********************************************************
Modification Log:
<Version>   	<Date>             <Author Name>                <Brief description of change > 
1.0 -      		 		           Saurav Setia   			     Initial Creation : sendEmailToUsers                 

*********************************************************/
public class PolicyAcknowledgementTriggerHelper 
{
    public static void BeforeInsert(List<Policy_Acknowledgement__c> newList) {
        handleBeforeIteration(newList, null);
    }
    
    public static void BeforeUpdate(List<Policy_Acknowledgement__c> newList, Map<Id, Policy_Acknowledgement__c> oldMap) {
        handleBeforeIteration(newList, oldMap);
    }
    
    public static void BeforeDelete(List<Policy_Acknowledgement__c> oldList) {}
    
    public static void AfterInsert(List<Policy_Acknowledgement__c> newList) {
        sendAcknowledgementEmailToUsers(newList);
    }
    
    public static void AfterUpdate(List<Policy_Acknowledgement__c> newList, Map<Id, Policy_Acknowledgement__c> oldMap) {
        sendAcknowledgedEmailToUsers(newList, oldMap);
    }
    
    public static void AfterDelete(List<Policy_Acknowledgement__c> oldList) {}
    
    public static void AfterUndelete(List<Policy_Acknowledgement__c> newList) {}
    
    static void handleBeforeIteration(List<Policy_Acknowledgement__c> policyAcknowledgements, Map<Id,Policy_Acknowledgement__c> oldMap ){
        
        for(Policy_Acknowledgement__c policyAcknowledgement : policyAcknowledgements) {
            if (policyAcknowledgement.user__c != null &&( oldMap == null || policyAcknowledgement.user__c != oldMap.get(policyAcknowledgement.Id).user__c)) {
                policyAcknowledgement.ownerId = policyAcknowledgement.user__c;
            }
        }
    }
    
    public static void sendAcknowledgementEmailToUsers(List<Policy_Acknowledgement__c> policyAcknowledgements) 
    {
        Set<Id> userIds = new Set<Id>();
        Set<Id> policyIds = new Set<Id>();
        
        for (Policy_Acknowledgement__c ack : policyAcknowledgements) {
            userIds.add(ack.User__c);
            policyIds.add(ack.Policy__c);
        }
        
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Email, FirstName FROM User WHERE Id IN :userIds AND isActive = true AND isPortalEnabled = true
        ]);
        
        Map<Id, Policy__c> policyMap = new Map<Id, Policy__c>([
            SELECT Id, Name, Document_URL__c FROM Policy__c WHERE Id IN :policyIds
        ]);
        
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        Id orgWideEmailId = (orgWideEmail != null) ? orgWideEmail.Id : null;
        
        Map<Id, ContentDocumentLink> policyToContentDocumentMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> contentDocumentLinks = [SELECT LinkedEntityId, 
                                                          ContentDocument.LatestPublishedVersion.VersionData, 
                                                          ContentDocument.LatestPublishedVersion.Title, 
                                                          ContentDocument.LatestPublishedVersion.FileType
                                                          FROM ContentDocumentLink 
                                                          WHERE LinkedEntityId IN :policyIds
                                                          ORDER BY ContentDocument.CreatedDate ASC];
        
        for (ContentDocumentLink link : contentDocumentLinks) {
            policyToContentDocumentMap.put(link.LinkedEntityId, link);
        }
        
        EmailTemplate emailTemplate = [SELECT HtmlValue, Subject 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = 'Policy_Acknowledgement_Email_Template' 
                                       LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Policy_Acknowledgement__c ack : policyAcknowledgements) {
            User user = userMap.get(ack.User__c);
            Policy__c policy = policyMap.get(ack.Policy__c);
            ContentDocumentLink contentLink = policyToContentDocumentMap.get(ack.Policy__c);
            
            if (user != null && policy != null && contentLink != null) {
                String htmlBody = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('###UserName', user.FirstName != null ? user.FirstName : '');
                htmlBody = htmlBody.replace('###PolicyName', policy.Name);
                htmlBody = htmlBody.replace('###DocumentURL', policy.Document_URL__c != null ? policy.Document_URL__c : '#');
                String subject = emailTemplate.Subject.replace('###PolicyName', policy.Name); 
                
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(ack.user__c);
                email.setSubject(emailTemplate.Subject);
                email.setHtmlBody(htmlBody);
                
                if (orgWideEmailId != null) {
                    email.setOrgWideEmailAddressId(orgWideEmailId);
                }
                
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setFileName(contentLink.ContentDocument.LatestPublishedVersion.Title);
                emailAttachment.setBody(contentLink.ContentDocument.LatestPublishedVersion.VersionData);
                emailAttachment.setContentType(getMimeType(contentLink.ContentDocument.LatestPublishedVersion.FileType));
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                
                email.setSaveAsActivity(false);
                
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void sendAcknowledgedEmailToUsers(List<Policy_Acknowledgement__c> policyAcknowledgements, Map<Id, Policy_Acknowledgement__c> oldMap) 
    {
        List<Policy_Acknowledgement__c> acknowledgedPolicies = new List<Policy_Acknowledgement__c>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> policyIds = new Set<Id>();
        
        for(Policy_Acknowledgement__c ack : policyAcknowledgements)
        {
            if(ack.Acknowledge__c && ack.Acknowledge__c != oldMap.get(ack.Id).Acknowledge__c)
            {
                acknowledgedPolicies.add(ack);
                userIds.add(ack.User__c);
                policyIds.add(ack.Policy__c);
            }
        }
        
        if (acknowledgedPolicies.size() == 0) {
            return;
        }
        
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Email, FirstName FROM User WHERE Id IN :userIds AND isActive = true AND isPortalEnabled = true
        ]);
        
        Map<Id, Policy__c> policyMap = new Map<Id, Policy__c>([
            SELECT Id, Name, Download_URL__c, Document_URL__c FROM Policy__c WHERE Id IN :policyIds
        ]);
        
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        Id orgWideEmailId = (orgWideEmail != null) ? orgWideEmail.Id : null;
        
        EmailTemplate emailTemplate = [SELECT HtmlValue, Subject 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = 'Policy_Acknowledged_Email_Template' 
                                       LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Policy_Acknowledgement__c ack : policyAcknowledgements) 
        {
            User user = userMap.get(ack.User__c);
            Policy__c policy = policyMap.get(ack.Policy__c);
            
            if (user != null && policy != null) 
            {
                String htmlBody = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('###UserName', user.FirstName);
                htmlBody = htmlBody.replace('###PolicyName', policy.Name);
                
                String subject = emailTemplate.Subject.replace('###PolicyName', policy.Name);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(ack.user__c);
                email.setSaveAsActivity(false);
                email.setSubject(emailTemplate.Subject);
                email.setHtmlBody(htmlBody);
                
                if (orgWideEmailId != null) 
                {
                    email.setOrgWideEmailAddressId(orgWideEmailId);
                }
                
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) 
        {
            Messaging.sendEmail(emails);
        }
    }
    
    private static String getMimeType(String fileType) {
        Map<String, String> mimeTypeMap = new Map<String, String>{
            'PDF' => 'application/pdf',
                'DOC' => 'application/msword',
                'DOCX' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'XLS' => 'application/vnd.ms-excel',
                'XLSX' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'PNG' => 'image/png',
                'JPEG' => 'image/jpeg',
                'TXT' => 'text/plain'
                };
                    
                    return mimeTypeMap.get(fileType) != null ? mimeTypeMap.get(fileType) : 'application/octet-stream';
    }
    
    @InvocableMethod
    public static void sendAcknowledgementReminderToUsers(List<String> policyAcknowledgementIds)
    {
        Set<Id> userIds = new Set<Id>();
        Set<Id> policyIds = new Set<Id>();
        
        List<Policy_Acknowledgement__c> policyAcknowledgements = [SELECT Id, Acknowledge__c, User__c, Policy__c 
                                                                  FROM Policy_Acknowledgement__c 
                                                                  WHERE Id IN :policyAcknowledgementIds
                                                                  AND Acknowledge__c = false];
        
        for (Policy_Acknowledgement__c ack : policyAcknowledgements) {
            userIds.add(ack.User__c);
            policyIds.add(ack.Policy__c);
        }
        
        
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Email, FirstName FROM User WHERE Id IN :userIds
        ]);
        
        System.debug(userMap);
        
        Map<Id, Policy__c> policyMap = new Map<Id, Policy__c>([
            SELECT Id, Name, Document_URL__c FROM Policy__c WHERE Id IN :policyIds
        ]);
        
        
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        Id orgWideEmailId = (orgWideEmail != null) ? orgWideEmail.Id : null;
        
        Map<Id, ContentDocumentLink> policyToContentDocumentMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> contentDocumentLinks = [SELECT LinkedEntityId, 
                                                          ContentDocument.LatestPublishedVersion.VersionData, 
                                                          ContentDocument.LatestPublishedVersion.Title, 
                                                          ContentDocument.LatestPublishedVersion.FileType
                                                          FROM ContentDocumentLink 
                                                          WHERE LinkedEntityId IN :policyIds
                                                          ORDER BY ContentDocument.CreatedDate ASC];
        
        for (ContentDocumentLink link : contentDocumentLinks) {
            policyToContentDocumentMap.put(link.LinkedEntityId, link);
        }
        
        EmailTemplate emailTemplate = [SELECT HtmlValue, Subject 
                                       FROM EmailTemplate 
                                       WHERE DeveloperName = 'Policy_Acknowledgement_Reminder_Template' 
                                       LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Policy_Acknowledgement__c ack : policyAcknowledgements) {
            System.debug('Looooooop');
            User user = userMap.get(ack.User__c);
            Policy__c policy = policyMap.get(ack.Policy__c);
            ContentDocumentLink contentLink = policyToContentDocumentMap.get(ack.Policy__c);
            
            if (user != null && policy != null && contentLink != null) {
                System.debug('iffffffffff');
                String htmlBody = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('###UserName', user.FirstName != null ? user.FirstName : '');
                htmlBody = htmlBody.replace('###PolicyName', policy.Name);
                htmlBody = htmlBody.replace('###DocumentURL', policy.Document_URL__c != null ? policy.Document_URL__c : '#');
                String subject = emailTemplate.Subject.replace('###PolicyName', policy.Name); 
                
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(ack.user__c);
                email.setSubject(emailTemplate.Subject);
                email.setHtmlBody(htmlBody);
                
                if (orgWideEmailId != null) {
                    email.setOrgWideEmailAddressId(orgWideEmailId);
                }
                
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setFileName(contentLink.ContentDocument.LatestPublishedVersion.Title);
                emailAttachment.setBody(contentLink.ContentDocument.LatestPublishedVersion.VersionData);
                emailAttachment.setContentType(getMimeType(contentLink.ContentDocument.LatestPublishedVersion.FileType));
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                
                email.setSaveAsActivity(false);
                
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}