public class recursive{
 public static Boolean OleToContact = false;//This boolean is to prevent recurssion when contact is updated from OLE
 public static Boolean ContactOCR = false;//This Boolean is to prevent recurssion 
 public Static Boolean OLEToOpp = false;//This boolean is to prevent recurssion when Opportunity is updated from OLE and vice versa
 public static Boolean OLEToOp = false;//This boolean is to prevent recurssion when Opportunity Provider is updated from OLE and vice versa
 public static Boolean OpptyMergeOLEUpdate = false;//This Boolean is used to prevent after update trigger of online enrollment not to fire
 //public static Boolean OpUpdateOnMerge= false;//This Boolean is used to prevent afterupdate trigger on opportunity provider as we arewhich updates OLE
}