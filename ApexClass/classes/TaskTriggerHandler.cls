public class TaskTriggerHandler {
    public static void handleAfterInsert(List<Task> TaskList)
    {
        //handler logic
        date myDate = date.today();
        List<Id> leadids = new List<Id>();
        List<Id> optyids = new List<Id>();
        List<lead> leadstoupdate = new List<lead>();
        List<lead> leadstoupdate1 = new List<lead>();
        List<Opportunity> Optystoupdate = new List<Opportunity>();
        for(Task tsk : (List <Task>) Trigger.new){
        leadids.add(tsk.WhoId);
        optyids.add(tsk.WhatId);
        }  
        Map<id,lead> leadMap = new Map<id,lead>([select id, Total_Email_Outbound__c from lead where id IN :leadids]);
        Map<id,lead> leadLTDate = new Map<id,lead>([select id, Last_Contact_Date__c from lead where id IN :leadids]);
        Map<id,Opportunity> OptyLTDate = new Map<id,Opportunity>([select id, Last_Contact_Date__c from Opportunity where id IN :optyids]);
    for (lead acc: [select Id, Name, Total_Email_Outbound__c,(select id,ActivityDate from tasks Where TaskSubtype  = 'Email' AND Status = 'Completed' ) from lead where Id IN :leadids]) {
        for(task t: acc.tasks){
                        leadMap.get(acc.Id).Total_Email_Outbound__c = acc.tasks.size();
        }
        leadstoupdate.add(leadMap.get(acc.Id));
    }

update leadstoupdate;
    
for (lead acc1: [select Id, Name, Last_Contact_Date__c,(select id,ActivityDate from tasks Where Status = 'Completed' AND LastModifiedDate = Today) from lead where Id IN :leadids]) {
        for(task t1: acc1.tasks){
                        leadLTDate.get(acc1.Id).Last_Contact_Date__c = myDate;
        }
        leadstoupdate1.add(leadLTDate.get(acc1.Id));
    }

update leadstoupdate1;

for (Opportunity Opty1: [select Id, Name, Last_Contact_Date__c,(select id,ActivityDate from tasks Where Status = 'Completed' AND LastModifiedDate = Today) from Opportunity where Id IN :optyids and Status__c = 'Open' ]) {
        for(task t2: Opty1.tasks){
                        OptyLTDate.get(Opty1.Id).Last_Contact_Date__c = myDate;
        }
        Optystoupdate.add(OptyLTDate.get(Opty1.Id));
    }

update Optystoupdate;
    }
    
}