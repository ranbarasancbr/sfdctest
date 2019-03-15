@isTest
public class AddCreditCardControllerTest {
    @isTest
    public static void unitTest(){
        contact conObj = New Contact();
        conObj.LastName = 'Test';
        conObj.FirstName = 'Test1';
        Insert conObj;
        AddCreditCardController creditObj = New AddCreditCardController();
        AddCreditCardController.getContactDetail(conObj.Id);
    }

}