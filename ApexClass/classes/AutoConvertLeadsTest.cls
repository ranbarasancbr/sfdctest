@isTest
public class AutoConvertLeadsTest {
    
    static testMethod void convertLead(){
        test.startTest();
        Lead leadRec = new Lead();
        leadRec.FirstName='tek lead';
        leadRec.LastName='lead for test';
        leadRec.LeadSource='CSS Referral';
        leadRec.Phone = '1234568901';
        leadRec.Email='abc@test12gmail.com';
        leadRec.Due_Date__c = system.today().addDays(3);
        leadRec.OwnerId = UserInfo.getUserId();
        leadRec.Status = 'Qualified';
        insert leadRec;
        test.stopTest();
       // Lead leead = [Select id,LeadSource from Lead where LeadSource = 'CSS Refferal'];
       // AutoConvertLeads.LeadAssign(leead.Id);
        
        
    } 
    
}