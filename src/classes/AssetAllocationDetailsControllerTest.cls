/**
 * Created by ravish.chawla on 10/18/2017.
 */

@IsTest
private class AssetAllocationDetailsControllerTest {

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
    static List<Product2> productList = null;
    static List<Project__c> projectList = null;
    static List<Asset> assetList = null;
    static Project_Asset_Allocation__c projectAssetAllocation = null;
    private static SBQQ__Subscription__c subscription;
    private static SubscriptionReplica__c subscriptionReplica;
    private static Project_Subscription_Allocation__c projectSubscriptionAllocation;
    static Contact testContact;

    static testMethod void testAssetAllocationDetails() {

        createTestData();
        createAssets();

        System.debug('projectAssetAllocation1 =>' + projectAssetAllocation);
        ApexPages.StandardController standardController = new ApexPages.StandardController(projectAssetAllocation);
        AssetAllocationDetailsController extensionAllocationDetailsController = new AssetAllocationDetailsController(standardController);
        System.debug('extensionAllocationDetailsController.projectId =>' + extensionAllocationDetailsController.projectId);
        String projectId = extensionAllocationDetailsController.projectId;
        System.debug('projectId =>' + projectId);
        System.assertNotEquals(projectId, null);

        ProjectInfoComponentController testComponentController = new ProjectInfoComponentController();
        testComponentController.setProjectId(projectId);
        testComponentController.getProjectId();
        System.debug('testComponentController.project.Certified_Implementation_Manager__c =>' + testComponentController.project.Certified_Implementation_Manager__c);
        testComponentController.project.Certified_Implementation_Manager__c = testContact.Id;
        testComponentController.enableEdit();
        testComponentController.saveProjectInfo();
        testComponentController.cancel();

        System.debug('testComponentController.project.Certified_Implementation_Manager__c =>' + testComponentController.project.Certified_Implementation_Manager__c);
        System.assertEquals(testContact.Id, testComponentController.project.Certified_Implementation_Manager__c);

    }

    static testMethod void testSubscriptionAllocationDetails() {

        createTestData();
        createSubscription();

        System.debug('projectSubscriptionAllocation =>' + projectSubscriptionAllocation);
        ApexPages.StandardController standardController = new ApexPages.StandardController(projectSubscriptionAllocation);
        SubscriptionAllocationDetailsController extensionAllocationDetailsController = new SubscriptionAllocationDetailsController(standardController);
        System.debug('extensionAllocationDetailsController.projectId =>' + extensionAllocationDetailsController.projectId);
        String projectId = extensionAllocationDetailsController.projectId;
        System.debug('projectId =>' + projectId);
        System.assertNotEquals(projectId, null);

        ProjectInfoComponentController testComponentController = new ProjectInfoComponentController();
        testComponentController.setProjectId(projectId);
        testComponentController.getProjectId();
        System.debug('testComponentController.project.Certified_Implementation_Manager__c =>' + testComponentController.project.Certified_Implementation_Manager__c);
        testComponentController.project.Certified_Implementation_Manager__c = testContact.Id;
        testComponentController.enableEdit();
        testComponentController.saveProjectInfo();
        testComponentController.cancel();

        System.debug('testComponentController.project.Certified_Implementation_Manager__c =>' + testComponentController.project.Certified_Implementation_Manager__c);
        System.assertEquals(testContact.Id, testComponentController.project.Certified_Implementation_Manager__c);

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
        Map<String,Schema.RecordTypeInfo> contactRecordTypeMap = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        testContact = new Contact(
                LastName = 'Contact',
                FirstName = 'ContactTriggerHandlerTest',
                Email = 'contact1@test.com',
                RecordTypeId = contactRecordTypeMap.get('Customer-Other').getRecordTypeId(),
                Account = acct
        );

        insert testContact;

        projectList = new List<Project__c>();

        Project__c project1 = new Project__c();
        project1.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PARENT_SAAS);
        project1.ProjectManager__c = '00539000005M7TO';
        //project1.Projected_Deadline__c = system.today() + 30;
        projectList.add(project1);

        Project__c project2 = new Project__c();
        project2.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PARENT_SAAS);
        project2.ProjectManager__c = '00539000005M7TO';
        //project2.Projected_Deadline__c = system.today() + 30;
        projectList.add(project2);

        Project__c phase1 = new Project__c();
        phase1.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PHASE_SAAS);
        phase1.ProjectManager__c = '00539000005M7TO';
        //phase1.Projected_Deadline__c = system.today() + 30;
        projectList.add(phase1);

        Project__c phase2 = new Project__c();
        phase2.RecordTypeId = recordTypeMap.get(PROJECT_TYPE_PHASE_SAAS);
        phase2.ProjectManager__c = '00539000005M7TO';
        //phase2.Projected_Deadline__c = system.today() + 30;
        projectList.add(phase2);

        insert projectList;

        phase1.ParentProject__c = project1.Id;
        //phase1.Phase_Status__c = 'Closed';
        update phase1;

    }

    static void createAssets()
    {
        assetList = new List<Asset>();

        Asset asset1 = new Asset();
        asset1.RecordTypeId = recordTypeMap.get(ASSET_TYPE_PREMISE);
        asset1.Name = 'AssetTriggerHandlerTest Asset 1';
        asset1.AccountId = acct.Id;
        asset1.Parent_Project__c = projectList[0].Id;
        asset1.Project_Phase__c = projectList[2].Id;
        asset1.Product2Id = productList[0].Id;
        asset1.Quantity = 1;
        asset1.Price = 10.00;
        assetList.add(asset1);

        Asset asset2 = new Asset();
        asset2.RecordTypeId = recordTypeMap.get(ASSET_TYPE_PREMISE);
        asset2.Name = 'AssetTriggerHandlerTest Asset 2';
        asset2.AccountId = acct.Id;
        asset2.Parent_Project__c = projectList[0].Id;
        asset2.Project_Phase__c = projectList[2].Id;
        asset2.Product2Id = productList[0].Id;
        asset2.Quantity = 1;
        asset2.Price = 100.00;
        assetList.add(asset2);

        //create SaaS assets
        Asset asset3 = new Asset();
        asset3.RecordTypeId = recordTypeMap.get(ASSET_TYPE_SAAS);
        asset3.Name = 'AssetTriggerHandlerTest Saas Asset 1';
        asset3.AccountId = acct.Id;
        asset3.Parent_Project__c = projectList[0].Id;
        asset3.Project_Phase__c = projectList[2].Id;
        asset3.Sales_Price__c = 500.00;
        asset3.Quantity = 1.00;
        asset3.Type__c = 'MRC';
        assetList.add(asset3);

        Asset asset4 = new Asset();
        asset4.RecordTypeId = recordTypeMap.get(ASSET_TYPE_SAAS);
        asset4.Name = 'AssetTriggerHandlerTest Saas Asset 1';
        asset4.AccountId = acct.Id;
        asset4.Parent_Project__c = projectList[0].Id;
        asset4.Project_Phase__c = projectList[2].Id;
        asset4.Sales_Price__c = 1000.00;
        asset4.Quantity = 2.00;
        asset4.Type__c = 'NRC';
        assetList.add(asset4);

        insert assetList;
        System.debug('assetList =>' + assetList.size());
        System.debug('assetList[2] =>' + assetList[2]);

        projectAssetAllocation = new Project_Asset_Allocation__c(
                Asset__c = assetList[2].Id,
                Project__c = assetList[2].Project_Phase__c,
                Quantity_Allocation__c = 1

        );

        insert  projectAssetAllocation;
        System.debug('projectAssetAllocation =>' + projectAssetAllocation);


    }

    static void createSubscription(){
        subscription = new SBQQ__Subscription__c();
        subscription.SBQQ__Account__c =  acct.id;
        //subscription.SBQQ__QuoteLine__c = QuoteLine.id;
        subscription.SBQQ__Quantity__c = 10;
        subscription.SBQQ__Product__c = productList[0].Id;
        subscription.Budgeted_Hours__c = 10;
        subscription.Project_Phase__c = projectList[2].Id;

        insert subscription;

        subscriptionReplica = new SubscriptionReplica__c();
        subscriptionReplica = [SELECT Id, Account__c, Product__c, Subscription__r.Project_Phase__c, Quantity__c, Subscription__c FROM SubscriptionReplica__c WHERE Subscription__c = :subscription.Id limit 1];

        projectSubscriptionAllocation = new Project_Subscription_Allocation__c(
                Project__c = subscriptionReplica.Subscription__r.Project_Phase__c,
                Subscription__c  = subscriptionReplica.Id,
                Quantity_Allocation__c = 5
        );
        insert projectSubscriptionAllocation;
    }
}