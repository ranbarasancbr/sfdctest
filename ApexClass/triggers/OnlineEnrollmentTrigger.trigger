/***********************************************************************************************************************
*Component Name:OnlineEnrInsert
*Description: Trigger fires on after insert and after update of online enrollment records.
*Developed By: Tek Systems
************************************************************************************************************************/


trigger OnlineEnrollmentTrigger on Online_Enrollment__c (after insert,after update) {
    Set<id> idSet = new Set<id>();
    if(trigger.isAfter){
        if(trigger.isInsert){
            for(Online_Enrollment__c oe:trigger.new){
                idSet.add(oe.id);
            }
            if(idSet!=null && !idSet.IsEmpty()){
            AccountContactRelatedRecsInsert.AccountsAndRelatedRecordsInsert(idSet);
            }
        }
        
        if(trigger.isUpdate){
        //recursive.ContactOCR static boolean is used to avoid recursion
        if(!recursive.ContactOCR || !recursive.OpptyMergeOLEUpdate){
            UpdateSobjectOfOnlineEnroll.updateallrecords(trigger.newMap, trigger.oldMap);
            }
            else if(recursive.ContactOCR || recursive.OpptyMergeOLEUpdate){
            recursive.ContactOCR = false;
            recursive.OpptyMergeOLEUpdate = false;//This static boolean is used prevent after update OLE trigger to fire when ole is updated when opportunity is merged
            }
        }
    }
    
}