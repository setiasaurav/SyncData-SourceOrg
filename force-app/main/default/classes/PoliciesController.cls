public with sharing class PoliciesController {

    @AuraEnabled
    public static List<policyWrapper> getPolicies(String userId){
        System.debug('got id'+userId);
         List<Policy__c> policies= [SELECT Document_URL__c, (SELECT Id, user__r.Id, Acknowledge__c FROM Policy_Acknowledgements__r WHERE User__r.Id= :userId ORDER BY CreatedDate desc LIMIT 1),  Download_URL__c, Name FROM Policy__c];
         System.debug('policies'+policies);
         List<policyWrapper> policyWrappers= new List<policyWrapper>();
         for(Policy__c policy: policies){
            policyWrapper policyWrapper= new policyWrapper();
            policyWrapper.name= policy.Name;
            policyWrapper.previewUrl= policy.Document_URL__c;
            policyWrapper.downloadUrl= policy.Download_URL__c;
            if( policy.Policy_Acknowledgements__r.size()>0){
            policyWrapper.acknowledge= policy.Policy_Acknowledgements__r[0].Acknowledge__c;
            if(policyWrapper.acknowledge==true){
                policyWrapper.dynamicColor= 'background-color: #088756';
            }
            else{
                policyWrapper.dynamicColor= 'background-color: #ba0517';
            }
            policyWrapper.acknowledgeId= policy.Policy_Acknowledgements__r[0].Id;
            }
            policyWrappers.add(policyWrapper);
         }

         return policyWrappers;
    }


    public class policyWrapper{
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String previewUrl {get; set;}
        @AuraEnabled public String downloadUrl {get; set;}
        @AuraEnabled public Boolean acknowledge {get; set;}
        @AuraEnabled public String acknowledgeId {get; set;}
        @AuraEnabled public String dynamicColor {get; set;}
    }

    @AuraEnabled
    public static string updateAcknowledgement(String Id){
        try {
            List<Policy_Acknowledgement__c> policyAcknowledgeList= new List<Policy_Acknowledgement__c>();
            Policy_Acknowledgement__c policyAcknowledge= new Policy_Acknowledgement__c();
            policyAcknowledge.Id= Id;
            policyAcknowledge.Acknowledgement_Date__c= Date.today();
            policyAcknowledge.Acknowledge__c= true;
            policyAcknowledgeList.add(policyAcknowledge);
            update policyAcknowledgeList;
            return Id;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}