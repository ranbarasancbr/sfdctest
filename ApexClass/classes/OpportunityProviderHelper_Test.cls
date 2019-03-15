/*
* This is a test class for OpportunityProviderHelper
* Created By: Tek Systems
*/
@isTest
private class OpportunityProviderHelper_Test {
    /*@isTest static void testRule() {
        Opportunity opp = new Opportunity();
        try{
   
        test.startTest();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Facility__c facility = new Facility__c (Address__c  = 'Test Address',City__c = 'Newyork', Facility_Name__c = 'test');
        insert facility;
        
        
        opp.Name = 'Test';
        opp.AccountId = acc.id;
        opp.StageName = 'Qualification';
        opp.CloseDate = system.today();
        opp.Adoption_Type__c = 'Closed';
        opp.Payment_Method__c = 'Credit Card';
        opp.of_Babies__c = 'single';
        opp.of_CB__c = '1';
        opp.of_CT__c = '0';
        opp.Due_Date__c = system.today().addDays(15);
        opp.Delivering_Hospital__c = facility.id;
        insert opp;
        
        Provider__c pro = new Provider__c(Address__c = 'Test address', city__c = 'Newyork', State__c = 'NY',
                                          Provider_First_Name__c  = 'Test',Provider_Last_Name__c = 'Provider');
        insert pro;
        
        Opportunity_Provider__c oppProvider = new Opportunity_Provider__c(Opportunity__c = opp.id,Provider__c = pro.id,
                                              Delivering_Provider__c = true,Primary_Provider__c = false);
        insert oppProvider;
            
        Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c(Opportunity__c = opp.id,Provider__c = pro.id,
                                               Delivering_Provider__c = true,Primary_Provider__c = false);
        insert oppProvider2;
        //pro.Opportunity_Provider__c  =
        test.stopTest();
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
    }*/
    @isTest static void testRuleUpdate() {
        Opportunity opp = new Opportunity();
        Provider__c pro; Provider__c objpro;
         Opportunity objopp = new Opportunity();
        try{
            test.startTest();
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            Facility__c facility = new Facility__c (Address__c  = 'Test Address',City__c = 'Newyork',Facility_Name__c = 'test');
            insert facility;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
            pro = new Provider__c(Address__c = 'Test address',city__c = 'Newyork',State__c = 'NY',
                                  Provider_First_Name__c  = 'Test',Provider_Last_Name__c = 'Provider');
            insert pro;
            
            objpro = new Provider__c(Address__c = 'Test address',city__c = 'Newyork',State__c = 'NY',
                                  Provider_First_Name__c  = 'Test',Provider_Last_Name__c = 'Provider');
            insert objpro;
            
            objopp.Name = 'Test';
            objopp.AccountId = acc.id;
            objopp.StageName = 'Qualification';
            objopp.CloseDate = system.today();
            objopp.Adoption_Type__c = 'Closed';
            objopp.Payment_Method__c = 'Credit Card';
            objopp.of_Babies__c = 'single';
            objopp.of_CB__c = '1';
            objopp.of_CT__c = '0';
            objopp.Due_Date__c = system.today().addDays(15);
            objopp.Delivering_Hospital__c = facilitY.id;
            insert objopp;

            Opportunity_Provider__c oppProvider = new Opportunity_Provider__c(Opportunity__c = opp.id,
                                     Provider__c = pro.id,Delivering_Provider__c = true,Primary_Provider__c = true);
            insert oppProvider;
            
            oppProvider.Opportunity__c = objopp.id;
            oppProvider.Provider__c = objpro.id;
            oppProvider.Primary_Provider__c = false;
            update oppProvider;
             
            oppProvider.Provider__c = objpro.id;
            oppProvider.Primary_Provider__c = true;
            oppProvider.Delivering_Provider__c = true;
            update oppProvider;

            /*
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c(Opportunity__c = opp.id,Provider__c = pro.id,
                                                   Delivering_Provider__c = true,Primary_Provider__c = true);
            insert oppProvider2;
            
            oppProvider2.Opportunity__c = objopp.id;
            oppProvider2.Primary_Provider__c = false;
            update oppProvider2;
            
           */
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
        try{
            Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = objopp.id;
            oppProvider3.Provider__c = pro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = true;
            
            insert oppProvider3;
        }catch(Exception e){}
        
        Opportunity_Provider__c oppProvider4 = new Opportunity_Provider__c();
        oppProvider4.Opportunity__c = objopp.id;
        oppProvider4.Provider__c = objpro.id;
        oppProvider4.Delivering_Provider__c = true; 
        oppProvider4.Primary_Provider__c = false;
        try{
        insert oppProvider4;
        }catch(Exception e){}
        
        test.stopTest();
    }
    @isTest static void testRule2() {
        Opportunity opp = new Opportunity();
        try{
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
            Provider__c pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objpro = new Provider__c();
            objpro.Address__c = 'Test address';
            objpro.city__c = 'Newyork';
            objpro.State__c = 'NY';
            objpro.Provider_First_Name__c  = 'Test';
            objpro.Provider_Last_Name__c = 'Provider';
            insert objpro;
            
            Opportunity_Provider__c oppProvider = new Opportunity_Provider__c();
            oppProvider.Opportunity__c = opp.id;
            oppProvider.Provider__c = objpro.id;
            oppProvider.Delivering_Provider__c = true;
            oppProvider.Primary_Provider__c = true;
            insert oppProvider;
            
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = pro.id;
            oppProvider2.Delivering_Provider__c = false;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            
            //pro.Opportunity_Provider__c  =
            test.stopTest();
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
    }
    @isTest static void testRule3() {
        Opportunity opp = new Opportunity();
        try{
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
            Provider__c pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
            
            Opportunity_Provider__c oppProvider = new Opportunity_Provider__c();
            oppProvider.Opportunity__c = opp.id;
            oppProvider.Provider__c = objPro.id;
            oppProvider.Delivering_Provider__c = true;
            oppProvider.Primary_Provider__c = true;
            insert oppProvider;
            
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = pro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            
            //pro.Opportunity_Provider__c  =
            test.stopTest();
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
    }
    @isTest static void testRule4() {
        Opportunity opp = new Opportunity();
        try{
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
            Provider__c pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
            
            
            Opportunity_Provider__c oppProvider = new Opportunity_Provider__c();
            oppProvider.Opportunity__c = opp.id;
            oppProvider.Provider__c = pro.id;
            oppProvider.Delivering_Provider__c = true;
            oppProvider.Primary_Provider__c = true;
            insert oppProvider;
            
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = objPro.id;
            oppProvider2.Delivering_Provider__c = false;
            oppProvider2.Primary_Provider__c = true;
            insert oppProvider2;
            
            //pro.Opportunity_Provider__c  =
            test.stopTest();
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
    }
    
    
     @isTest static void testRuleUpdate1() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = objPro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            
            Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = pro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = true;
            
            insert oppProvider3;
            oppProvider2.Primary_Provider__c = true;
            update oppProvider2;
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        
        test.stopTest();
    }
    
    
     
    
     @isTest static void testRuleUpdate2() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
            
           
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = objPro.id;
            oppProvider2.Delivering_Provider__c = false;
            oppProvider2.Primary_Provider__c = true;
            insert oppProvider2;
            
            Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = pro.id;
            oppProvider3.Delivering_Provider__c = true; 
            oppProvider3.Primary_Provider__c = true;
            
            insert oppProvider3;
            
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        
        test.stopTest();
    }
    
    
     @isTest static void testRuleUpdate3() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = pro.id;
            oppProvider2.Delivering_Provider__c = false;
            oppProvider2.Primary_Provider__c = true;
            insert oppProvider2;
            
            Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = objPro.id;
            oppProvider3.Delivering_Provider__c = true; 
            oppProvider3.Primary_Provider__c = false;
            
            insert oppProvider3;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            update oppProvider2;
           
            
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        
        test.stopTest();
    }
    @isTest static void testRuleUpdate4() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        Opportunity_Provider__c oppProvider2;
        Opportunity_Provider__c oppProvider3;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = pro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = objPro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = true;
            
            insert oppProvider3;
            oppProvider2.Delivering_Provider__c = false; 
            oppProvider2.Primary_Provider__c = true;
            update oppProvider2;
            
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        test.stopTest();
    }
    
    
      @isTest static void testRuleUpdate5() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        Opportunity_Provider__c oppProvider2;
        Opportunity_Provider__c oppProvider3;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facilitY;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facility.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
             Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
            
            oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = objPro.id;
            oppProvider2.Delivering_Provider__c = false;
            oppProvider2.Primary_Provider__c = true;
            insert oppProvider2;
            oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = pro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = false;
            
            insert oppProvider3;
            oppProvider3.Primary_Provider__c = true;
            oppProvider3.Delivering_Provider__c = true;
            update oppProvider3;
            
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        test.stopTest();
    }
    
    
     @isTest static void testRuleUpdate6() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        Opportunity_Provider__c oppProvider2;
        Opportunity_Provider__c oppProvider3;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facility;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = objPro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = pro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = false;
            
            insert oppProvider3;
            oppProvider3.Primary_Provider__c = true;
            oppProvider3.Delivering_Provider__c = true;
            update oppProvider3;
            
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        test.stopTest();
    }
    
      @isTest static void testRuleUpdate7() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        Opportunity_Provider__c oppProvider2;
        Opportunity_Provider__c oppProvider3;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facilitY.Facility_Name__c = 'test';
            insert facility;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
             pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = objPro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = true;
            insert oppProvider2;
            oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = pro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = false;
            
            insert oppProvider3;
            oppProvider3.Primary_Provider__c = true;
            oppProvider3.Delivering_Provider__c = true;
            update oppProvider3;
            
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
       
        test.stopTest();
    }
    
    
    @isTest static void testRuleUpdate8() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        try{            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facilitY.City__c = 'Newyork';
            facility.Facility_Name__c = 'test';
            insert facility;
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
            pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = pro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = objPro.id;
            oppProvider3.Delivering_Provider__c = false; 
            oppProvider3.Primary_Provider__c = true;
            
            insert oppProvider3;
            oppProvider3.Delivering_Provider__c = true;
            update oppProvider3;
            List<Opportunity_Provider__c> oppoList = new List<Opportunity_Provider__c>();
            oppoList.add(oppProvider3);
            Map<Id,Opportunity_Provider__c> oldMap = new Map<Id,Opportunity_Provider__c>();
            oldMap.put(oppProvider3.id, oppProvider3);
            //OpportunityProviderHelper.rule(oppoList,false,oldMap);
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
        List<Opportunity_Provider__c> oppProdList = new List<Opportunity_Provider__c>();
        Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
        oppProvider2.Opportunity__c = opp.id;
        oppProvider2.Provider__c = pro.id;
        oppProvider2.Delivering_Provider__c = true;
        oppProvider2.Primary_Provider__c = false;
        oppProdList.add(oppProvider2);
        Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
        oppProvider3.Opportunity__c = opp.id;
        oppProvider3.Provider__c = pro.id;
        oppProvider3.Delivering_Provider__c = false; 
        oppProvider3.Primary_Provider__c = true;
            
        oppProdList.add(oppProvider3);
        try{
        insert oppProdList;
        }catch(Exception e){
            
        }
        test.stopTest();
    }
    
      @isTest static void testRuleUpdate9() {
        Opportunity opp = new Opportunity();
        Provider__c pro;
        try{
            
            test.startTest();
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Facility__c facility = new Facility__c ();
            facility.Address__c  = 'Test Address';
            facility.City__c = 'Newyork';
            facility.Facility_Name__c = 'test';
            insert facility;
            
            
            opp.Name = 'Test';
            opp.AccountId = acc.id;
            opp.StageName = 'Qualification';
            opp.CloseDate = system.today();
            opp.Adoption_Type__c = 'Closed';
            opp.Payment_Method__c = 'Credit Card';
            opp.of_Babies__c = 'single';
            opp.of_CB__c = '1';
            opp.of_CT__c = '0';
            opp.Due_Date__c = system.today().addDays(15);
            opp.Delivering_Hospital__c = facilitY.id;
            insert opp;
            
            pro = new Provider__c();
            pro.Address__c = 'Test address';
            pro.city__c = 'Newyork';
            pro.State__c = 'NY';
            pro.Provider_First_Name__c  = 'Test';
            pro.Provider_Last_Name__c = 'Provider';
            insert pro;
            
            Provider__c objPro = new Provider__c();
            objPro.Address__c = 'Test address';
            objPro.city__c = 'Newyork';
            objPro.State__c = 'NY';
            objPro.Provider_First_Name__c  = 'Test';
            objPro.Provider_Last_Name__c = 'Provider';
            insert objPro;
           
            Opportunity_Provider__c oppProvider2 = new Opportunity_Provider__c();
            oppProvider2.Opportunity__c = opp.id;
            oppProvider2.Provider__c = pro.id;
            oppProvider2.Delivering_Provider__c = true;
            oppProvider2.Primary_Provider__c = false;
            insert oppProvider2;
            Opportunity_Provider__c oppProvider3 = new Opportunity_Provider__c();
            oppProvider3.Opportunity__c = opp.id;
            oppProvider3.Provider__c = objPro.id;
            oppProvider3.Delivering_Provider__c = true; 
            oppProvider3.Primary_Provider__c = true;
            
            insert oppProvider3;
           
        }catch(Exception ex){
            string error = System.Label.DeliveringProvider +' '+ System.Label.ErrorMessage1 + ' '+ Opp.Name;
            system.debug(error);
            Boolean expectedExceptionThrown =  ex.getMessage().contains(error) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
            
        }
        
        test.stopTest();
    }
    
}