//US Zipcode - check US Zipcode list for City and State
public with sharing class LeadUpdate {
    public static void LeadZipUpdate(List<Lead> nl){
    	set<string> lzips = new set<string>(); 
    	for (lead l: nl) {
        	if (l.postalcode != null && l.countrycode == 'US') {
            	lzips.add(l.postalcode.substring(0,5));
        	}
    	}
        //Query for the US Zipcode
   		map<string,string> zipMap=new map<string,string>(); 
    	for(US_Zipcode__c z : [Select name, city__c, state__c, time_zone__c from US_Zipcode__c WHERE name IN :lzips]) {
        	zipMap.put ( 'City', z.city__c);
            zipMap.put ( 'Timezone', z.time_zone__c);
            zipMap.put ( z.name, z.state__c);
     	}
		//Update lead with City and Zipcode
    	for (lead l: nl) {
        	if(l.postalcode != null && l.countrycode == 'US') {
            	String zip = zipMap.get(l.postalcode.substring(0,5));
            	if (zip != null) {
                	//l.city = zip;
                	l.city = zipMap.get('City');
					l.timezone__c = zipMap.get('Timezone');
                    l.statecode = zip;
            	}
                else{
                    l.addError('Please provide a valid US Zipcode');
                }

        	}
        	if (l.city == null ){
            	l.city = '';
        	}
        	if (l.state == null ){
                l.state = '';
        	}   
        	if (l.timezone__c == null){
                l.timezone__c = '';
        	}                        
    	}
    }
}