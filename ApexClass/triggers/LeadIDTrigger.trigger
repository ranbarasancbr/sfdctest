/*********************************************************************************************************
*Component Name: LeadIDTrigger
*Description   : This Trigger updates the Company field when a record is created and also when the Lead Source is CSS Referral
*Developed By  : TEK Systems
**************************************************************************************************************/

trigger LeadIDTrigger on Lead (after insert, before insert) {
    List<Lead> UpdateLeadList = new List<Lead>();
    List<ID> refferalList = new List<ID>();
    if(trigger.isAfter){ 
        for(Lead objLead : Trigger.new){
            if(objLead.LeadSource == 'CSS Referral')
                refferalList.add(objLead.Id);    
        }
        if(!refferalList.isEmpty())
            AutoConvertLeads.LeadAssign(refferalList);
    }
   
}