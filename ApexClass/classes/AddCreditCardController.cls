public class AddCreditCardController {
	@AuraEnabled
    public static Contact getContactDetail(String cId){
        String fieldList = getFieldList();
        
        String qry = 'Select '+fieldList+' From Contact Where Id=:cId';
        List<Contact> conList = new List<Contact>();
        conList = database.query(qry);
        if(conList.size()>0){
            return conList[0];
        }else{
            return null;
        }
    }
    public static String getFieldList(){
        Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
        String apiNames = '';
        for(string apiName : r.fields.getMap().keySet()){
            apiNames += apiName+',';
        }
        apiNames = apiNames.removeEnd(',');
        return apiNames;
    }
}