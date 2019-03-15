/********************************************************************************************************************************************************
* Component Name: OLEUpdateFromContact
* Description   : This class contains logic to update OLE when OlE's Primary contact's street address,City, Country, State, ZipCode, PhoneNumber, Date of Birth, 
                  Identification Type, Identification Id fields are updated.
* Developed By  : TEK Systems
****************************************************************************************************************************************************/
public class OLEUpdateFromContact{
    //This Method is calling from MarketoSync Trigger
    public static void UpdateOLEOnContactUpdate(Map<id,Contact> newconMap, Map<id,Contact> oldconMap){
        Map<id,Contact> ContactMap = new Map<id,Contact>();//Queried Contacts are stored in this map
        Map<id,Online_Enrollment__c> OLEMap = new Map<id,Online_Enrollment__c>();//Queried Online enrollment records are added to this map
        Set<id> contactIds = new Set<id>();//Contact Ids are added to this set to use this set in querying Contact records
        Set<id> OLEIds = new Set<id>();//OLE ids are added to this set to use this set in querying Online enrollment records
        List<Online_Enrollment__c> OLEListToUpdate = new List<Online_Enrollment__c>();//OLEs that are updating are added to this List
        system.debug('newconMap======'+newconMap.values());
        //If one or more fields on Online Enrollment's Primary contact are updated then add contact ids to set- contactIds and OLE ids to Set - OLEIds. This Sets with ids are used to query on contact object and online enrollment.
        if(newconMap!=null && !newconMap.isEmpty()){
            system.debug('inside if condition');
            for(Contact c:newconMap.values()){
                system.debug('c.Online_Enrollment__c----'+c.Online_Enrollment__c);
                system.debug('c.FirstName==='+c.FirstName);
                
                if(String.isNotBlank(c.Online_Enrollment__c) && c.Opportunity_Status__c=='Open' && String.isNotBlank(c.ID_Type__c) && (c.Birthdate != oldconMap.get(c.id).Birthdate || c.ID_Type__c != oldconMap.get(c.id).ID_Type__c || c.ID_Information__c != oldconMap.get(c.id).ID_Information__c || c.Phone != oldconMap.get(c.id).Phone || c.MailingStreet != oldconMap.get(c.id).MailingStreet || c.MailingCity  != oldconMap.get(c.id).MailingCity  || c.MailingState != oldconMap.get(c.id).MailingState || c.MailingPostalCode != oldconMap.get(c.id).MailingPostalCode )){
                    contactIds.add(c.id);//Adding Contact Id to set
                    OLEIds.add(c.Online_Enrollment__c);//Adding OLE id to set
                }
            }
            
        }
        system.debug('contactIds======='+contactIds);
        system.debug('OLEIds====='+OLEIds);
        //If Set i.e contactIds is not null query on contact to get contact records with required fields and also query on OLE with fields which are updating.
        if(contactIds!=null && !contactIds.isEmpty()){
            ContactMap = new Map<id,Contact>([select id,ID_Type__c,Birthdate,Online_Enrollment__c,Opportunity_Status__c,ID_Information__c,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode from contact where Id IN:contactIds]);
            OLEMap = new Map<id,Online_Enrollment__c>([select id,Primary_Contact_Id__c,Primary_Address__c,Primary_City__c,Primary_State__c,Primary_Zipcode__c,Birth_Date_of_Primary__c,Primary_Home_Phone__c,Primary_ID_Type__c,PrimaryID__c from Online_Enrollment__c where Id IN:OLEIds]);
        }
        system.debug('ContactMap'+ContactMap);
        system.debug('OLEMap'+OLEMap);
        //If above Maps are not null then check if which following fields address,City, Country, State, ZipCode, PhoneNumber, Date of Birth,Identification Type, Identification Id fields are updated on contact to update related fields on online enrollment.
        if(ContactMap!=null && !ContactMap.isEmpty() && OLEMap!=null && !OLEMap.isEmpty()){
            for(Online_Enrollment__c ole:OLEMap.values()){
                system.debug('ole.Primary_Contact_Id__c'+ole.Primary_Contact_Id__c);
                if(ContactMap.containsKey(ole.Primary_Contact_Id__c)){//Check if queried map contains OLE's primary contact 
                    Contact c = ContactMap.get(ole.Primary_Contact_Id__c);
                    //If Id Type is updated on contact then update Primary ID Type field on OLE
                    if(c.ID_Type__c != ole.Primary_ID_Type__c){
                        ole.Primary_ID_Type__c = c.ID_Type__c;
                    }
                    //If contact's ID_Information__c is updated update PrimaryID__c on OLE
                    if(c.ID_Information__c != ole.PrimaryID__c){
                        ole.PrimaryID__c = c.ID_Information__c;
                    }
                    //If Conttact's BirthDate is updated then update Birth_Date_of_Primary__c of OLE
                    if(c.BirthDate != ole.Birth_Date_of_Primary__c){
                        ole.Birth_Date_of_Primary__c = c.BirthDate;
                    }
                    //If contact's Phone is updated then update OLE's Primary_Home_Phone__c
                    if(c.Phone != ole.Primary_Home_Phone__c){
                        ole.Primary_Home_Phone__c = c.Phone;
                    }
                    //If Contact's Street Address is updated then update OLE's Primary_Address__c
                    if(c.MailingStreet != ole.Primary_Address__c){
                        ole.Primary_Address__c = c.MailingStreet;
                    }
                    //If Contact's State is updated then update OLE's Primary_State__c
                    if(c.MailingState != ole.Primary_State__c){
                        ole.Primary_State__c = c.MailingState;
                    }
                    //If Contact's City  is updated then update OLE's Primary_City__c
                    if(c.MailingCity != ole.Primary_City__c){
                        ole.Primary_City__c = c.MailingCity;
                    }
                    //If Contact's ZipCode is updated then update OLE's Primary_Zipcode__c
                    if(c.MailingPostalCode != ole.Primary_Zipcode__c){
                        ole.Primary_Zipcode__c = c.MailingPostalCode;
                    }
                    
                }
                OLEListToUpdate.add(ole);//Add Ole to List
            }//OLE For loop close
        }
        system.debug('OLEListToUpdate'+OLEListToUpdate);
        list<Database.SaveResult> oleSaveResult = new List<DataBase.SaveResult>();
        if(OLEListToUpdate!=null && !OLEListToUpdate.isEmpty()){
            //Update Ole list if list is not empty
            recursive.ContactOCR = true;
            oleSaveResult = DataBase.update(OLEListToUpdate,false);
        }
        
    }
   
}