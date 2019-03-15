/************************************************************************************************************************************************************************************
*Component Name:OpportunityEnrollmentAlert
Description: Batch Job to send email to opportunity's primary contact.
Created By: Teksystems
***********************************************************************************************************************************************************************************************/

global class OpportunityEnrollmentAlert implements Database.Batchable<sObject>,Database.Stateful{
    global Map<id,String> reSendEmails = new Map<id,String>();//This variable holds contact Id as key and its email as value if emails not sent to contact 
    DateTime myDateTime = DateTime.newInstance(2013, 30, 1, 00, 00, 00);
    Date Date1 = Date.Today().addDays(14);
    Date Date2 = Date.Today().addDays(7);
    Date Systemtoday = system.today();
    global Database.Querylocator start(Database.BatchableContext BC){
        
        system.debug('What date====='+Date2);
        String query = 'SELECT Id, Name,Primary_Contact__c,Email_Address__c, Enrollment_Date__c, Storage_Date__c from Opportunity where (Section_1_Received__c = FALSE OR Section_2_Received__c = FALSE OR Section_3_Received__c = FALSE OR Section_4_Received__c = FALSE OR (Section_5_Received__c = FALSE AND Storage_Date__c >: myDateTime)) AND ((Enrollment_Date__c <: Systemtoday AND Storage_Date__c = NULL AND Due_Date__c =:Date1) OR (Enrollment_Date__c != NULL AND Storage_Date__c =:Date2))';      
        system.debug('query==========>>>>>>>'+query);
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('Inside execute method');
        system.debug('scope=====>>>>>'+scope);
        set<id> oppIdList = new set<id>();
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        Map<id,String> contactIdEmailMap = new Map<id,String>();//This map holds primary contact id as key and values as its email
        //Get Email Template 
        Id etId = [select id, Name from EmailTemplate where developername='Missing_Enrollment_Forms'].id;
        if(scope!=null || !scope.isEmpty()){
            for(Opportunity opp:scope){
                //Send email if primary contact field on opportunity is not null.
                if(String.isNotBlank(opp.Primary_Contact__c)){
                    
                    contactIdEmailMap.put(opp.Primary_Contact__c,opp.Email_Address__c);
                    List<String> emailAdd = new List<String>();
                    // Step 1: Create a new Email
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    // Step 2: Set list of people who should get the email primary contact's email is added to list
                    emailAdd.add(opp.Email_Address__c);
                    message.setToAddresses(emailAdd);
                    // Step 4. Set email contents - you can use variables!
                    message.setTargetObjectId(opp.Primary_Contact__c);
                    message.setTemplateId(etId);
                    mails.add(message); 
                }
            }
        }
        // Step 6: Send all emails in the master list
        results  = Messaging.sendEmail(mails);
        //Check Email sent results if for any failures. If email is not sent to any contact then add that target id to list contactIds.
        List<id> contactIds = new List<Id>();
        List<String> Errors = new List<String>();
        for(Messaging.SendEmailResult s:results){
            if(!s.isSuccess()){
                for(Messaging.SendEmailError e:s.getErrors()){
                    contactIds.add(e.targetobjectid);
                    Errors.add(e.getMessage());
                }
            }
        }
        system.debug('Errors==='+Errors);
        //Get emails of primary contacts to whom email is not sent to resend emails.
        if(!ContactIds.isEmpty() && !contactIdEmailMap.isEmpty()){
            for(Id conId:ContactIds){
                if(contactIdEmailMap.containsKey(conId)){
                    reSendEmails.put(conId,contactIdEmailMap.get(conId));
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
        //if email sending to a contact is failed then we resend email.
        if(reSendEmails!=null && !reSendEmails.isEmpty()){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Id etId = [select id, Name from EmailTemplate where developername='Missing_Enrollment_Forms'].id;
            for(Id conId:reSendEmails.keySet()){
                List<String> emailAdd = new List<String>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                emailAdd.add(reSendEmails.get(conId));
                message.setToAddresses(emailAdd);
                message.setTargetObjectId(conId);
                message.setTemplateId(etId);
                mails.add(message); 
            }
            Messaging.sendEmail(mails);
        }
    }
}