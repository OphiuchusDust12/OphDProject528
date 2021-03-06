public without sharing class PSProjectAssetAttachment {

    public static void AttachAssetsByIdToParentProject (set<id> QouteLineids, set<id>AssetsIds, set<id> SubscriptionsIds ){
        //should pass in ids of duplicate assets
        map<id, list<Asset>> opportunityAssetsByIds = new map<id, list<Asset>>();
        map<id, list<SubscriptionReplica__c>> opportunitySubscriptionsByIds = new map<id, list<SubscriptionReplica__c>>();
        set<id> opportunityIds = new set<id>();
        set<id> projectIds = new set<id>();
        list<asset> lstAssets = new list<Asset>();
        list<SubscriptionReplica__c> lstSubscriptionReplicas = new list<SubscriptionReplica__c>();
        list<Project__c> lstProjects = new list<Project__c>();
        try{
            //get all Subscriptions/Assets from the QuoteLines
            for ( SBQQ__QuoteLine__c quoteLine : [select SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                                    (select id from SBQQ__Assets__r where id in : AssetsIds),
                                                    (select id from Subscriptions_Custom__r where id in : SubscriptionsIds)
                                                    from SBQQ__QuoteLine__c where id in : QouteLineids]){

                opportunityIds.add(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                if(AssetsIds.size() > 0){
                    if(!opportunityAssetsByIds.containsKey(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                        opportunityAssetsByIds.put(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c, new List<Asset>(quoteLine.SBQQ__Assets__r));
                    }
                    else{
                        opportunityAssetsByIds.get(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(quoteLine.SBQQ__Assets__r);
                    }
                }
                else if(SubscriptionsIds.size() > 0){
                    if(!opportunitySubscriptionsByIds.containsKey(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                        opportunitySubscriptionsByIds.put(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c, new List<SubscriptionReplica__c>(quoteLine.Subscriptions_Custom__r));
                    }
                    else{
                        opportunitySubscriptionsByIds.get(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(quoteLine.Subscriptions_Custom__r);
                    }
                }

            }
            // if there are related opportinuties found attach the Parent project of the opportunities to the Assets/subscriptions
            if(opportunityIds.size() > 0){

                for(AggregateResult agr: [select Opportunity__c,Max(Id) maxId
                                            from Project__c
                                            where Opportunity__c in : opportunityIds
                                            And RecordType.Name like  '%Parent%'
                                            Group By Opportunity__c]){
                    string projectId = (string)agr.get('maxId');
                    string oppyId = (string)agr.get('Opportunity__c');
                    projectIds.add(projectId);
                    if(opportunityAssetsByIds.size() > 0){
                        for(Asset a : opportunityAssetsByIds.get(oppyId)){
                            Asset asset = new Asset(Id = a.Id);
                            asset.Parent_Project__c =projectId;
                            lstAssets.add(asset);

                        }
                    }
                    else if(opportunitySubscriptionsByIds.size() > 0){
                        for(SubscriptionReplica__c s : opportunitySubscriptionsByIds.get(oppyId)){
                            SubscriptionReplica__c subs = new SubscriptionReplica__c(Id = s.Id);
                            subs.ParentProject__c = projectId;
                            lstSubscriptionReplicas.add(subs);

                        }
                    }

                }

                if(projectIds.size() > 0){
                    for(Project__c proj :[select Id, Status__c,
                    (select Id from Assets__r)
                    From Project__c
                    Where id in : projectIds and Status__c = '0 - PreSale']){
                        if(proj.Assets__r.size() <= 0){
                            Project__c newProject = new Project__c(Id = proj.Id);
                            newProject.Status__c = '1 - Open';
                            lstProjects.add(newProject);
                        }
                    }
                }
                // update all the list
                if(lstAssets.size() > 0){
                    update lstAssets;
                }
                if(lstSubscriptionReplicas.size() > 0){
                    update lstSubscriptionReplicas;
                }
                if(lstProjects.size() > 0){
                    update lstProjects;
                }

            }

        }catch (Exception ex){
            inContactBaseClass.SendErrorEmail( ex, null);
        }

    }

}