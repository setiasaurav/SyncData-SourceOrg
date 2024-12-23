/*********************************************************
Apex Class Name    : ContentDocumentLinkTriggerHelper
Test Class Name    : 
Code Coverage      : 
@description       : This class is used to handle the trigger operation Content Document Link object
@author            : Saurav Setia
**********************************************************
Modification Log:
<Version>   	<Date>             <Author Name>                <Brief description of change > 
1.0 -      		 		            Saurav Setia   			     Initial Creation : urlCreationForPolicy                   

*********************************************************/
public class ContentDocumentLinkTriggerHelper 
{
    //This method create public and download URL for the uploaded document in the policy object
    public static void urlCreationForPolicy(List<ContentDocumentLink> contentDocumentLinkList)
    {        
        List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();   
        
        Map<Id, Id> contentDocumentIDToLinkedEntityIDMap = new Map<Id, Id>();
        
        for (ContentDocumentLink cdl : contentDocumentLinkList) 
        {
            if (cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType() == Policy__c.SObjectType) 
            {
                contentDocumentIDToLinkedEntityIDMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
        }
        
        Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>([
            SELECT Id, LatestPublishedVersionId, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIDToLinkedEntityIDMap.keySet()
        ]);
        
        Map<Id,List<String>> recordIdToPublicUrl = new Map<Id, List<String>>();
        
        for (ContentDocumentLink cdl : contentDocumentLinkList) 
        {
            ContentDocument contentDocument = contentDocumentMap.get(cdl.ContentDocumentId);
            
            if (contentDocument != null) 
            {         
                ContentDistribution contentDistribution = new ContentDistribution(
                    Name = 'Public URL for ' + contentDocument.Title,
                    ContentVersionId = contentDocument.LatestPublishedVersionId,
                    PreferencesAllowViewInBrowser = true,
                    PreferencesAllowOriginalDownload = true,
                    PreferencesNotifyOnVisit = false
                );                    
                distributionsToInsert.add(contentDistribution);
            }
        }
        
        if (!distributionsToInsert.isEmpty()) 
        {
            insert distributionsToInsert;
            System.debug('Public URLs created successfully.');
            List<ContentDistribution> distributionInserted = [SELECT ID, ContentDocumentId, DistributionPublicUrl, ContentVersionId, ContentDownloadUrl 
                                                              FROM ContentDistribution 
                                                              WHERE Id in :distributionsToInsert];
            
            for (ContentDistribution distribution : distributionInserted) 
            {
                List<String> linksList = new List<String>{distribution.DistributionPublicUrl, distribution.ContentDownloadUrl};
                recordIdToPublicUrl.put(distribution.ContentDocumentId, linksList);
            }
            
            List<Policy__c> policyToUpdate = new List<Policy__c>();
            
            for (Id contentDocumentID : recordIdToPublicUrl.keySet()) 
            {
                if (!recordIdToPublicUrl.get(contentDocumentId).isEmpty()) 
                {
                    Policy__c policy = new Policy__c();
                    policy.Id = contentDocumentIDToLinkedEntityIDMap.get(contentDocumentId);
                    policy.Document_URL__c = recordIdToPublicUrl.get(contentDocumentId)[0];
                    policy.Download_URL__c = recordIdToPublicUrl.get(contentDocumentId)[1];
                    policyToUpdate.add(policy);                
                }
            }   
            
            if (!policyToUpdate.isEmpty()) 
            {
                update policyToUpdate;
                System.debug('Records updated with public URLs successfully.');
            }            
        }
    }
}