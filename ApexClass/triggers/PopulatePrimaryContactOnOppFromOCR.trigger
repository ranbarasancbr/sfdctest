trigger PopulatePrimaryContactOnOppFromOCR on Opportunity (before update) { 

    // limit to 1000 entries in Set, scales by number of records up to 5000
    // Make list of Opp ids for query of OCR records

    Set<Id> OppIds = new Set<Id>();
    for (Opportunity o : Trigger.new) {
         OppIds.add(o.id);
    } 
    // Map of Opp id, related list of OCR ids
    // I used a map with a list of OCRs as you may want to have multiple Contacts listed on Opp, Primary Contact, Ship To Contact, etc 
    // so get them all and look for other conditions like role = xxx. If you just want Primary, SFDC ensure there is only 1 per Opp so you could 
    // make your map <Id, OpportunityContactRole> instead of the list. 

    Map<Id, List<OpportunityContactRole>> Opp_OCR = new Map<Id, List<OpportunityContactRole>>();

    // find all related OCRs to build Map 

    for (OpportunityContactRole ocr : [ Select id, contactid, Opportunityid, role, isprimary, createddate
                                        From OpportunityContactRole 
                                        Where opportunityid in :OppIds and isprimary = true]) { 
        
        // look for Oppid in master map 
        
        List<OpportunityContactRole> tmp_ocr = new List<OpportunityContactRole>();

        tmp_ocr = Opp_OCR.get(ocr.opportunityid);
        
        // if Oppid not already in map, add it with this new OCR record 

        if (tmp_ocr == null) { 
            Opp_OCR.put(ocr.opportunityid, new List<OpportunityContactRole>{ocr});
        } else { 
           // otherwise add this new OCR record to the existing list
           tmp_ocr.add(ocr);
           Opp_OCR.put(ocr.opportunityid, tmp_ocr);
        } 
    } 
    system.debug('Final OCR map: '+Opp_OCR);

    // for each Opp modified in the trigger, try to find relevant contacts

    for (Opportunity opps : Trigger.new) { 
        // temporary list of OCRs for this Opportunity populated from the master map 
        if(String.isBlank(opps.Online_Enrollment_Id__c)){
            List<OpportunityContactRole> this_OCR = new List<OpportunityContactRole>();
            this_OCR = Opp_OCR.get(opps.id);
            system.debug('this Opps ('+opps.id+') list of OCRs: '+this_OCR);
    
            // if no OCRs related, null out contact field(s) 
    
            if (this_OCR == null){
               opps.primary_contact__c = null;
            }
            else { 
                // cycle through all ocrs for this Opp and trap the various roles if you want 
    
                for (OpportunityContactRole r : this_OCR) { 
                    
                    //system.debug('cycling through the OCR list: '+r);
                    // if the role is primary, track this Contact id
                    
                    if (r.isprimary) opps.primary_contact__c = r.contactid;
                } // end for loop
    
            } // end if multiple OCRs for this Opp
        }
    } // end for loop of Opps 
 }