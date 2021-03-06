/**
 * Created by jeremy.sparrell on 1/30/2018.
 */

@IsTest
private class ProjectAssetAllocationTriggerTests {
    static final String ACCOUNT_TYPE_CUSTOMERS = 'Customers';
    static final String PROJECT_TYPE_PARENT_SAAS = 'PS Parent Project - SaaS';
    static final String PROJECT_TYPE_PHASE_SAAS = 'PS Project Phase SaaS';
    static final String ASSET_TYPE_PREMISE = 'Premise Asset';
    static final String ASSET_TYPE_SAAS = 'SaaS Asset';

    static final Set<String> recordTypeSet = new Set<String>
    {
            ACCOUNT_TYPE_CUSTOMERS,
            PROJECT_TYPE_PARENT_SAAS,
            PROJECT_TYPE_PHASE_SAAS,
            ASSET_TYPE_PREMISE,
            ASSET_TYPE_SAAS
    };

    static Map<String, Id> recordTypeMap = null;
    static Account acct = null;
    static ImplementedProduct__c implementedProduct = null;
    static List<Product2> productList = null;
    static List<Project__c> projectList = null;
    static List<Asset> assetList = null;
    static Project_Asset_Allocation__c projectAssetAllocation = null;
    static WorkIt2__Session_Type__c session_type;
    static list<WorkIt2__Time_Entry__c> timeEntryList;
    static list<WorkIt2__Timing__c> timings;

    static testMethod void AddParentProjectTest() {

        createTestData();
        createAssets();

        Project_Asset_Allocation__c projectAssetAllocation2 = new Project_Asset_Allocation__c(
                Project__c = projectList[2].id,
                Asset__c = assetList[0].Id,
                Quantity_Allocation__c = 2
        );

        Test.startTest();
            Project_Asset_Allocation__c savedAllocation = [SELECT Id, ParentProjectId__c FROM Project_Asset_Allocation__c WHERE Id = :projectAssetAllocation.Id];
            system.assertEquals(savedAllocation.ParentProjectId__c, projectList[0].Id);

            insert projectAssetAllocation2;

        Project_Asset_Allocation__c implementedAllocation = [SELECT Id, Implemented__c FROM Project_Asset_Allocation__c WHERE Id = :projectAssetAllocation2.Id];
            system.assertEquals(implementedAllocation.Implemented__c, true);
        Test.StopTest();
    }

    static testMethod  void TestTimingError(){
        createTestData();
        createAssets();
        createTimingData();
        try{

            delete projectAssetAllocation;

        }catch (Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Asset Allocation can not be deleted as there are time enteries') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    static testMethod void TestRollup(){
        createTestData();
        createAssets();
        Test.startTest();
            string localProjectId = projectAssetAllocation.Project__c;
            Project__c projBeforeDelete = [select Contracted_NRR__c from Project__c where Id = :localProjectId];
            System.debug('actual NRR before delete ==> ' + projBeforeDelete.Contracted_NRR__c);
            delete projectAssetAllocation;
        Test.StopTest();
        Project__c projafterDelete = [select Contracted_NRR__c from Project__c where Id = :localProjectId];
        System.debug('actual NRR before delete ==> ' + projBeforeDelete.Contracted_NRR__c);
        system.assertEquals(projafterDelete.Contracted_NRR__c, 0);
    }


    static void createTestData()
    {

        recordTypeMap = new Map<String, Id>();
        for(RecordType record : [Select Id, Name from RecordType
        where Name IN :recordTypeSet])
        {
            recordTypeMap.put(record.Name, record.Id);
        }

        createAccount();
        createProducts();
        createProjects();

        Opportunity o = new Opportunity();
        o.RecordTypeId = inContactBaseClass.SelectRecordTypeIDByName('Historical Products', 'Opportunity');
        o.Name = 'test';
        o.CloseDate = system.today().addDays(30);
        o.StageName = 'Open';
        o.AccountId = acct.Id;

        insert o;

        implementedProduct = new ImplementedProduct__c();
        implementedProduct.Account__c = acct.Id;
        implementedProduct.GoLiveDate__c = system.today() - 1;
        implementedProduct.Status__c = 'Implemented';
        implementedProduct.Product__c = 'inContact';
        implementedProduct.Opportunity__c = o.Id;
        insert implementedProduct;


    }

    static void createAccount()
    {

        acct = new Account(
                Name = 'AssetTriggerHandlerTest Account',
                RecordTypeId = recordTypeMap.get(ACCOUNT_TYPE_CUSTOMERS)
        );
        insert acct;
    }

    static void createProducts()
    {
        productList = new List<Product2>();

        Product2 p1 = new Product2();
        p1.Name     = 'AssetTriggerHandlerTest 1';
        p1.ProductCode ='1111';
        p1.Category__c = 'Maintenance';
        productList.add(p1);

        Product2 p2 = new Product2();
        p2.Name     = 'AssetTriggerHandlerTest 2';
        p2.ProductCode ='1097';
        p2.Category__c ='Integration';
        productList.add(p2);

        insert productList;

    }

    static void createProjects()
    {
        projectList = new List<Project__c>();

        Project__c project1 = new Project__c();
        project1.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PARENT_SAAS);
        project1.ProjectManager__c = '00539000005M7TO';
        //project1.Projected_Deadline__c = system.today() + 30;
        projectList.add(project1);

        Project__c phase1 = new Project__c();
        phase1.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PHASE_SAAS);
        phase1.ProjectManager__c = '00539000005M7TO';
        //phase1.Projected_Deadline__c = system.today() + 30;
        projectList.add(phase1);

        Project__c phase2 = new Project__c();
        phase2.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PHASE_SAAS);
        phase2.ProjectManager__c = '00539000005M7TO';
        phase2.Phase_Status__c = 'Closed';
        //phase1.Projected_Deadline__c = system.today() + 30;
        projectList.add(phase2);

        insert projectList;

        phase1.ParentProject__c = project1.Id;
        //phase1.Phase_Status__c = 'Closed';
        update phase1;

        phase2.ParentProject__c = project1.Id;
        //phase1.Phase_Status__c = 'Closed';
        update phase2;

    }

    static void createAssets()
    {
        assetList = new List<Asset>();

        //create SaaS assets
        Asset asset3 = new Asset();
        asset3.RecordTypeId = recordTypeMap.get(ASSET_TYPE_SAAS);
        asset3.Name = 'AssetTriggerHandlerTest Saas Asset 1';
        asset3.AccountId = acct.Id;
        asset3.Parent_Project__c = projectList[0].Id;
        asset3.Project_Phase__c = projectList[1].Id;
        asset3.Sales_Price__c = 500.00;
        asset3.Quantity = 5.00;
        asset3.Type__c = 'MRC';
        assetList.add(asset3);

        //create SaaS assets
        Asset asset4 = new Asset();
        asset4.RecordTypeId = recordTypeMap.get(ASSET_TYPE_SAAS);
        asset4.Name = 'AssetTriggerHandlerTest Saas Asset 2';
        asset4.AccountId = acct.Id;
        asset4.Parent_Project__c = projectList[0].Id;
        asset4.Sales_Price__c = 1000.00;
        asset4.Quantity = 1.00;
        asset4.Type__c = 'NRC';
        assetList.add(asset4);

        insert assetList;
        System.debug('assetList =>' + assetList.size());


        projectAssetAllocation = new Project_Asset_Allocation__c(
                Asset__c = assetList[0].Id,
                Project__c = projectList[1].id,
                Quantity_Allocation__c = 2

        );

        insert  projectAssetAllocation;
        System.debug('projectAssetAllocation =>' + projectAssetAllocation);
    }

    static void createTimingData(){
        session_type = new WorkIt2__Session_Type__c(
                Name = 'Reviewing Details Test',
                WorkIt2__Priority__c = 50
        );

        insert session_type;

        timings = new list<WorkIt2__Timing__c>();

        WorkIt2__Timing__c subscription_timing = new WorkIt2__Timing__c(
                Project_Asset_Allocation__c = projectAssetAllocation.Id
        );

        timings.add(subscription_timing);

        insert timings;

        timeEntryList = new list<WorkIt2__Time_Entry__c>();

        WorkIt2__Time_Entry__c time_entry1 = new WorkIt2__Time_Entry__c(
                WorkIt2__Session_Type__c = session_type.Id,
                WorkIt2__Start__c = System.now().addHours(-1),
                WorkIt2__Timing__c = timings[0].Id
        );
        timeEntryList.add(time_entry1);


        insert timeEntryList;

    }
}