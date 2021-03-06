/**
 * Created by ravish.chawla on 5/24/2017.
 */

@IsTest
public class XMBusinessLayerTest {
    static final String CUSTOMER_CONTACT = 'Customer-Other';
    public static testMethod void TestGetGroupListByUserid() {

        XMRestGroupMockHttpGenerator fakeResponse = new XMRestGroupMockHttpGenerator(200,'Complete','[{"Name": "sForceTest1"}]',null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        setup();
        test.startTest();
        Contact testContact = [select id from contact limit 1];
        XMBusinessLayer xmBusinessLayer = new XMBusinessLayer(testContact.Id, 'eventType');
        Map<String, XMGroupProductCluster> groupListByUserId = xmBusinessLayer.GetGroupListByUserid();
        test.stopTest();
        System.debug('groupListByUserIdTest -->' + groupListByUserId);
    }


    public static testMethod void TestUpdateXMUserToGrouops() {

        XMRestGroupMockHttpGenerator fakeResponse = new XMRestGroupMockHttpGenerator(200,'Complete','[{"Name": "sForceTest1"}]',null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        setup();

        test.startTest();



        List<XMGroupProductCluster> groupListTest = new List<XMGroupProductCluster>();

        List<xmPersonMemberModel> deviceList1 = new List<xmPersonMemberModel>();
        xmPersonMemberModel device1 = new xmPersonMemberModel();
        device1.id = '1234453223525';
        device1.targetName= 'testTargetName1';
        device1.recipientType= 'testRecipientType1';
        device1.links = new xmGroupLinkModel();
        device1.checked= true;

        xmPersonMemberModel device2 = new xmPersonMemberModel();
        device2.id = '123443223525';
        device2.targetName= 'testTargetName2';
        device2.recipientType= 'testRecipientType2';
        device2.links = new xmGroupLinkModel();
        device2.checked= false;

        xmPersonMemberModel device3 = new xmPersonMemberModel();
        device3.id = '123445322525';
        device3.targetName= 'testTargetName3';
        device3.recipientType= 'testRecipientType3';
        device3.links = new xmGroupLinkModel();
        device3.checked= true;

        deviceList1.add(device1);
        deviceList1.add(device2);
        deviceList1.add(device3);



        XMGroupProductCluster groupProClusterTest1 = new XMGroupProductCluster();
        groupProClusterTest1.Product = 'inContact';
        groupProClusterTest1.Cluster = 'C9 - inContact';
        groupProClusterTest1.PartnerPrefix = 'TestPartnerPrefix2';
        groupProClusterTest1.XmattersGroupName = 'TestXmattersGroupName2';
        groupProClusterTest1.Devices = deviceList1;
        groupProClusterTest1.selected = true;
        groupListTest.add(groupProClusterTest1);



        XMGroupProductCluster groupProClusterTest2 = new XMGroupProductCluster();
        groupProClusterTest2.Product = 'NICE WFM - IEX';
        groupProClusterTest2.Cluster = 'NWFM 1-2 - inContact';
        groupProClusterTest2.PartnerPrefix = 'TestPartnerPrefix2';
        groupProClusterTest2.XmattersGroupName = 'TestXmattersGroupName2';
        groupProClusterTest2.Devices = deviceList1;
        groupProClusterTest2.selected = false;
        groupListTest.add(groupProClusterTest2);

        XMBusinessLayer xmBusinessLayer = new XMBusinessLayer();
        XMDeviceWrapper[] newDeviceList = new XMDeviceWrapper[]{};
        newDeviceList.add(new XMDeviceWrapper());
       // xmBusinessLayer.AddMissingDevicesToList(newDeviceList, groupListTest);
        String responseMessageTest = xmBusinessLayer.UpdateXMUserToGroups(groupListTest, 'aefgh-1234-cdeft');


        test.stopTest();
        System.debug('responseMessageTest -->' + responseMessageTest);
    }

    public static void setup(){
        //setup test data

        Id rtCustOther = '01270000000Lrn4AAC';

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.CadebillAccountNo__c = 9999999;
        acc.NICE_QM_Cluster__c = 'EN1';
        acc.NICE_WFM_Cluster__c = 'NWFM 1-2';
        acc.Verint_Cluster__c = 'V1';
        acc.inContact_Cluster__c =  'C9';

        insert acc;

        xmPerson__c person = new xmPerson__c(
                xmPersonUID__c = 'aefgh-1234-cdeft'
        );
        insert person;

        Map<String, RecordTypeInfo> recordTypeMap = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        Contact testContact = new Contact(
                FirstName = 'XMPersonManagementControllerTest',
                LastName = 'Contact',
                Email = 'contact1@incontact.com',
                RecordTypeId = recordTypeMap.get(CUSTOMER_CONTACT).getRecordTypeId(),
                AccountId = acc.Id,
                xmPerson__c = person.Id
        );

        insert testContact;

        Opportunity o = new Opportunity();
        o.RecordTypeId = inContactBaseClass.SelectRecordTypeIDByName('Historical Products', 'Opportunity');
        o.Name = 'test';
        o.CloseDate = system.today().addDays(30);
        o.StageName = 'Open';
        o.AccountId = acc.Id;

        insert o;

        ImplementedProduct__c ip1 = new ImplementedProduct__c();
        ip1.Account__c = acc.Id;
        ip1.GoLiveDate__c = system.today() - 1;
        ip1.Status__c = 'Implemented';
        ip1.Product__c = 'inContact';
        ip1.Opportunity__c = o.Id;
        insert ip1;


        ImplementedProduct__c ip2 = new ImplementedProduct__c();
        ip2.Account__c = acc.Id;
        ip2.GoLiveDate__c = system.today() - 1;
        ip2.Status__c = 'Implemented';
        ip2.Product__c = 'NICE QM - Engage';
        ip2.Opportunity__c = o.Id;
        insert ip2;

        ImplementedProduct__c ip3 = new ImplementedProduct__c();
        ip3.Account__c = acc.Id;
        ip3.GoLiveDate__c = system.today() - 1;
        ip3.Status__c = 'Implemented';
        ip3.Product__c = 'NICE WFM - IEX';
        ip3.Opportunity__c = o.Id;
        insert ip3;

        ImplementedProduct__c ip4 = new ImplementedProduct__c();
        ip4.Account__c = acc.Id;
        ip4.GoLiveDate__c = system.today() - 1;
        ip4.Status__c = 'Implemented';
        ip4.Product__c = 'NICE WFM - NQM';
        ip4.Opportunity__c = o.Id;
        insert ip4;



        ProductEventMap__c pem = new ProductEventMap__c();
        pem.Name = 'inContact';
        pem.Product__c = 'inContact';
        pem.ImplementedProduct__c = 'inContact';
        pem.Platform__c = 'Cluster - inContact';
        pem.HasClusters__c = true;

        insert pem;

        ProductEventMap__c pem1 = new ProductEventMap__c();
        pem1.Name = 'NICE QM - Engage';
        pem1.Product__c = 'NICE QM - Engage';
        pem1.ImplementedProduct__c = 'NICE QM - Engage';
        pem1.Platform__c = 'Verint - inContact';
        pem1.HasClusters__c = true;

        insert pem1;

        ProductEventMap__c pem2 = new ProductEventMap__c();
        pem2.Name = 'NICE WFM - IEX';
        pem2.Product__c = 'NICE WFM - IEX';
        pem2.ImplementedProduct__c = 'NICE WFM - IEX';
        pem2.Platform__c = 'NWFM - inContact';
        pem2.HasClusters__c = true;

        insert pem2;

        ProductEventMap__c pem3 = new ProductEventMap__c();
        pem3.Name = 'NICE WFM - NQM';
        pem3.Product__c = 'NICE WFM - NQM';
        pem3.ImplementedProduct__c = 'NICE WFM - NQM';
        pem3.Platform__c = 'NQM - inContact';
        pem3.HasClusters__c = true;

        insert pem3;
    }

}