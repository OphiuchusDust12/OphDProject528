/**
 * Created by mohandaas.rangaswamy on 12/11/2017.
 */

public class TimingTriggerHandler extends TriggerHandler{

    protected override void afterUpdate(){

        rollupTimeToAssetAllocation();

    }

    private static void rollupTimeToAssetAllocation(){

        Set<Id> assetAllocationIds = new Set<Id>();
//        Set<Id> subscriptionAllocationIds = new Set<Id>();

        List<WorkIt2__Timing__c> newList = (List<WorkIt2__Timing__c>) trigger.new;
        Map<Id, WorkIt2__Timing__c> oldMap = (Map<Id, WorkIt2__Timing__c>) trigger.oldMap;

        for(WorkIt2__Timing__c newTime : newList){

            WorkIt2__Timing__c oldTime = oldMap.get(newTime.Id);

            if(newTime.Project_Asset_Allocation__c != null && newTime.Closed_Sessions__c != oldTime.Closed_Sessions__c){
                assetAllocationIds.add(newTime.Project_Asset_Allocation__c);
            }

            /*if(newTime.Project_Subscription_Allocation__c != null && newTime.Closed_Sessions__c != oldTime.Closed_Sessions__c){
                subscriptionAllocationIds.add(newTime.Project_Subscription_Allocation__c);
            }*/

        }

        system.debug(' **** TimingTriggerHandler(): assetAllocationIds - ' + assetAllocationIds);

        if(assetAllocationIds.size() > 0){
            return;
        }

        List<Project_Asset_Allocation__c> allocations = new List<Project_Asset_Allocation__c>();

        for(AggregateResult ar : [
                Select sum(WorkIt2__Time_In_Hours__c) totalHours, Project_Asset_Allocation__c
                from WorkIt2__Timing__c
                where Project_Asset_Allocation__c IN :assetAllocationIds
                group by Project_Asset_Allocation__c
        ]){

            system.debug(' **** TimingTriggerHandler(): ar - ' + ar);

            if(ar.get('Project_Asset_Allocation__c') != null){
                Project_Asset_Allocation__c allocation = new Project_Asset_Allocation__c(
                        Id = (Id) ar.get('Project_Asset_Allocation__c'),
                        Logged_Hours__c = ar.get('totalHours') == null ? 0 : (Decimal) ar.get('totalHours')
                );

                allocations.add(allocation);
            }
        }

        system.debug(' **** TimingTriggerHandler(): allocations - ' + allocations);

        if(allocations.size() > 0){

            try{
                update allocations;
            } catch (Exception ex){
                system.debug('**** rollupTimeToAssetAllocation(): Exception - ' + ex);
            }

        }

    }

}