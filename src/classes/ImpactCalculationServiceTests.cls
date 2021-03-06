@isTest
public class ImpactCalculationServiceTests {

    static testMethod void CalculateIncidentNetScore_WillSetScoreCorrectly() {

        Case[] caseList = new Case[]{
                new Case(
                        Severity__c = 's1',
                        RepeatIssue__c = 'yes',
                        Security_Issue__c = 'no',
                        Related_to_Previous_Known_Issue__c = 'no'
                )
        };

        // Set stub methods to always return the same value

        IncidentImpactCalculationStub calculationStub = new IncidentImpactCalculationStub();
        calculationStub.IncidentIdentityScore = 1;
        calculationStub.RepeatIssueScore = 1;
        calculationStub.SecurityIssueScore = 1;
        calculationStub.RelatedKnownIssueScore = 1;

        ImpactCalculationService impactService = new ImpactCalculationService(calculationStub);

        impactService.CalculateIncidentNetScore(caseList);

        for (Case caseRecord : caseList) {
            system.assertEquals(4, caseRecord.Incident_Net_Score__c);
        }
    }

    static testMethod void CalculateAccountScore_WillSetScoreCorrectly() {
        Map<String,Schema.RecordTypeInfo> accountRecordTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Account[] accountList = new Account[]{
                new Account(
                        Name = 'My little Account',
                        Risk_of_Leaving__c = 'High', // High
                        CustomerSegment__c = 'Strategic', // 1
                        RecordTypeId = accountRecordTypeMap.get('Customers').getRecordTypeId(),
                        Brand_Visibility__c = 'no', // 0,
                        Industry_Leadership_Vocality__c = 'no', // 0
                        Social_Media_Presence__c = 'no', // 0
                        Referenceable__c = false  // 1
                )
        };

        AccountImpactCalculationStub accountImpactCalculationStub = new AccountImpactCalculationStub();
        accountImpactCalculationStub.AgeOfCustomerInMonthsScore = 0;
        accountImpactCalculationStub.RiskOfLeavingScore = 1;
        accountImpactCalculationStub.StrategicAccountScore = 1;
        accountImpactCalculationStub.PartnerAccountScore = 0;
        accountImpactCalculationStub.BrandVisibilityScore = 1;
        accountImpactCalculationStub.IndustryLeaderScore = 1;
        accountImpactCalculationStub.SocialMediaPresenceScore = 1;
        accountImpactCalculationStub.CurrentReferenceScore = 1;

        ImpactCalculationService impactService = new ImpactCalculationService(accountImpactCalculationStub);

        impactService.CalculateAccountNetScore(accountList);


        for(Account accountRecord : accountList){
            system.assertEquals(6, accountRecord.Account_Net_Score__c);
        }
    }

    static testMethod void CalculateGainsightNetScore_WillSetScoreCorrectly() {
        Account[] accountList = new Account[]{
                new Account(
                        Name = 'My little Account'
                )
        };

        insert accountList;

        JBCXM__CustomerInfo__c[] customerInfoRecords = new JBCXM__CustomerInfo__c[]{
                new JBCXM__CustomerInfo__c(
                        JBCXM_Credits__c = 2,
                        JBCXM__Account__c = accountList[0].Id,
                        JBCXM__MRR__c = 5000
                )
        };
        customerInfoRecords[0].recalculateFormulas();
        GainsightImpactCalculationStub gainsightImpactCalculationStub = new  GainsightImpactCalculationStub();
        gainsightImpactCalculationStub.MrrValueScore = 1;
        gainsightImpactCalculationStub.CreditGivenLastTwelveMonthsScore = 1;
        gainsightImpactCalculationStub.HealthScore = 0;

        ImpactCalculationService impactService = new ImpactCalculationService(gainsightImpactCalculationStub);

        impactService.CalculateGainsightNetScore(customerInfoRecords);

        for(Account accountRecord :[Select Gainsight_Net_Score__c from Account]){
            system.assertEquals(2, accountRecord.Gainsight_Net_Score__c);
        }
    }
}