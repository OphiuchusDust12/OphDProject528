/**
 * Created by arnab.karsarkar on 3/15/2017.
 */
public without sharing class KnownIssueImpactCalculationClass {

    private KnownIssuesImpactCalculationInterface impactCalculator;
    private Map<String, Impact_Score_Multiplier__c> multiplierMap;
    private map<Id, integer> KnownIssueIncidentCounts;
    private map<Id, double> KnownIssueIncidentMaxScore;
    private map<Id, string> KnownIssueIncidentMaxPriority;
    private map<Id, integer> KnownIssueIncidentAge;
    private map<Id, double> KnownIssueASVMap;
    private set<id> accountIds;
    private set<Id> KnownIssueSecurityIssues;

    public KnownIssueImpactCalculationClass(KnownIssuesImpactCalculationInterface impactCalculator)
    {
        //store the impactCalculator and the multiplier map for this.
        this.impactCalculator = impactCalculator;
        this.multiplierMap = Impact_Score_Multiplier__c.getAll();
        KnownIssueIncidentCounts  = new map<Id, integer>();
        KnownIssueIncidentAge = new map<Id, integer>();
        KnownIssueIncidentMaxScore= new map<Id, double>();
        KnownIssueASVMap = new map<Id, double>();
        KnownIssueIncidentMaxPriority = new map<Id, string>();
        accountIds = new set<id>();
        KnownIssueSecurityIssues = new Set<Id>();
    }

    public void CalculateKnownIssueScore(list<Case> knownIssueList){
        if(knownIssueList.isEmpty()) {
            system.debug('Known Issue List is empty');
            return;
        }


        set<Id> KnownIssueIds = new set<Id>();
        map<Id, set<Id>> KnownIssueAccounts = new map<Id, set<Id>>();
        double netKnownIssueScore;
        list<Case> updKnowIssueList = new list<Case>();

        for(case c: knownIssueList){
            KnownIssueIds.add(c.Id);
        }

        Try{
            system.debug('CalculateKnownIssueScore in Try');
            GetIncidentValues(KnownIssueIds);
            KnownIssueAccounts = GetAccountsAssociated(KnownIssueIds);
            GetAccountASVValue(KnownIssueAccounts);

            /*system.debug('KnownIssueIncidentAge =>' + KnownIssueIncidentAge);
            system.debug('KnownIssueIncidentAge =>' + KnownIssueIncidentCounts);
            system.debug('KnownIssueIncidentAge =>' + KnownIssueASVMap);*/

            for(Case KnownIssuCase : knownIssueList){
                boolean isBrokenByRelease = GetBrokenByRelease(KnownIssuCase);
                Case newCase = new Case(Id = KnownIssuCase.Id);
                newCase.TotalDaysBugPresent__c = KnownIssueIncidentAge.containsKey(KnownIssuCase.Id)
                                    ?
                                    KnownIssueIncidentAge.get(KnownIssuCase.Id)
                                    : 0;

                newCase.NumberOfIncidents__c = KnownIssueIncidentCounts.containsKey(KnownIssuCase.Id)
                                    ?
                                    KnownIssueIncidentCounts.get(KnownIssuCase.Id)
                                    : 0;

                newCase.ASVValue__c = KnownIssueASVMap.containsKey(KnownIssuCase.Id)
                                    ?
                                    KnownIssueASVMap.get(KnownIssuCase.Id)
                                    :0.0;
                netKnownIssueScore = impactCalculator.CalculateNumberIncidentsTiedToIssue(Integer.valueOf(newCase.NumberOfIncidents__c), GetMultiplierValue('IncidentCount'));
                system.debug('netKnownIssueScore 1 =>' + netKnownIssueScore);
                netKnownIssueScore += impactCalculator.CalculateDaysIssuePresent(Integer.valueOf(newCase.TotalDaysBugPresent__c), GetMultiplierValue('IncidentAge'));
                system.debug('netKnownIssueScore 2 =>' + netKnownIssueScore);
                netKnownIssueScore += KnownIssueIncidentMaxScore.containsKey(KnownIssuCase.Id) ? KnownIssueIncidentMaxScore.get(KnownIssuCase.Id) : 0;
                system.debug('netKnownIssueScore 3 =>' + netKnownIssueScore);
                netKnownIssueScore += impactCalculator.CalculateSecurityIssue(KnownIssueSecurityIssues.contains(newCase.Id), GetMultiplierValue('KI Security Issue'));
                system.debug('netKnownIssueScore 4 =>' + netKnownIssueScore);
                netKnownIssueScore += impactCalculator.CalculateRecentReleaseBreak(isBrokenByRelease, GetMultiplierValue('BrokenByRelease'));
                system.debug('netKnownIssueScore 5 =>' + netKnownIssueScore);
                netKnownIssueScore += impactCalculator.CalculatePriorityScore(KnownIssuCase.Priority, GetMultiplierValue('KI Priority'));
                system.debug('netKnownIssueScore 6 =>' + netKnownIssueScore);

                //track the old value
                if(system.isBatch()) {
                    system.debug('KIImpactScoreHistorical__c set to ' + KnownIssuCase.KIImpactScore__c);
                    newCase.KIImpactScoreHistorical__c = KnownIssuCase.KIImpactScore__c;
                }


                newCase.KIImpactScore__c = netKnownIssueScore;

                updKnowIssueList.add(newCase);
            }
            CaseTriggerHandler.callActionHub = false;
            update updKnowIssueList;
            string body = 'Successfully Updated ' + knownIssueList.size() + ' known issues';
            string subject = 'Success';

        }Catch(Exception ex){
            string body = 'There is an exception occured - ' + ex.getMessage() + ' at line number ' + ex.getLineNumber();
            string subject = 'Error Occured';
            KnownIssueImpactCalculationClass.SendEmail(subject, body);
        }
    }

    private boolean GetBrokenByRelease(case c){
        if(c.Broken_by_Recent_Release__c == 'Yes')
                return true;
        else
                return false;
    }

    private void GetIncidentValues(set<Id> knownIssueIds) {
        AggregateResult[] groupedResults = [
                select KnownIssue__c, Min(CreatedDate) MINDT, Count(Id) CNTID, MAX(IncidentImpactScore__c) MAXSCORE, MIN(Priority) MAXPriority
                from Case
                where KnownIssue__c in :KnownIssueIds
                and RecordType.Name = 'Incident'
                group by KnownIssue__c
        ];
        for (AggregateResult ar : groupedResults)  {
            system.debug('Count =>' + ar.get('CNTID'));
            Id knownIssueId = (ID)ar.get('KnownIssue__c');
            KnownIssueIncidentCounts.put(knownIssueId, Integer.valueOf(ar.get('CNTID')));
            Date minimumDate = Date.valueOf(ar.get('MINDT'));
            integer incidentOpeDays = minimumDate.daysBetween(system.now().dateGMT());
            KnownIssueIncidentAge.put(knownIssueId, incidentOpeDays);
            double maxScore = 0.0;
            if(ar.get('MAXSCORE') != null) {
                maxScore = double.valueOf(ar.get('MAXSCORE'));
            }
            KnownIssueIncidentMaxScore.put(knownIssueId,maxScore);
            KnownIssueIncidentMaxPriority.put(knownIssueId, String.valueOf(ar.get('MAXPriority')));
        }
    }

    //
    private map<Id, set<Id>> GetAccountsAssociated(Set<id> KnownIssueIds){
        map<Id, set<Id>> knownIssueAccountIds = new map<Id, set<Id>>();
        for(Case incidents : [select Id, KnownIssue__c, AccountId, Security_Issue__c from Case where KnownIssue__c in : KnownIssueIds and RecordType.Name = 'Incident']){
            accountIds.add(incidents.AccountId);

            if(incidents.Security_Issue__c == 'Yes')
                KnownIssueSecurityIssues.add(incidents.KnownIssue__c);

            if(knownIssueAccountIds.containsKey(incidents.KnownIssue__c))
                    knownIssueAccountIds.get(incidents.KnownIssue__c).add(incidents.AccountId);// existing knownissue
            else
                    knownIssueAccountIds.put(incidents.KnownIssue__c, new set<Id>{incidents.AccountId});// new knownissue
        }
        return knownIssueAccountIds;
    }

    private void GetAccountASVValue( map<Id, set<Id>> KnownIssueAccounts){
        map<Id, Double> accountASVMap = new map<Id, Double>();

        for(JBCXM__CustomerInfo__c customerInfo : [select Id, JBCXM__ASV__c, JBCXM__Account__c
                                                   FROM JBCXM__CustomerInfo__c
                                                    where JBCXM__Account__c in : accountIds]){

            if(customerInfo.JBCXM__ASV__c != null && customerInfo.JBCXM__ASV__c != 0){
                double ASVinMil = customerInfo.JBCXM__ASV__c.divide(1000000, 2);
                accountASVMap.put(customerInfo.JBCXM__Account__c, ASVinMil);
            }
            else
                accountASVMap.put(customerInfo.JBCXM__Account__c, 0);
        }

        system.debug('KnownIssueAccounts =>' + KnownIssueAccounts);
        for(Id kiId : KnownIssueAccounts.keySet()){
            double totalASVVal = 0.0;
            for(Id acctId : KnownIssueAccounts.get(kiId)){
                if(accountASVMap.containsKey(acctId)){
                    totalASVVal += accountASVMap.get(acctId);
                }
            }
            KnownIssueASVMap.put(kiId, totalASVVal);
        }
    }


    private Decimal GetMultiplierValue(String key)
    {
        //if the key doesn't exist, return 1 as the multiplier
        decimal multiplier = 1.0;
        if(multiplierMap.containsKey(key))
        {
            multiplier = multiplier.setScale(2);
            multiplier = multiplierMap.get(key).Multiplier__c;
            return multiplier;
        }
        else
        {
            return 1.0;
        }
    }

    @TestVisible
    private static void SendEmail(string subject, string body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String OrgId15Digit = UserInfo.getOrganizationId().left(15);
        SiteConfiguration__c siteConfig = SiteConfiguration__c.getInstance(OrgId15Digit);
        if(siteConfig != null){
            String[] toAddresses = new String[]{siteConfig.DeveloperErrorEmail__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }Catch(Exception ex){}
        }

    }


}