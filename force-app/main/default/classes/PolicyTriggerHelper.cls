/*********************************************************
Apex Class Name    : PolicyTriggerHelper
Test Class Name    : 
Code Coverage      : 
@description       : This class is used to handle the trigger operation policy object 
@author            : Saurav Setia
*********************************************************
Modification Log:
<Version>   	<Date>             <Author Name>                <Brief description of change > 
1.0 -      		 		           Saurav Setia   			     Initial Creation                     

*********************************************************
*/
public class PolicyTriggerHelper 
{

    public static void BeforeInsert(List<Policy__c> newList) {}
    
    public static void BeforeUpdate(List<Policy__c> newList, Map<Id, Policy__c> oldMap) {}
    
    public static void BeforeDelete(List<Policy__c> oldList) {}
    
    public static void AfterInsert(List<Policy__c> newList) {}
    
    public static void AfterUpdate(List<Policy__c> newList, Map<Id, Policy__c> oldMap) {
        createAcknowledgementsForPolicy(newList, oldMap);
    }
    
    public static void AfterDelete(List<Policy__c> oldList) {}
    
    public static void AfterUndelete(List<Policy__c> newList) {}

    
    public static void createAcknowledgementsForPolicy(List<Policy__c> newPolicyList, Map<Id, Policy__c> oldPolicyMap)
    {
        List<Policy__c> policiesWithUpdatedURL = new List<Policy__c>();
        
        for(Policy__c policy : newPolicyList)
        {
            if(policy.Document_URL__c != oldPolicyMap.get(policy.Id).Document_URL__c)
            {
                policy.Version__c += 1;
                policiesWithUpdatedURL.add(policy);
            }
        }
        
        List<Policy_Acknowledgement__c> acknowledgementsList = new List<Policy_Acknowledgement__c>();
        
        List<User> users = [SELECT Id FROM User 
                            WHERE isActive = true 
                            AND isPortalEnabled = true];
        
        for(Policy__c policy : policiesWithUpdatedURL)
        {
            for(User user : users)
            {
                Policy_Acknowledgement__c ack = new Policy_Acknowledgement__c();
                ack.User__c = user.Id; 
                ack.Policy__c = policy.Id;
                ack.Version__c = policy.Version__c;
                acknowledgementsList.add(ack);
            }
        }
        insert acknowledgementsList;       
    }
}