Public class AutoConvertLeads
// auto convert leads based on the MQL score - Raj 3/14/2019 sfdctest
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
        LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(id currentlead: LeadIds){
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(currentlead);                
                Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
                MassLeadconvert.add(Leadconvert);
        }
        
        if (!MassLeadconvert.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
              //List<Database.LeadConvertResult> lcrs = Database.convertLead(MassLeadconvert, false);
        }
    }
}