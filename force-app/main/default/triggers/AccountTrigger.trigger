trigger AccountTrigger on Account (before insert, after insert, after update, after delete, after undelete) 
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
        
        if(Trigger.isDelete)
        {
            String recordList = JSON.serialize(Trigger.old);
            SendDataToOrg.sendRecordsToDelete(recordList);
        }
        if(Trigger.isUndelete)
        {
            String recordList = JSON.serialize(Trigger.new);
            SendDataToOrg.sendRecordsToUndelete(recordList);
        }
    }
}