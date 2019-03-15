public with sharing class ContactUpdate {
    public static void ContactZipUpdate(List<Contact> nc){
      set<string> czips = new set<string>(); 
      for (contact c: nc) {
          if (c.mailingpostalcode != null && c.mailingcountrycode == 'US') {
              czips.add(c.mailingpostalcode.substring(0,5));
          }
      }
        //Query for the US Zipcode 
       map<string,string> zipMap=new map<string,string>(); 
      for(US_Zipcode__c z : [Select name, city__c, state__c, time_zone__c from US_Zipcode__c WHERE name IN :czips]) {
          zipMap.put ( 'City', z.city__c);
            zipMap.put ( 'Timezone', z.time_zone__c);
            zipMap.put ( z.name, z.state__c);
       }
    //Update contact with City and Zipcode
      for (contact c: nc) {
          if(c.mailingpostalcode != null && c.mailingcountrycode == 'US') {
              String zip = zipMap.get(c.mailingpostalcode.substring(0,5));
              if (zip != null) {
                   c.mailingcity = zipMap.get('City');
                    c.timezone__c = zipMap.get('Timezone');
                    c.mailingstatecode = zip;
              }
                else{
                    //c.addError('Please provide a valid US Zipcode');
                }

          }
          if (c.mailingcity == null){
              c.mailingcity = '';
          }
            if (c.mailingstate == null ){
                c.mailingstate = '';
          }
            if (c.timezone__c == null ){
                c.timezone__c = '';
          }            
      }
    }
}