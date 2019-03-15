@isTest
private class PopulatePrimaryContactOnOppFromOCR_Test {

    static testMethod void ContactRoleTest() {
        // create test account
        Account a = new Account(name='sample');
        insert a;   

        // create test contacts
        Contact c1 = new Contact(firstname='Sally', lastname='Doe');
        Contact c2 = new Contact(firstname='John', lastname='Black');
        Contact c3 = new Contact(firstname='Jill', lastname='Hill');
        Contact[] cons = new Contact[]{c1, c2, c3}; 
        insert cons;

        // create test opp
        Opportunity o = new Opportunity(name='test Opp', closedate=system.today(), stagename='Prospect');
        insert o;

        // test 1: no OCRs == null
        o = [select primary_contact__c from opportunity where id=:o.id];
        o.description='initial test';
        update o;
        system.assert(o.primary_contact__c == null);

        // test 2: 1 OCR, not Primary == null
        OpportunityContactRole ocr1 = new OpportunityContactRole(opportunityid=o.id, contactid=c1.id, role='Mother');
        insert ocr1;
        ocr1 = [select createddate, opportunityid, contactid, role, isprimary from opportunitycontactrole where id = :ocr1.id];
        system.debug('************ ocr is:'+ocr1);
        o.description='test';
        update o;
        o = [select primary_contact__c from opportunity where id=:o.id];
        system.assert(o.primary_contact__c == null);

        // test 3: 1 OCR, Primary == c1
        ocr1.isprimary=true;
        update ocr1;
        o.description='test2';
        update o;
        o = [select primary_contact__c from opportunity where id=:o.id];
        system.assert(o.primary_contact__c == c1.id);

        // test 4: 2 OCR, 1 not Primary, 1 Primary == c2
        OpportunityContactRole ocr2 = new OpportunityContactRole(opportunityid=o.id, contactid=c2.id, role='Ship To', isprimary=true);
        insert ocr2;
        ocr2 = [select createddate, opportunityid, contactid, role, isprimary from opportunitycontactrole where id = :ocr2.id];
        ocr1.isprimary=false;
        update ocr1;
        o.description='test3';
        update o;
        o = [select primary_contact__c from opportunity where id=:o.id];
        system.assert(o.primary_contact__c == c2.id);

    }
}