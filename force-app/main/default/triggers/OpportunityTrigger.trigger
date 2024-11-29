trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            String recordList = JSON.serialize(Trigger.new);
            SendDataToOrg.sendRecordsToInsert(recordList);
        }
        
        if(Trigger.isUpdate)
        {
            String recordList = JSON.serialize(Trigger.new);
            SendDataToOrg.sendRecordsToUpdate(recordList);
        }
    }
}