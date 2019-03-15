/**************************************************************************************************************************************
*Component Name : opportunityValidateAndMerge
*Developed By   : TEKsystems
*Description    : This class method validateAndMergeOpp() is called from opportunityMergeController to validate all fields and merge winning and Losing Opportunities selected for mergeing.
                 - After merging opportunities we re-parent child records under losing opportunity.Reparenting of different child object is in different methods.
*User Story     : 491

**********************************************************************************************************************************/
public class opportunityValidateAndMerge{
    //Merging Opportunities Logic is handled. Input parameter pf  this method is opportunityMergeController.WrapperClass which holds 6 values that are winning Opportunity,Losing Opportunity,Merge Type,If custom merge list of fields that need to be merged, opportunity merged by and merge date.
    public static List<String> validateAndMergeOpp(List<opportunityMergeController.WrapperClass> wrapperList){
        Map<String,List<String>> AllReParentingErrors = new Map<String,List<String>>();//If there are any errors in reparenting of child records then that pariticular child object is added as key to this map and its errors are added as list of values 
        Map<String,List<String>> OCRErrorsList = new Map<String,List<String>>();//This map holds Opportunity Contact Role(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> oppProviderErrorsList = new Map<String,List<String>>();//This map holds Opportunity Provider(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> CIErrorsList = new Map<String,List<String>>();//This map holds Campaign Influence  (i.e child object name) as key and its related errors list as value
        Map<String,List<String>> openActivitesErrorsList = new Map<String,List<String>>();//This map holds Open Activites(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> FilesErrorsList = new Map<String,List<String>>();//This map holds Files(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> DocImageErrorsList = new Map<String,List<String>>();//This map holds DocImage Attachment(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> AssetsErrorsList = new Map<String,List<String>>();//This map holds Asset(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> NotesErrorsList = new Map<String,List<String>>();//This map holds Note(i.e child object name) as key and its related errors list as value
        Map<String,List<String>> OLEsErrorsList = new Map<String,List<String>>();//This map holds Online Enrollment(i.e child object name) as key and its related errors list as value
        system.debug('wrapperList mergeing'+wrapperList);
        Map<Id,opportunityMergeController.WrapperClass> winOppWrapperMap = new Map<Id,opportunityMergeController.WrapperClass>();//This map holds winning opp id as key and wrapperclass as value
        Map<id,Opportunity> WinOppMap = new Map<id,Opportunity>();//All winning opportunities are added to this map winning opp id as key and winning opp as value
        Map<id,Opportunity> lossOppMap = new Map<id,Opportunity>();//All Losing opportunities are added to this map Losing opp id as key and Losing opp as value
        Map<id,id> winLossIdsMap = new Map<id,id>();//This Map holds winning opp id as key and losing opp id as value
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();//This list holds save results of updated winning opportunities
        List<string> Opperrors = new List<string>();//this list holds winning opportunity updated failure errors
        List<Opportunity> OppListToUpdate = new List<Opportunity>();//opportunities that are to be updated are added to this list.
        Map<id,id> WinLossOppIdsMap = new map<id,id>();//This Map holds updated winnning opp id and its losing opp id as key-value pair
        Map<id,Opportunity> mergedWinOppMap = new Map<id,Opportunity>();//Updated Opp's winning Opportunity
        Map<id,Opportunity> mergedLossOppMap = new Map<id,Opportunity>();//updated winning opp's losing opportunity
        List<opportunity> LossOppsToUpdate = new List<opportunity>();//all losing opps are added to this list to update losing opps Stage,Status and lose Reason
        List<Database.SaveResult> lossOppSaveResults = new List<Database.SaveResult>();//This list holds save results of updated winning opportunities
        List<string> LossOpperrors = new List<string>();//this list holds winning opportunity updated failure errors
        //This Map is used to compare no of babys of winning Opportunity and losing opportunity 
        Map<String,Integer> NoOfBabysMap = new Map<String,Integer>{'Single' =>1,'Twins' => 2,'Triplets' => 3,'Quadruplets' => 4,'Quintuplets' => 5};
         Set<Id> UpdatedOppIds = new Set<id>();//This set holds updated winning opportunities
        //If wrapperList is not empty add each wrapperClass's winning opportunity as key and that WrapperClass as value to map- winOppWrapperMap.

        //For each wrapperclass which is input parameter to this method we add values to maps WinOppMap,winOppWrapperMap,lossOppMap and winLossIdsMap 
        if(wrapperList!=null && !wrapperList.isEmpty()){
            for(opportunityMergeController.WrapperClass w:wrapperList){
                
               Opportunity oppWin = w.winOpp;
               Opportunity oppLoss = w.lossOpp;
               WinOppMap.put(oppWin.id,oppWin);//All winning Opportunities are added to this map
               winOppWrapperMap.put(oppWin.id,w);//Winning opp id as key and wrapperclass as value added to this map
               lossOppMap.put(oppLoss.id,oppLoss);//All losing opportunities are added to this map
               winLossIdsMap.put(OppWin.id,oppLoss.id);//winning opp id => losing opp id are key value pair in this map
               system.debug('w.lossOpp============================'+w.lossOpp);
            }
        }
        system.debug('winOppWrapperMap============'+winOppWrapperMap);
       
            //If winOppWrapperMap is not null validate all fields of winning opportunity if any of the winning opportunity field value is null then update that field value with losing opportunity's field value.
            if(WinOppMap!=null && !WinOppMap.isEmpty()){
                system.debug('wrapper list not empty');
                for(Opportunity opp:WinOppMap.values()){
                    //Adding losing opportunity to losingOpp to access losing opportunity's fields
                    opportunity losingOpp = lossOppMap.get(winLossIdsMap.get(opp.id));
                    //String mType holds merge type
                    String mType = winOppWrapperMap.get(opp.id).mergeType;
                    //Adding merged by User Id to field  Opportunity_Merged_By__c of winning opportunity
                    opp.Opportunity_Merged_By__c = winOppWrapperMap.get(opp.id).MergedUserId;
                    opp.Opportunity_Merged_Date__c = system.today();//Adding today's date that is opportunity merged date to Opportunity_Merged_Date__c of winning opp
                    opp.Losing_Opportunity__c = losingOpp.id;//Losing opp Id is added to field Losing_Opportunity__c of winning opportunity
                    //If merge type is standard all fields in opportunityFields field set of winning opportunity are validated to check if any of the field value is null and if winning opp field value is null then copy same field value from losing opportunity to winning opportunity and update the opportunity
                    
                    Set<string> CustomMergeFieldsAPI = new Set<string>();
                    //for custom merge we add selected field names to set CustomMergeFieldsAPI
                    if(mType == 'Custom'){
                        CustomMergeFieldsAPI = winOppWrapperMap.get(opp.id).selectedFields;
                    }
                        //If losing Opp no of babies is > winning opp no of babies then we update winning opp of_Babies__c field value. As of_Babies__c field is picklist and its values are strings so used this map -- 'NoOfBabysMap' to check integer values 
                        if(NoOfBabysMap.get(opp.of_Babies__c)<NoOfBabysMap.get(losingOpp.of_Babies__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('of_Babies__c')))){
                            opp.of_Babies__c = losingOpp.of_Babies__c;
                        }
                        //If Pricebook2id is null on winning opp and losing opp have values for this field then we update winning opp's Pricebook2Id
                        if(String.isBlank(opp.Pricebook2Id) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Pricebook2Id')))){
                            opp.Pricebook2Id = losingOpp.Pricebook2Id;
                        }
                         //If Payment_Plan__c is null on winning opp and losing opp have values for this field then we update winning opp's Payment_Plan__c
                        if(String.isBlank(opp.Payment_Plan__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Payment_Plan__c')))){
                            opp.Payment_Plan__c = losingOpp.Payment_Plan__c ;
                        }
                         //If Payment_Method__c is null on winning opp and losing opp have values for this field then we update winning opp's Payment_Method__c
                        if(String.isBlank(opp.Payment_Method__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Payment_Method__c')))){
                            opp.Payment_Method__c = losingOpp.Payment_Method__c ;
                        }
                         //If CB_Storage_Fee_Option__c is null on winning opp and losing opp have values for this field then we update winning opp's CB_Storage_Fee_Option__c
                        if(String.isBlank(opp.CB_Storage_Fee_Option__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('CB_Storage_Fee_Option__c')))){
                            opp.CB_Storage_Fee_Option__c = losingOpp.CB_Storage_Fee_Option__c ;
                        }
                         //If CT_Storage_Fee_Option__c is null on winning opp and losing opp have values for this field then we update winning opp's CT_Storage_Fee_Option__c
                        if(String.isBlank(opp.CT_Storage_Fee_Option__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('CT_Storage_Fee_Option__c')))){
                            opp.CT_Storage_Fee_Option__c = losingOpp.CT_Storage_Fee_Option__c ;
                        }
                        //If Corporate_Discount__c is null on winning opp and losing opp have values for this field then we update winning opp's Corporate_Discount__c
                        if(String.isBlank(opp.Corporate_Discount__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Corporate_Discount__c')))){
                            opp.Corporate_Discount__c = losingOpp.Corporate_Discount__c ;
                        }
                        //If Promo_Code__c is null on winning opp and losing opp have values for this field then we update winning opp's Promo_Code__c
                        if(String.isBlank(opp.Promo_Code__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Promo_Code__c')))){
                            opp.Promo_Code__c = losingOpp.Promo_Code__c ;
                        }
                        //If Manual_Discount__c is null on winning opp and losing opp have values for this field then we update winning opp's Manual_Discount__c
                        if(opp.Manual_Discount__c==null && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Manual_Discount__c')))){
                            opp.Manual_Discount__c = losingOpp.Manual_Discount__c ;
                        }
                        //If Discount_Comments__c is null on winning opp and losing opp have values for this field then we update winning opp's Discount_Comments__c
                        if(String.isBlank(opp.Discount_Comments__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Discount_Comments__c')))){
                            opp.Discount_Comments__c = losingOpp.Discount_Comments__c ;
                        }
                        //If PickUp_or_Ship_Kit__c is null on winning opp and losing opp have values for this field then we update winning opp's PickUp_or_Ship_Kit__c
                        if(String.isBlank(opp.PickUp_or_Ship_Kit__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('PickUp_or_Ship_Kit__c')))){
                            opp.PickUp_or_Ship_Kit__c = losingOpp.PickUp_or_Ship_Kit__c ;
                        }
                        system.debug('winning opp ship to name'+opp.Ship_To_Name__c);
                            system.debug('losingOpp opp ship to name'+losingOpp.Ship_To_Name__c);
                            //If Ship_To_Name__c is null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_Name__c
                        if(String.isBlank(opp.Ship_To_Name__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_Name__c')))){
                            system.debug('winning opp ship to name'+opp.Ship_To_Name__c);
                            system.debug('losingOpp opp ship to name'+losingOpp.Ship_To_Name__c);
                            opp.Ship_To_Name__c = losingOpp.Ship_To_Name__c ;
                        }
                        system.debug('winning opp ship to Address'+opp.Ship_To_Street1__c);
                            system.debug('losingOpp opp ship to Address'+losingOpp.Ship_To_Street1__c);
                             //If Ship_To_Street1__cis null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_Street1__c
                        if(String.isBlank(opp.Ship_To_Street1__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_Street1__c')))){
                            opp.Ship_To_Street1__c= losingOpp.Ship_To_Street1__c;
                        }
                         //If Ship_To_Street1__cis null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_Street2__c
                        if(String.isBlank(opp.Ship_To_Street2__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_Street2__c')))){
                            opp.Ship_To_Street2__c= losingOpp.Ship_To_Street2__c;
                        }
                         //If Ship_To_City__c is null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_City__c
                        if(String.isBlank(opp.Ship_To_City__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_City__c')))){
                            opp.Ship_To_City__c= losingOpp.Ship_To_City__c;
                        }
                         //If Ship_To_State__c is null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_State__c
                        if(String.isBlank(opp.Ship_To_State__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_State__c')))){
                            opp.Ship_To_State__c= losingOpp.Ship_To_State__c;
                        }
                         //If Ship_To_Zip_Code__c is null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_Zip_Code__c
                        if(String.isBlank(opp.Ship_To_Zip_Code__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_Zip_Code__c')))){
                            opp.Ship_To_Zip_Code__c= losingOpp.Ship_To_Zip_Code__c;
                        }
                        //If Ship_To_Country__c is null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_Country__c
                        if(String.isBlank(opp.Ship_To_Country__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_Country__c')))){
                            opp.Ship_To_Country__c= losingOpp.Ship_To_Country__c;
                        }
                        //If Ship_To_Phone__c is null on winning opp and losing opp have values for this field then we update winning opp's Ship_To_Phone__c
                        if(String.isBlank(opp.Ship_To_Phone__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Ship_To_Phone__c')))){
                            opp.Ship_To_Phone__c = losingOpp.Ship_To_Phone__c ;
                        }
                        system.debug('winning opp ship to Total_Expedited_Shipping_Cost__c'+opp.Total_Expedited_Shipping_Cost__c);
                        system.debug('losingOpp opp ship to Total_Expedited_Shipping_Cost__c'+losingOpp.Total_Expedited_Shipping_Cost__c);
                        //If Total_Expedited_Shipping_Cost__c == 0 on winning opp and losing opp have values for this field then we update winning opp's Total_Expedited_Shipping_Cost__c == 0
                        if(opp.Total_Expedited_Shipping_Cost__c== 0 && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Total_Expedited_Shipping_Cost__c')))){
                            opp.Total_Expedited_Shipping_Cost__c = losingOpp.Total_Expedited_Shipping_Cost__c ;
                        }
                        //If Shipping_Method__c is null on winning opp and losing opp have values for this field then we update winning opp's Shipping_Method__c
                        if(String.isBlank(opp.Shipping_Method__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Shipping_Method__c')))){
                            opp.Shipping_Method__c = losingOpp.Shipping_Method__c ;
                        }
                          //If Requested_Shipping_Method__c is null on winning opp and losing opp have values for this field then we update winning opp's Requested_Shipping_Method__c
                        if(String.isBlank(opp.Requested_Shipping_Method__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Requested_Shipping_Method__c')))){
                            opp.Requested_Shipping_Method__c = losingOpp.Requested_Shipping_Method__c ;
                        }
                        //If Requested_Shipping_Date__c is null on winning opp and losing opp have values for this field then we update winning opp's Requested_Shipping_Date__c
                        if(opp.Requested_Shipping_Date__c==null && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Requested_Shipping_Date__c')))){
                            opp.Requested_Shipping_Date__c = losingOpp.Requested_Shipping_Date__c ;
                        }
                        //If Requested_Shipping_Date__c is null on winning opp and losing opp have values for this field then we update winning opp's Requested_Shipping_Date__c
                        if(!opp.Saturday_Delivery__c && losingOpp.Saturday_Delivery__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Saturday_Delivery__c')))){
                            opp.Saturday_Delivery__c = losingOpp.Saturday_Delivery__c ;
                        }
                         //If Signature_Required__c is null on winning opp and losing opp have values for this field then we update winning opp's Signature_Required__c
                        if(!opp.Signature_Required__c && losingOpp.Signature_Required__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Signature_Required__c')))){
                            opp.Signature_Required__c = losingOpp.Signature_Required__c ;
                        }
                        //if of_CT__c value on winning opp is less than of_CT__c value on losing opp then update winning opp values with losing opp value
                        if(integer.valueof(opp.of_CT__c)<integer.valueof(losingOpp.of_CT__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('of_CT__c')))){
                            opp.of_CT__c = losingOpp.of_CT__c;
                        }
                         //if of_CB__c value on winning opp is less than of_CB__c value on losing opp then update winning opp values with losing opp value
                        if(integer.valueof(opp.of_CB__c)<integer.valueof(losingOpp.of_CB__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('of_CB__c')))){
                            opp.of_CB__c = losingOpp.of_CB__c;
                        }
                        //If Gift_Registry_Start_Date__c || Gift_Registry_End_Date__c are null on winning opp then update this fields values from losing opp if values are present on losing opp for this fields
                        if(opp.Gift_Registry_End_Date__c == null && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Gift_Registry_End_Date__c')))){
                           
                            if(losingOpp.Gift_Registry_End_Date__c!=null){
                                opp.Gift_Registry_End_Date__c = losingOpp.Gift_Registry_End_Date__c;
                            }
                        } 
                        if(opp.Gift_Registry_Start_Date__c == null && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Gift_Registry_Start_Date__c')))){
                           
                            if(losingOpp.Gift_Registry_Start_Date__c!=null){
                                opp.Gift_Registry_Start_Date__c = losingOpp.Gift_Registry_Start_Date__c;
                            }
                        } 
                        //If Adoption_Type__c is N/A on winning opp and losing opp have values other than N/A f then we update winning opp's Adoption_Type__c
                        if(opp.Adoption_Type__c == 'N/A' && losingOpp.Adoption_Type__c != 'N/A' && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Adoption_Type__c')))){
                            opp.Adoption_Type__c = losingOpp.Adoption_Type__c;
                        }
                        //If Primary_Source__c is null on winning opp and losing opp have values for this field then we update winning opp's Primary_Source__c
                        if(String.isBlank(opp.Primary_Source__c) && String.isNotBlank(losingOpp.Primary_Source__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Primary_Source__c')))){
                            opp.Primary_Source__c = losingOpp.Primary_Source__c;
                        }
                        //If Referred_By_Opportunity__c is null on winning opp and losing opp have values for this field then we update winning opp's Referred_By_Opportunity__c
                        if(String.isNotBlank(losingOpp.Referred_By_Opportunity__c) && String.isBlank(opp.Referred_By_Opportunity__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Referred_By_Opportunity__c')))){
                            opp.Referred_By_Opportunity__c = losingOpp.Referred_By_Opportunity__c;
                        }
                         //If losing opp Section_1_Received__c is true and winning opp Section_1_Received__c is false then change winning opp Section_1_Received__c field to true
                        if(losingOpp.Section_1_Received__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_1_Received__c')))){
                            opp.Section_1_Received__c = losingOpp.Section_1_Received__c;
                        }
                        //If losing opp Section_2_Received__c is true and winning opp Section_2_Received__c is false then change winning opp Section_2_Received__c field to true
                        if(losingOpp.Section_2_Received__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_2_Received__c')))){
                            opp.Section_2_Received__c = losingOpp.Section_2_Received__c;
                        }
                        //If losing opp Section_3_Received__c is true and winning opp Section_3_Received__c is false then change winning opp Section_3_Received__c field to true
                        if(losingOpp.Section_3_Received__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Received__c')))){
                            opp.Section_3_Received__c = losingOpp.Section_3_Received__c;
                        }
                         //If losing opp Section_3_Incomplete__c is true and winning opp Section_3_Incomplete__c is false then change winning opp Section_3_Incomplete__c field to true
                        if(losingOpp.Section_3_Incomplete__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Incomplete__c')))){
                            opp.Section_3_Incomplete__c = losingOpp.Section_3_Incomplete__c;
                        }
                        //If losing opp Section_3_Needs_Review__c is true and winning opp Section_3_Needs_Review__c is false then change winning opp Section_3_Needs_Review__c field to true
                        if(losingOpp.Section_3_Needs_Review__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Needs_Review__c')))){
                            opp.Section_3_Needs_Review__c = losingOpp.Section_3_Needs_Review__c;
                        }
                         //If losing opp Section_4_Received__c is true and winning opp Section_4_Received__c is false then change winning opp Section_4_Received__c field to true
                        if(losingOpp.Section_4_Received__c  && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_4_Received__c')))){
                            opp.Section_4_Received__c    = losingOpp.Section_4_Received__c;
                        }
                         //If losing opp Section_5_Received__c is true and winning opp Section_5_Received__c is false then change winning opp Section_5_Received__c field to true
                        if(losingOpp.Section_5_Received__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_5_Received__c')))){
                            opp.Section_5_Received__c = losingOpp.Section_5_Received__c;
                        }
                         //If losing opp Section_2_Received_Birth_Mother__c is true and winning opp Section_2_Received_Birth_Mother__c is false then change winning opp Section_2_Received_Birth_Mother__c field to true
                        if(losingOpp.Section_2_Received_Birth_Mother__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_2_Received_Birth_Mother__c')))){
                            opp.Section_2_Received_Birth_Mother__c = losingOpp.Section_2_Received_Birth_Mother__c;
                        }
                        //If losing opp Section_3_Incomplete_Birth_Mother__c is true and winning opp Section_3_Incomplete_Birth_Mother__c is false then change winning opp Section_3_Incomplete_Birth_Mother__c field to true
                        if(losingOpp.Section_3_Incomplete_Birth_Mother__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Incomplete_Birth_Mother__c')))){
                            opp.Section_3_Incomplete_Birth_Mother__c = losingOpp.Section_3_Incomplete_Birth_Mother__c;
                        }
                        //If losing opp Section_3_Received_Birth_Mother__c is true and winning opp Section_3_Received_Birth_Mother__c is false then change winning opp Section_3_Received_Birth_Mother__c field to true
                        if(losingOpp.Section_3_Received_Birth_Mother__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Received_Birth_Mother__c')))){
                            opp.Section_3_Received_Birth_Mother__c = losingOpp.Section_3_Received_Birth_Mother__c;
                        }
                        //If losing opp Section_3_Needs_Review__c is true and winning opp Section_3_Needs_Review__c is false then change winning opp Section_3_Needs_Review__c field to true
                        if(losingOpp.Section_3_Needs_Review__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Needs_Review__c')))){
                            opp.Section_3_Needs_Review__c = losingOpp.Section_3_Needs_Review__c;
                        }
                        //If losing opp Section_5_Received_Birth_Mother__c is true and winning opp Section_5_Received_Birth_Mother__c is false then change winning opp Section_5_Received_Birth_Mother__c field to true
                        if(losingOpp.Section_5_Received_Birth_Mother__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_5_Received_Birth_Mother__c')))){
                            opp.Section_5_Received_Birth_Mother__c = losingOpp.Section_5_Received_Birth_Mother__c;
                        }
                        //If losing opp Delivering_Hospital__c have value and winning opp Delivering_Hospital__c is empty then populdate losing opp values on winning opp Delivering_Hospital__c field
                        if(String.isNotBlank(losingOpp.Delivering_Hospital__c) && String.isBlank(opp.Delivering_Hospital__c) && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Delivering_Hospital__c')))){
                            opp.Delivering_Hospital__c = losingOpp.Delivering_Hospital__c;
                        }
                        //If losing opp Section_3_Needs_Review_Birth_Mother__c is true and winning opp Section_3_Needs_Review_Birth_Mother__c is false then change winning opp Section_3_Needs_Review_Birth_Mother__c field to true
                        if(losingOpp.Section_3_Needs_Review_Birth_Mother__c && (mType == 'Standard' || ( mType == 'Custom' && CustomMergeFieldsAPI.contains('Section_3_Needs_Review_Birth_Mother__c')))){
                            opp.Section_3_Needs_Review_Birth_Mother__c = losingOpp.Section_3_Needs_Review_Birth_Mother__c;
                        }
                        OppListToUpdate.add(opp);
                   
                }//End of for loop
            }
        
        //If OppListToUpdate is not null update OppListToUpdate.
        if(OppListToUpdate!=null && !OppListToUpdate.isEmpty()){
            saveResults = Database.update(OppListToUpdate,false);

        }
        //Check all save results if any errors are found errors are added in list-errors
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    Opperrors.add(e.getMessage());
                }
            }
            //Get all updated opportunity Ids.
            else{
                UpdatedOppIds.add(saveResult.getId());
            }
        }
        system.debug(Opperrors);
        system.debug('Opportunity'+OppListToUpdate);
        system.debug('OppListToUpdate Size'+OppListToUpdate.size());
        //If set-UpdatedOppIds is not null we get 
        
        system.debug('UpdatedOppIds-----'+UpdatedOppIds);
        //for each UpdatedOppIds add values add values to maps mergedWinOppMap,mergedLossOppMap and WinLossOppIdsMap these maps are passed as input parameters for re-parenting child objects.
        if(UpdatedOppIds!=null && !UpdatedOppIds.isEmpty() && !WinOppMap.isEmpty()){
            system.debug('Inside if condition...............');
            for(Opportunity opp:WinOppMap.values()){
                if(UpdatedOppIds.contains(opp.id)){
                   mergedWinOppMap.put(opp.id,opp);
                    mergedLossOppMap.put(winLossIdsMap.get(opp.id),lossOppMap.get(winLossIdsMap.get(opp.id)));
                    WinLossOppIdsMap.put(opp.id,winLossIdsMap.get(opp.id));
                }
            }
        }
         //Update Losing opportunity's StageName = 'Closed Lost' and status__c = 'closed_Lost' and lose Reason = 'Duplicate Record'
           if(!UpdatedOppIds.isEmpty() && !mergedLossOppMap.isEmpty()){
                for(Opportunity lossOpp:mergedLossOppMap.values()){
                    system.debug('losing opp updating');
                    lossOpp.StageName = 'Closed Lost (10)';
                    lossOpp.Loss_Reason__c = 'Duplicate record';
                    lossOpp.Status__c = 'Closed_Lost';
                    //L.Opp.CT reason closed is set to Auto Closed (Not built yet) Field is not created
                    LossOppsToUpdate.add(lossOpp);
                }
           }
           system.debug('LossOppsToUpdate===='+LossOppsToUpdate);
            if(LossOppsToUpdate!=null || !LossOppsToUpdate.isEmpty()){
                system.debug('losing opp list not nnull');
                lossOppSaveResults = Database.update(LossOppsToUpdate,false);
            }
            for (Database.SaveResult saveResult : lossOppSaveResults) {
                if (!saveResult.isSuccess()) {
                    for (Database.Error e : saveResult.getErrors()) {
                        LossOpperrors.add(e.getMessage());
                    }
                }
            }
            system.debug('Loss opportunity Update failure Errors'+LossOpperrors);
            //Reparenting logic of child objects of opportunity is handled in seperate methods.
            if(mergedWinOppMap!=null && !mergedWinOppMap.isEmpty() && !mergedLossOppMap.isEmpty()){
            OCRErrorsList = reParentOpportunityContactRole(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            oppProviderErrorsList = reParentOppProviders(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            CIErrorsList = reParentCampaignInfluence(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            openActivitesErrorsList = reParentActivities(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            FilesErrorsList = reparentFiles(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            DocImageErrorsList = reParentDocImageAttachments(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            AssetsErrorsList = reParentAssets(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            NotesErrorsList = reParentNotes(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);
            OLEsErrorsList = reParentOnlineEnrollments(mergedWinOppMap,mergedLossOppMap,WinLossOppIdsMap);

            if(OCRErrorsList!=null && !OCRErrorsList.isEmpty()){
                AllReParentingErrors.put('Opportuity Contact Roles',OCRErrorsList.get('Opportuity Contact Roles'));
            }
             if(oppProviderErrorsList!=null && !oppProviderErrorsList.isEmpty()){
                AllReParentingErrors.put('Opportunity Provider',oppProviderErrorsList.get('Opportunity Provider'));
            }
             if(CIErrorsList!=null && !CIErrorsList.isEmpty()){
                AllReParentingErrors.put('Campaign influence',CIErrorsList.get('Campaign influence'));
            }
             if(openActivitesErrorsList!=null && !openActivitesErrorsList.isEmpty()){
                AllReParentingErrors.put('Open Activites',openActivitesErrorsList.get('Open Activites'));
            }
             if(FilesErrorsList!=null && !FilesErrorsList.isEmpty()){
                AllReParentingErrors.put('Files',FilesErrorsList.get('Files'));
            }
             if(DocImageErrorsList!=null && !DocImageErrorsList.isEmpty()){
                AllReParentingErrors.put('docImage Attachments',DocImageErrorsList.get('docImage Attachments'));
            }
             if(AssetsErrorsList!=null && !AssetsErrorsList.isEmpty()){
                AllReParentingErrors.put('Assets',AssetsErrorsList.get('Assets'));
            }
             if(NotesErrorsList!=null && !NotesErrorsList.isEmpty()){
                AllReParentingErrors.put('Notes',NotesErrorsList.get('Notes'));
            }
             if(OLEsErrorsList!=null && !OLEsErrorsList.isEmpty()){
                AllReParentingErrors.put('Online Enrollment',OLEsErrorsList.get('Online Enrollment'));
            }
        }
    
        List<Task> FinalTaskAfterMerge = new List<Task>();
        system.debug('AllReParentingErrors============'+AllReParentingErrors);
        system.debug('UpdatedOppIds==='+UpdatedOppIds);
        system.debug('WinOppMap============='+WinOppMap);
            if(UpdatedOppIds!=null && !UpdatedOppIds.isEmpty() && !WinOppMap.isEmpty()){
                system.debug('Inside if condition...............');
                for(Opportunity opp:WinOppMap.values()){
                    system.debug('merged opp');
                        if(UpdatedOppIds.contains(opp.id)){
                            system.debug('without errors opp');
                                //Creating task if opportunity merge is successfull 
                            if(AllReParentingErrors==null || AllReParentingErrors.isEmpty()){
                              Task t = new Task();
                              t.Subject = 'Opportunity Merge';
                              t.Description = 'Opportuities'+' ' + opp.Name + ' '+ lossOppMap.get(winLossIdsMap.get(opp.id)).Name + ' '+'have been merged.';
                              t.Priority = 'Normal';
                              t.OwnerId = opp.OwnerId;
                              t.Status = 'Completed';
                              t.WhatId = opp.id;
                               FinalTaskAfterMerge.add(t);
                             }
                             //Creating Task for partially merged opportunities.if there are any errors in re-parenting all those errors are added as comments in task
                             else{
                                system.debug('merged opp with errors');
                                String errorsString = null;
                                for(String s:AllReParentingErrors.keyset()){

                                         errorsString = s + ' Errors: '+String.join(AllReParentingErrors.get(s),', ')+'\n';
                                        
                                }
                                system.debug('errorsString========'+errorsString);
                                Task t = new Task();
                              t.Subject = 'Partial Opportunity Merge';
                              t.Description = errorsString;
                              t.Priority = 'Normal';
                              t.OwnerId = opp.OwnerId;
                              t.Status = 'Completed';
                               t.WhatId = opp.id;
                               FinalTaskAfterMerge.add(t);
                            }
                        }
                    
                }
            }
            List<Database.SaveResult> taskSaveResult = new List<Database.SaveResult>();
            List<String> taskErrors  = new List<String>();
            system.debug('FinalTaskAfterMerge=============='+FinalTaskAfterMerge);
        if(FinalTaskAfterMerge!=null && !FinalTaskAfterMerge.isEmpty()){
            //Create task for opportunity merge
            taskSaveResult = Database.insert(FinalTaskAfterMerge,false);
        }
         for (Database.SaveResult saveResult : taskSaveResult) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    taskErrors.add(e.getMessage());
                }
            }
        }
        system.debug(taskErrors);
        system.debug('taskSaveResult'+taskSaveResult);
        system.debug('Opperrors======'+Opperrors);
        //If any errors when winning opportunity is updated then if condition is executed
        if(Opperrors!=null && !Opperrors.isEmpty()){
            return Opperrors;
        }
         //if there are no errors in re-parenting and opp update then else condition is executed
        else{

             Opperrors.add('Opportunity Merged');
             return Opperrors;
        }
         
    }
    //This Method reparent Opportunity Contact Roles to Winning Opportunity. If Losing opp have same role as winning opp then those OCRs are re-parented with role value as duplicate. If losing opp have unknown as role value same OCR is re-parented with same value. If winning opp's OCRs doesnt have any value of losing opp's OCRs then OCRs are reparented with same Roles.
    //Note: we cannot update Opp id on opportunity contact Role so new contact roles are created and losing opp's contact roles are deleted in this method
    public static Map<String,List<String>> reParentOpportunityContactRole(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<OpportunityContactRole> OCRList = new List<OpportunityContactRole>();//this list holds quiered OCRs of winning and losing opp
         Map<id,List<OpportunityContactRole>> WinOppOCRlist = new Map<id,List<OpportunityContactRole>>();//This map holds winning opp id as key and its OCRs in list as value
        Map<id,List<OpportunityContactRole>> LossOppOCRlist = new Map<id,List<OpportunityContactRole>>();//This map holds Losing opp id key and its OCRs in list as value
        List<OpportunityContactRole> FinalOCRListToInsert = new List<OpportunityContactRole>();//This list have new OCRS for reparenting 
        List<OpportunityContactRole> FinalOCRListToDelete = new List<OpportunityContactRole>();//This list holds OCRS of losing opp that need to be deleted
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();//This  list holds save result of OCR creation
        List<string> errors = new List<string>();//This list holds OCR Create failure errors
         Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();//if any failure errors this map return with Opportunity Contact Roel as and its errors list as value

        system.debug('WinLosOppIds=============='+WinLosOppIds);
        //Query on OpportunityContactRole 
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            OCRList = [Select id,Role,OpportunityId,ContactId,isPrimary from OpportunityContactRole where OpportunityId IN:WinLosOppIds.keySet() OR OpportunityId IN:WinLosOppIds.values()];
        }
        system.debug('OCRList============'+OCRList);
       
        //Split losing OpportunitycontactRoles and winning OppContactRoels into 2 maps
        if(OCRList!=null && !OCRList.isEmpty()){
            for(OpportunityContactRole ocr:OCRList){
                if(WinLosOppIds.containsKey(ocr.OpportunityId)){
                    List<OpportunityContactRole> tempList = new List<OpportunityContactRole>();
                    tempList = WinOppOCRlist.get(ocr.OpportunityId);
                    if(tempList == null){
                        WinOppOCRlist.put(ocr.OpportunityId,new List<OpportunityContactRole>{ocr});
                    }
                    else{
                        tempList.add(ocr);
                        WinOppOCRlist.put(ocr.Opportunityid,tempList);
                    }
                }
                else{
                    List<OpportunityContactRole> tempList = new List<OpportunityContactRole>();
                    tempList = LossOppOCRlist.get(ocr.OpportunityId);
                    if(tempList == null){
                        LossOppOCRlist.put(ocr.OpportunityId,new List<OpportunityContactRole>{ocr});
                    }
                    else{
                        tempList.add(ocr);
                        LossOppOCRlist.put(ocr.Opportunityid,tempList);
                    }
                    
                }
            }
        }
        //for each winning opp we check roles present on its OCR child records.
        if(LossOppOCRlist!=null && !LossOppOCRlist.isEmpty()){
            for(Opportunity opp:mergedWinOppMap.values()){
                Set<String> winOcrRoles = new Set<String>();//Tis set holds all roles of winning Opps OCRs
                Boolean primaryOCR = false;
                if(WinOppOCRlist!=null && !WinOppOCRlist.isEmpty()){
                   for(OpportunityContactRole ocr:WinOppOCRlist.get(opp.id)){
                        winOcrRoles.add(ocr.Role);
                        if(ocr.isPrimary){
                            primaryOCR = true;
                        }
                    } 
                } 
                //If this winning opp's losing opp OCRs are not null then only we create new OCRs for winning opp
                if(LossOppOCRlist.get(WinLosOppIds.get(opp.id))!=null || !LossOppOCRlist.get(WinLosOppIds.get(opp.id)).isEmpty()){
                    for(OpportunityContactRole ocr:LossOppOCRlist.get(WinLosOppIds.get(opp.id))){
                         OpportunityContactRole o1 = new OpportunityContactRole();
                         o1.OpportunityId = opp.id;
                         if(!primaryOCR && ocr.isPrimary){
                            o1.isPrimary =  ocr.isPrimary;
                         }
                         else if(primaryOCR && ocr.isPrimary){
                            o1.isPrimary = false;
                         }
                        
                         o1.ContactId = ocr.ContactId;
                         //If OCR role is unkown new OCR created with same role
                        if(ocr.Role == 'Unknown'){
                            o1.Role = 'Unknown';
                        }
                        //if OCR role is repeated then we create OCR with duplicate role value
                        else if(!winOcrRoles.isEmpty() && winOcrRoles.contains(ocr.Role)){
                            o1.Role = 'Duplicate';
                            //ocr.OpportunityId = opp.id;
                        }
                        //if role is not there in winning opp OCRS then COR is created with same Role
                        else{
                            o1.Role = ocr.Role;
                        }
                        FinalOCRListToInsert.add(o1);//new OCRS for winning opp
                        FinalOCRListToDelete.add(ocr);//Losing opp's OCRs to delete
                    }
                }
                
            }
        }
        
        //If FinalOCRListToInsert is not null update FinalOCRListToInsert.
        if(FinalOCRListToInsert!=null && !FinalOCRListToInsert.isEmpty()){
            saveResults = Database.insert(FinalOCRListToInsert,false);
        }
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug(errors);
        system.debug('saveResults'+saveResults);
        
         //Deleting losing opportunity's contact Roles
         if(FinalOCRListToDelete!=null && !FinalOCRListToDelete.isEmpty()){
            Database.delete(FinalOCRListToDelete,false);
         }
         //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Opportuity Contact Roles',errors);
            return ErrorsMap;
        }
        //If no errors return null
        else{
            return null;
        }
        
    }
    //Reparenting of opportunity providers if there winning opportunity doesnt have primary and delivering opp provider but losing opportunity have primary and delivering opp provider then reparent losing opp providers to winning opp providers. If provider is same on winning opp and losing opp then we  update winning opp's opportunity provider insteady of reparenting
    //Start of opp proivder reparenting 
    public static Map<String,List<String>> reParentOppProviders(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<Opportunity_Provider__c> OppProviderList = new List<Opportunity_Provider__c>();//List holds queried on Opp Provider
        Map<id,List<Opportunity_Provider__c>> WinningOppProviderMap = new Map<id,List<Opportunity_Provider__c>>();//This map holds winning opp's opp providers
        Map<id,List<Opportunity_Provider__c>> LosingOppProviderMap = new Map<id,List<Opportunity_Provider__c>>();//This map holds Losing opp's opp providers
         List<Opportunity_Provider__c> OppProviderToUpdate = new List<Opportunity_Provider__c>();//This list holds opp providers that are to be updated
        List<Database.SaveResult> OppProvidersaveResults = new List<Database.SaveResult>();//Tis list holds save results of opp provider update
        List<string> errors = new List<string>();//This list holds failure errors
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            //Query on Opportunity provider object to get opp providers under winning opportunity and losing opportunity
            OppProviderList = [Select id,Delivering_Provider__c,Primary_Provider__c,Opportunity__c,Facility__c ,Provider__c,Provider_Facility__c  from Opportunity_Provider__c where Opportunity__c IN: WinLosOppIds.keySet() OR Opportunity__c IN: WinLosOppIds.values()];
        }
        system.debug('OppProviderList=============='+OppProviderList);
        //Split opp porviders into different maps with winning Opp id as key and list of opp providers as values to map  and add map-WinningOppProviderMap losing opp id and opp providers list to map-LosingOppProviderMap
        if(OppProviderList!=null && !OppProviderList.isEmpty()){
            for(Opportunity_Provider__c op:OppProviderList){
                if(WinLosOppIds.containsKey(op.Opportunity__c)){
                    List<Opportunity_Provider__c> tempList = new List<Opportunity_Provider__c>();
                    tempList = WinningOppProviderMap.get(op.Opportunity__c);
                    if(tempList == null){
                        WinningOppProviderMap.put(op.Opportunity__c,new List<Opportunity_Provider__c>{op});
                    }
                    else{
                        tempList.add(op);
                        WinningOppProviderMap.put(op.Opportunity__c,tempList);
                    }
                }
                else{
                    List<Opportunity_Provider__c> tempList = new List<Opportunity_Provider__c>();
                    tempList = LosingOppProviderMap.get(op.Opportunity__c);
                    if(tempList == null){
                        LosingOppProviderMap.put(op.Opportunity__c,new List<Opportunity_Provider__c>{op});
                    }
                    else{
                        tempList.add(op);
                        LosingOppProviderMap.put(op.Opportunity__c,tempList);
                    }
                    
                }
            }
        }
        system.debug('WinningOppProviderMap============'+WinningOppProviderMap);
        system.debug('LosingOppProviderMap=========='+LosingOppProviderMap);
        //For each winning opp if there is no primary provider or delivering but  losing opp have orimary provider and delivering provider then reparent losing opp's primary and delivering provider 
        system.debug('mergedWinOppMap==========='+mergedWinOppMap);
        if(mergedWinOppMap!=null && !mergedWinOppMap.isEmpty()){
            system.debug('Opp provider records');
            for(Opportunity opp:mergedWinOppMap.values()){
               Map<Id,String> WinOppProviderTypeOnOP = new Map<Id,String>();
                Map<Id,String> losingOppProviderTypeOnOP = new Map<Id,String>();
                Boolean isPrimary = false;
                Boolean isDelivering = false;
               //For each Opp provider of winning Opp add provider Id as key and value as String(if provider is primary= isPrimary, if provider is delivering is Delivering and is Provider is primary n delivering primaryDelProvider if not primary or delivering NONE) to map WinOppProviderTypeOnOP
                if(WinningOppProviderMap.get(opp.id)!=null && !WinningOppProviderMap.get(opp.id).isEmpty()){
                    for(Opportunity_Provider__c op:WinningOppProviderMap.get(opp.id)){
                        //If executes if provider is primary and delviering
                        if(op.Primary_Provider__c && op.Delivering_Provider__c){
                            WinOppProviderTypeOnOP.put(op.Provider__c,'primaryDelProvider');
                            isPrimary = true;
                            isDelivering = true;
                            system.debug('debug---------1');
                        }
                        //Below else if executes if op is primary but not delivering 
                        else if(op.Primary_Provider__c && !op.Delivering_Provider__c){
                            WinOppProviderTypeOnOP.put(op.Provider__c,'primaryProvider');
                            isPrimary = true;
                            system.debug('debug---------2');
                        }
                        //if opp provider is delivering but not primary then add key value pair to map WinOppProviderTypeOnOP
                         else if(!op.Primary_Provider__c && op.Delivering_Provider__c){
                            WinOppProviderTypeOnOP.put(op.Provider__c,'deliveringProvider');
                            isDelivering = true;
                            system.debug('debug---------3');
                        }
                        //if opp provider is not primary or delivering then add key value pair to map WinOppProviderTypeOnOP
                        else{
                            WinOppProviderTypeOnOP.put(op.Provider__c,'None');
                            system.debug('debug---------4');
                        }
                    }//winning opps Opp provider for loop end
                }
                else{
                    system.debug(' no winning opp providers');
                    isPrimary = false;
                    isDelivering = false;
                }
                system.debug('WinOppProviderTypeOnOP======='+WinOppProviderTypeOnOP);
                //If there are opp provides on losing opp then below if conditio n is executed to reparent opp providers of losing opp
                if(LosingOppProviderMap.get(WinLosOppIds.get(opp.id))!=null && !LosingOppProviderMap.get(WinLosOppIds.get(opp.id)).isEmpty()){
                    for(Opportunity_Provider__c op:LosingOppProviderMap.get(WinLosOppIds.get(opp.id))){
                        //If losing opp's provider is in winning opp's provider then we update winning opp's opp provider so below coditions check opp providers on losing opp and add to losingOppProviderTypeOnOP
                        if(!WinOppProviderTypeOnOP.isEmpty() && WinOppProviderTypeOnOP!=null){
                             if(WinOppProviderTypeOnOP.containsKey(op.Provider__c)){
                                system.debug('in winning opp===');
                                system.debug('op------------'+op);
                                 String type =  WinOppProviderTypeOnOP.get(op.Provider__c);
                                 if(type == 'primaryProvider' && op.Delivering_Provider__c){
                                    losingOppProviderTypeOnOP.put(op.Provider__c,'deliveringProvider');//op with this provider is updated as delivering provider
                                 }
                                 else if(type == 'deliveringProvider' && op.Primary_Provider__c){
                                    losingOppProviderTypeOnOP.put(op.Provider__c,'primaryProvider');//op with this provider is updated as primary provider
                                 }
                                 else if(type == 'None'){
                                   losingOppProviderTypeOnOP.put(op.Provider__c,'PrimaryDeliveringProvider');
                                 }
                             }
                            else{
                                 system.debug('op------------11'+op);
                                system.debug('not in winning opp');
                                system.debug('isPrimary==='+isPrimary);
                                system.debug('isDelivering==='+isDelivering);
                                system.debug('op.Primary_Provider__c==='+op.Primary_Provider__c);
                                system.debug('op.Delivering_Provider__c========'+op.Delivering_Provider__c);
                                 if(isPrimary && op.Primary_Provider__c || isDelivering && op.Delivering_Provider__c){
                                    if(isPrimary && op.Primary_Provider__c){
                                        system.debug('los opp primary');
                                        op.Primary_Provider__c = false;
                                     }
                                     if(isDelivering && op.Delivering_Provider__c){
                                        system.debug('los opp delivering');
                                        op.Delivering_Provider__c = false;
                                    }
                                    op.Opportunity__c = opp.id;
                                     OppProviderToUpdate.add(op);
                                 }
                                else if(!isPrimary && op.Primary_Provider__c){
                                    op.Opportunity__c = opp.id;
                                     OppProviderToUpdate.add(op);
                                }
                                else if(!isDelivering && op.Delivering_Provider__c){
                                    op.Opportunity__c = opp.id;
                                     OppProviderToUpdate.add(op);
                                 }
                                else  if(!op.Primary_Provider__c && !op.Delivering_Provider__c){
                                    op.Opportunity__c = opp.id;
                                     OppProviderToUpdate.add(op);
                                 }
                               
                            }
                        }
                        else{
                            op.Opportunity__c = opp.id;
                            OppProviderToUpdate.add(op);
                        }
                       
                    }
                }//If condition when losing opp have Opportunity providers
                if(losingOppProviderTypeOnOP!=null && !losingOppProviderTypeOnOP.isEmpty() && WinningOppProviderMap.get(opp.id)!=null && !WinningOppProviderMap.get(opp.id).isEmpty()){
                    for(Opportunity_Provider__c op:WinningOppProviderMap.get(opp.id)){
                        system.debug('winning opp update');
                        if(losingOppProviderTypeOnOP.containsKey(op.Provider__c)){
                             system.debug('winning opp update1111111111');
                            String s = losingOppProviderTypeOnOP.get(op.Provider__c);
                            if(s == 'deliveringProvider' && !isDelivering){
                                 system.debug('winning opp update22222222222');
                                op.Delivering_Provider__c = true;
                            }
                            else if(s == 'primaryProvider' && !isPrimary){
                                 system.debug('winning opp update33333333333');
                                op.Primary_Provider__c = true;
                            }
                            else if(!isDelivering && !isPrimary){
                                 system.debug('winning opp update444444444444');
                                op.Delivering_Provider__c = true;
                                 op.Primary_Provider__c = true;
                            }
                             OppProviderToUpdate.add(op);
                        }
                    }

                }
            }//End of for Loop of winning Opportunties
        }
       
        //If OppProviderToUpdate is not null update OppProviderToUpdate.
        if(OppProviderToUpdate!=null && !OppProviderToUpdate.isEmpty()){
            OppProvidersaveResults = Database.update(OppProviderToUpdate,false);
        }
        for (Database.SaveResult saveResult : OppProvidersaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug(errors);
        system.debug('OppProvidersaveResults'+OppProvidersaveResults);
        Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
        //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Opportunity Provider',errors);
            return ErrorsMap;
        }
        //if there are  no erros return null
        else{
            return null;
        }
        
    }
    //End of opp provider reparenting
    
    //Campaign records reparenting if there are no campaign influence child records on winning opp and campaign child records are present under losing opp then reparent campaign influence records of losing opp and if  losing opp campaignInfluence records doesnt have same campaign Ids as winning opp's campaign influence
    //Note we cannot udpate opp id on campaign influence os we create new campaigninfluence records for winning opp same as related to losing opp and delete losing opp's camapigninfluence reocrds
    //Start of campaign influnce reparenting.
    public static Map<String,List<String>> reParentCampaignInfluence(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<CampaignInfluence> CampaignInfluenceList = new List<CampaignInfluence>();//This list holds queried campaignInfluence records
        List<CampaignInfluence> FinalCIListToInsert = new List<CampaignInfluence>();//This list holds campignInfluence to insert
        List<CampaignInfluence> FinalCIListToDelete = new List<CampaignInfluence>();//this list holds campignInfluence to delete
        Map<id,List<CampaignInfluence>> WinningOppCIMap = new Map<id,List<CampaignInfluence>>();//this map holds winning opp id as key and its related campignInfluence as values in list
        Map<id,List<CampaignInfluence>> LosingOppCIMap = new Map<id,List<CampaignInfluence>>();//this map holds losing opp id as key and its related campignInfluence as values in list
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();//this list holds new CampaignInfluence save results
        List<string> errors = new List<string>();//This list holds failure errors
         Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();//this map holds errors as value and CampaignInflunce as key
        //Query on campaign influence
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            CampaignInfluenceList = [Select id,CampaignId ,OpportunityId,ModelId from CampaignInfluence where OpportunityId IN:WinLosOppIds.keySet() OR Opportunityid IN:WinLosOppIds.values()];
        }
        system.debug('CampaignInfluenceList============='+CampaignInfluenceList);
        //Split campaign influence of winning and losing opps
        if(CampaignInfluenceList!=null && !CampaignInfluenceList.isEmpty()){
            for(CampaignInfluence c:CampaignInfluenceList){
                if(WinLosOppIds.containsKey(c.OpportunityId)){
                    List<CampaignInfluence> tempList = new List<CampaignInfluence>();
                    tempList = WinningOppCIMap.get(c.OpportunityId);
                    if(tempList == null){
                        WinningOppCIMap.put(c.OpportunityId,new List<CampaignInfluence>{c});
                    }
                    else{
                        tempList.add(c);
                        WinningOppCIMap.put(c.OpportunityId,tempList);
                    }
                }
                else{
                    List<CampaignInfluence> tempList = new List<CampaignInfluence>();
                    tempList = LosingOppCIMap.get(c.OpportunityId);
                    if(tempList == null){
                        LosingOppCIMap.put(c.OpportunityId,new List<CampaignInfluence>{c});
                    }
                    else{
                        tempList.add(c);
                        LosingOppCIMap.put(c.OpportunityId,tempList);
                    }
                    
                }
            }
        }
        if(mergedWinOppMap!=null && !mergedWinOppMap.isEmpty()){
            system.debug('mergedWinOppMap======'+mergedWinOppMap);
            for(Opportunity opp:mergedWinOppMap.values()){
                //Get Campaign Ids of winning Opportunity's campaignInfluence 
                Set<Id> WinningOppCampIds = new Set<id>();
                if(WinningOppCIMap!=null && !WinningOppCIMap.isEmpty()){
                    for(CampaignInfluence c:WinningOppCIMap.get(opp.id)){
                         WinningOppCampIds.add(c.CampaignId);
                    }
                }
                system.debug('WinningOppCIMap===='+WinningOppCIMap);
                system.debug('LosingOppCIMap==='+LosingOppCIMap);
                system.debug('WinningOppCampIds===='+WinningOppCampIds);
                    //If campaign id of losing campaign influence records not in winning opp's campaign ids then create a new Campaign influence under winning opportunity and delete that losing opps campaign influence.
                    if(LosingOppCIMap!=null && !LosingOppCIMap.isEmpty()){
                        for(CampaignInfluence c:LosingOppCIMap.get(WinLosOppIds.get(opp.id))){
                            if(!WinningOppCampIds.contains(c.CampaignId)){
                                CampaignInfluence newCI = new CampaignInfluence();
                                newCI.CampaignId = c.CampaignId;
                                newCI.OpportunityId = opp.id;
                                newCI.Modelid = c.Modelid;
                                FinalCIListToInsert.add(newCI);
                                FinalCIListToDelete.add(c);
                            }
                         }
                    } 
              
            }
        }
        system.debug('FinalCIListToInsert============='+FinalCIListToInsert);
     
        //If FinalCIListToInsert is not null update FinalCIListToInsert.
        if(FinalCIListToInsert!=null && !FinalCIListToInsert.isEmpty()){
            saveResults = Database.insert(FinalCIListToInsert,false);
        }
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        //Delteing losing opp's campaignInfluence
        if(FinalCIListToDelete!=null || !FinalCIListToDelete.isEmpty()){
            Database.delete(FinalCIListToDelete,false);
        }
        system.debug(errors);
        system.debug('FinalCIListToInsert'+FinalCIListToInsert);
       //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Campaign influence',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }
    }
    //End of campaign influence reparenting.
    
    //Start of Activites reparenting
    //If open activities (Tasks OR Events)are present under losing opportunity then reparent then to winning opp.
    public static Map<String,List<String>> reParentActivities(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<Task> LosingOppOpenTasks = new List<Task>();
        Map<id,List<Task>> OppOpenTasksMap = new Map<id,List<Task>>();
        Map<id,List<Event>> OppUpComingEventsMap = new Map<id,List<Event>>();
        List<Task> finalTasksToUpdate = new list<Task>();
        List<Event> LosingOppOpenEvents = new List<Event>();
        List<Event> FinalOppEventsToUpdate = new List<Event>();
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        List<Database.SaveResult> EventSaveResults = new List<Database.SaveResult>();
        List<string> errors = new List<string>();
           Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            LosingOppOpenTasks = [Select Id,WhatId,Status,WhoId,OwnerId from Task where WhatId IN:WinLosOppIds.values() AND Status='Open'];
            LosingOppOpenEvents = [Select Id,WhatId,StartDateTime,WhoId,OwnerId from Event where WhatId IN:WinLosOppIds.values() AND StartDateTime >: system.now()];
        }
        system.debug('LosingOppOpenTasks=============='+LosingOppOpenTasks);
        system.debug('LosingOppOpenEvents=============='+LosingOppOpenEvents);
        if(LosingOppOpenEvents!=null && !LosingOppOpenEvents.isEmpty()){
            for(Event e:LosingOppOpenEvents){
                List<Event> tempList = new List<Event>();
                tempList = OppUpComingEventsMap.get(e.WhatId);
                if(tempList == null){
                    OppUpComingEventsMap.put(e.WhatId,new List<Event>{e});
                }
                else{
                    tempList.add(e);
                    OppUpComingEventsMap.put(e.WhatId,tempList);
                }
            }
        }
        if(OppUpComingEventsMap!=null && !OppUpComingEventsMap.isEmpty()){
           for(Opportunity opp:mergedWinOppMap.values()){
                if(OppUpComingEventsMap.get(WinLosOppIds.get(opp.id)).size()>0){
                    for(Event e:OppUpComingEventsMap.get(WinLosOppIds.get(opp.id))){
                        e.WhatId = opp.id;
                        e.OwnerId = opp.OwnerId;
                        //e.WhoId = opp.Primary_Contact__c;
                        FinalOppEventsToUpdate.add(e);
                    }
                }
            }
        }
        if(FinalOppEventsToUpdate!=null && !FinalOppEventsToUpdate.isEmpty()){
            EventSaveResults = Database.update(FinalOppEventsToUpdate,false);
        }
        for (Database.SaveResult saveResult : EventSaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        //Reparenting Tasks
        if(LosingOppOpenTasks!=null && !LosingOppOpenTasks.isEmpty()){
            for(Task t:LosingOppOpenTasks){
                List<Task> tempList = new List<Task>();
                tempList = OppOpenTasksMap.get(t.WhatId);
                if(tempList == null){
                    OppOpenTasksMap.put(t.WhatId,new List<Task>{t});
                }
                else{
                    tempList.add(t);
                    OppOpenTasksMap.put(t.WhatId,tempList);
                }
            }
        }
        if(OppOpenTasksMap!=null && !OppOpenTasksMap.isEmpty()){
            for(Opportunity opp:mergedWinOppMap.values()){
                if(OppOpenTasksMap.get(WinLosOppIds.get(opp.id)).size()>0){
                    for(Task t:OppOpenTasksMap.get(WinLosOppIds.get(opp.id))){
                        t.WhatId = opp.id;
                        //t.WhoId = opp.Primary_Contact__c;
                        t.OwnerId = opp.OwnerId;
                        finalTasksToUpdate.add(t);
                    }
                }
            }
        }
        //If finalTasksToUpdate is not null update finalTasksToUpdate.
        if(finalTasksToUpdate!=null && !finalTasksToUpdate.isEmpty()){
            saveResults = Database.update(finalTasksToUpdate,false);
        }
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug(errors);
        system.debug('finalTasksToUpdate'+finalTasksToUpdate);
        //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Open Activites',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }

    }
    //End of Activites reparenting
    
    //Start Of files reparenting
    //Reparenting files of losing opportunity
   public static Map<String,List<String>> reparentFiles(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<ContentDocumentLink> filesList = new List<ContentDocumentLink>();
        Map<id,List<ContentDocumentLink>> OppFilesMap = new Map<id,List<ContentDocumentLink>>();
        Map<id,id> LosOppToWinOppIds = new map<id,id>();//this map holds losing opp id as key and winning opp id as value.
        List<ContentDocumentLink> FinalFilesListToUpdate = new List<ContentDocumentLink>();
        List<Database.SaveResult> FielssaveResults = new List<Database.SaveResult>();
        List<string> errors = new List<string>();
         Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
        system.debug('mergedWinOppMap======'+mergedWinOppMap);
        system.debug('mergedLosingOppMap======='+mergedLosingOppMap);
        system.debug('WinLosOppIds=========='+WinLosOppIds);
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            for(opportunity opp:mergedWinOppMap.values()){
                LosOppToWinOppIds.put(WinLosOppIds.get(opp.id),opp.id);
            }
            //Query on ContentDocumentLink to get losing opportunity Files
            filesList = [Select id,ContentDocumentId,LinkedEntityId,Visibility,ShareType from ContentDocumentLink where LinkedEntityId IN (Select id from opportunity where id IN:WinLosOppIds.values())];
        }
        system.debug('filesList========='+filesList);
        
        if(filesList!=null && !filesList.isEmpty()){
            for(ContentDocumentLink c:filesList){
                List<ContentDocumentLink> tempList = new List<ContentDocumentLink>();
                tempList = OppFilesMap.get(c.LinkedEntityId);
                if(tempList == null){
                    OppFilesMap.put(c.LinkedEntityId,new List<ContentDocumentLink>{c});
                }
                else{
                    tempList.add(c);
                    OppFilesMap.put(c.LinkedEntityId,tempList);
                }
            }
            system.debug('OppFilesMap----------'+OppFilesMap);
            system.debug('mergedLosingOppMap============='+mergedLosingOppMap);
            system.debug('LosOppToWinOppIds=========='+LosOppToWinOppIds);
            for(Opportunity opp:mergedLosingOppMap.values()){
                system.debug('INside opp loop'+opp);
                if(OppFilesMap.containsKey(opp.id)){
                    for(ContentDocumentLink c:OppFilesMap.get(opp.id)){
                        if(LosOppToWinOppIds.containsKey(opp.id)  && !LosOppToWinOppIds.isEmpty()){
                            system.debug('c=========='+c);
                           // c.LinkedEntityId = LosOppToWinOppIds.get(opp.id);
                          ContentDocumentLink cNew =c.clone();
                          cNew.LinkedEntityId = LosOppToWinOppIds.get(opp.id);
                          FinalFilesListToUpdate.add(cNew);
                        }
                    }
                }
            }
        }
        system.debug('FinalFilesListToUpdate==========='+FinalFilesListToUpdate);
        
        //If FinalFilesListToUpdate is not null update FinalFilesListToUpdate.
        if(FinalFilesListToUpdate!=null && !FinalFilesListToUpdate.isEmpty()){
            FielssaveResults = Database.insert(FinalFilesListToUpdate,false);
        }
       
        //Check all save results if any errors are found errors are added in list-errors
        for (Database.SaveResult saveResult : FielssaveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug('errors'+errors);
        //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Files',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }
    } 
    //End of files reparenting.
    
    //Start of docImageAttachments reparenting.
    //If any docImageAttachment records are present under losing opportunity reparent them to winning opportunity.
    public static Map<String,List<String>> reParentDocImageAttachments(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<DocImage_Attachment__c> docImageAttachmentsList = new List<DocImage_Attachment__c>();
        List<DocImage_Attachment__c> FinalDocImageAttachmentsList = new List<DocImage_Attachment__c>();
        Map<id,List<DocImage_Attachment__c>> loseOppDocImageMap = new  Map<id,List<DocImage_Attachment__c>>();
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            docImageAttachmentsList = [Select id,Opportunity__c from DocImage_Attachment__c where Opportunity__c IN:WinLosOppIds.values()];
        }
        system.debug('docImageAttachmentsList========='+docImageAttachmentsList);
        if(docImageAttachmentsList!=null && !docImageAttachmentsList.isEmpty()){
            for(DocImage_Attachment__c doc:docImageAttachmentsList){
                List<DocImage_Attachment__c> tempList = new List<DocImage_Attachment__c>();
                tempList = loseOppDocImageMap.get(doc.Opportunity__c);
                if(tempList == null){
                    loseOppDocImageMap.put(doc.Opportunity__c,new List<DocImage_Attachment__c>{doc});
                }
                else{
                    tempList.add(doc);
                    loseOppDocImageMap.put(doc.Opportunity__c,tempList);
                }
            }
        }
        if(mergedWinOppMap!=null && !mergedWinOppMap.isEmpty() && loseOppDocImageMap!=null && !loseOppDocImageMap.isEmpty()){
            for(Opportunity opp:mergedWinOppMap.values()){
                if(loseOppDocImageMap.get(WinLosOppIds.get(opp.id)).size()>0){
                    for(DocImage_Attachment__c doc:loseOppDocImageMap.get(WinLosOppIds.get(opp.id))){
                        doc.Opportunity__c = opp.id;
                        FinalDocImageAttachmentsList.add(doc);
                    }
                }
            }
        }
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        List<string> errors = new List<string>();
        //If FinalDocImageAttachmentsList is not null update FinalDocImageAttachmentsList.
        if(FinalDocImageAttachmentsList!=null && !FinalDocImageAttachmentsList.isEmpty()){
            saveResults = Database.update(FinalDocImageAttachmentsList,false);
        }
        //Check all save results if any errors are found errors are added in list-errors
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug('errors'+errors);
        Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
        //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('docImage Attachments',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }
    }
    //End of docImageAttachments reparenting.
    
    //Start of reparenting Assets.
    //If any Assets records are present under losing opportunity reparent them to winning opportunity.
    public static Map<String,List<String>> reParentAssets(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetListToUpdate = new List<Asset>();
        Map<id,List<Asset>> losingOppAssetsMap = new Map<id,List<Asset>>();
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            assetList = [Select id,Opportunity__c from Asset where Opportunity__c IN:WinLosOppIds.values()];
        }
        system.debug('assetList============'+assetList);
        if(assetList!=null && !assetList.isEmpty()){
            for(Asset a:assetList){
                List<Asset> tempList = new List<Asset>();
                tempList = losingOppAssetsMap.get(a.Opportunity__c);
                if(tempList == null){
                    losingOppAssetsMap.put(a.Opportunity__c,new List<Asset>{a});
                }
                else{
                    tempList.add(a);
                    losingOppAssetsMap.put(a.Opportunity__c,tempList);
                }
            }
        }
        if(mergedWinOppMap!=null && !mergedWinOppMap.isEmpty() && losingOppAssetsMap!=null && !losingOppAssetsMap.isEmpty()){
            for(Opportunity opp:mergedWinOppMap.values()){
                if(losingOppAssetsMap.get(WinLosOppIds.get(opp.id)).size()>0){
                    for(Asset a:losingOppAssetsMap.get(WinLosOppIds.get(opp.id))){
                        a.Opportunity__c = opp.id;
                        assetListToUpdate.add(a);
                    }
                }
            }
        }
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        List<string> errors = new List<string>();
        //If assetListToUpdate is not null update assetListToUpdate.
        if(assetListToUpdate!=null && !assetListToUpdate.isEmpty()){
            saveResults = Database.update(assetListToUpdate,false);
        }
        //Check all save results if any errors are found errors are added in list-errors
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug('errors'+errors);
       Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
       //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Assets',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }
    }
    //End of reparenting Assets.
    
    //Start of reparenting Notes.
    //If any Notes are present under losing opportunity reparent them to winning opportunity.
    public static Map<String,List<String>> reParentNotes(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        list<Note> notesList = new List<Note>();
        List<Note> finalNoteListInsert = new List<Note>();
        Map<id,List<Note>> LosingOppNotesMap = new Map<id,List<Note>>();
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            notesList = [SELECT ID, ParentID,Title,Body from Note where ParentID IN:WinLosOppIds.values()];
        }
        system.debug('notesList============='+notesList);
        if(notesList!=null && !notesList.isEmpty()){
            for(Note a:notesList){
                List<Note> tempList = new List<Note>();
                tempList = LosingOppNotesMap.get(a.ParentID);
                if(tempList == null){
                    LosingOppNotesMap.put(a.ParentID,new List<Note>{a});
                }
                else{
                    tempList.add(a);
                    LosingOppNotesMap.put(a.ParentID,tempList);
                }
            }
        }
        if(mergedWinOppMap!=null && !mergedWinOppMap.isEmpty() && LosingOppNotesMap!=null && !LosingOppNotesMap.isEmpty()){
            for(Opportunity opp:mergedWinOppMap.values()){
                if(LosingOppNotesMap.get(WinLosOppIds.get(opp.id)).size()>0){
                    for(Note a:LosingOppNotesMap.get(WinLosOppIds.get(opp.id))){
                        Note newNote = new Note();
                        newNote = a.clone();
                        newNote.ParentID = opp.id;
                        newNote.Title = a.Title;
                        newNote.Body = a.Body;
                        finalNoteListInsert.add(newNote);
                    }
                }
            }
        }
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        List<string> errors = new List<string>();
        //If finalNoteListInsert is not null insert finalNoteListInsert.
        if(finalNoteListInsert!=null && !finalNoteListInsert.isEmpty()){
            saveResults = Database.insert(finalNoteListInsert,false);
        }
        //Check all save results if any errors are found errors are added in list-errors
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    errors.add(e.getMessage());
                }
            }
        }
        system.debug('errors'+errors);
        Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
        //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Notes',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }
    }
    //End of reparenting Assets.
    
    
    //Start of online Enrollment record update.
    //If a OLE reocrd is having losing opp id then update that OLE with winning opp id
    public static Map<String,List<String>> reParentOnlineEnrollments(Map<id,Opportunity> mergedWinOppMap,Map<id,Opportunity> mergedLosingOppMap,Map<id,id> WinLosOppIds){
        List<Online_Enrollment__c> losingOppOleListToUpdate = new List<Online_Enrollment__c>();
        Map<Id,Online_Enrollment__c> losingOppOleMap = new Map<Id,Online_Enrollment__c>();
         List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
            List<string> errors = new List<string>();
            Map<String,List<String>> ErrorsMap = new Map<String,List<String>>();
        //Query on oles related to losing opportunities
        if(WinLosOppIds!=null && !WinLosOppIds.isEmpty()){
            //losingOppOleMap = new Map<id,Online_Enrollment__c>([Select id,Opportunity_Id__c,Opportunity_Status__c from Online_Enrollment__c where Opportunity_Id__c IN:WinLosOppIds.values() AND Opportunity_Status__c ='Open']);
            losingOppOleMap = new Map<id,Online_Enrollment__c>([Select id,Opportunity_Id__c,Opportunity_Status__c from Online_Enrollment__c where Opportunity_Id__c IN:WinLosOppIds.values()]);
        }
        system.debug('losingOppOleMap==========='+losingOppOleMap);
        if(losingOppOleMap!=null && !losingOppOleMap.isEmpty() && mergedWinOppMap!=null && !mergedWinOppMap.isEmpty()){
            system.debug('winning opps ');
            for(Opportunity opp:mergedWinOppMap.values()){
                system.debug('Winning opp values for OLE');

                system.debug('WinLosOppIds.get(opp.id)----------'+WinLosOppIds.get(opp.id));
                 system.debug('mergedLosingOppMap.get(WinLosOppIds.get(opp.id)).Online_Enrollment__c'+mergedLosingOppMap.get(WinLosOppIds.get(opp.id)).Online_Enrollment__c);
                //If losing opportunity's online enrollment field is not null then update that OLE opp id
                if(String.isNotBlank(mergedLosingOppMap.get(WinLosOppIds.get(opp.id)).Online_Enrollment__c) && losingOppOleMap.containsKey(mergedLosingOppMap.get(WinLosOppIds.get(opp.id)).Online_Enrollment__c)){
                    List<Online_Enrollment__c> tempOLEList = new List<Online_Enrollment__c>();//This list holds ole that is to be updaetd.
                    tempOLEList.add(losingOppOleMap.get(mergedLosingOppMap.get(WinLosOppIds.get(opp.id)).Online_Enrollment__c));
                    system.debug('tempOLEList========'+tempOLEList);
                    if(tempOLEList!=null && !tempOLEList.isEmpty()){
                        for(Online_Enrollment__c ole:tempOLEList){
                            ole.Opportunity_Id__c = opp.id;
                            losingOppOleListToUpdate.add(ole);
                        }
                    }
                    system.debug('losingOppOleListToUpdate============='+losingOppOleListToUpdate);
                }
            }
            //If losingOppOleListToUpdate is not null update losingOppOleListToUpdate.
            if(losingOppOleListToUpdate!=null && !losingOppOleListToUpdate.isEmpty()){
                recursive.OpptyMergeOLEUpdate = true;
                saveResults = Database.update(losingOppOleListToUpdate,false);
            }
            //Check all save results if any errors are found errors are added in list-errors
            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    for (Database.Error e : saveResult.getErrors()) {
                        errors.add(e.getMessage());
                    }
                }
            }
            system.debug('errors'+errors);
        }
        
        //if any errors are present then return map
        if(errors!=null && !errors.isEmpty()){
            ErrorsMap.put('Online Enrollment',errors);
            return ErrorsMap;
        }
         //if there are  no erros return null
        else{
            return null;
        }
    } 
    //End of online Enrollment record update.
    
}