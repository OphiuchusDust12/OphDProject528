public class AssetSubscriptionAllocationModel {

    public integer rowid{get;set;}
    public boolean isDelete{get;set;}
    public boolean isError{get;set;}
    public boolean isQuantityAllocation{get;set;}
    public boolean isPercentageAllocation{get;set;}
    public boolean isAllocatedHours{get;set;}
    public string message{get;set;}
    public Project_Asset_Allocation__c assetAllocation{get; set;}
    public Project_Subscription_Allocation__c subscriptionAllocation{get;set;}

    public AssetSubscriptionAllocationModel(Asset currentAsset, Project__c currentProject, Integer row){

        this.assetAllocation = new Project_Asset_Allocation__c(
                Asset__c = currentAsset != null ? currentAsset.Id : null,
                Asset__r = currentAsset != null ? currentAsset : null,
                project__c = currentProject != null ? currentProject.id : null
        );
        this.isQuantityAllocation = (currentAsset != null && currentAsset.Quantity > 1);
        this.isPercentageAllocation = (currentAsset != null && currentAsset.Budgeted_Hours__c > 0 && currentAsset.Quantity <= 1);
        this.isAllocatedHours = (currentAsset != null && currentAsset.Quantity > 1 && currentAsset.Budgeted_Hours__c > 0);
        this.rowid = row;
        this.isDelete = false;

        if(currentAsset != null){
            List<Asset> assetList = new List<Asset>([select RemainingQuantity__c, Remaining_Hours__c,
                    Remaning_Percentage__c from Asset where Id =: currentAsset.Id LIMIT 1]);

            if(this.isQuantityAllocation){
                this.assetAllocation.Quantity_Allocation__c = assetList[0].RemainingQuantity__c;
            }
            if(this.isAllocatedHours){
                this.assetAllocation.Hours_Allocated__c = assetList[0].Remaining_Hours__c;
            }
            if(this.isPercentageAllocation){
                this.assetAllocation.Percent_Allocation__c = assetList[0].Remaning_Percentage__c;
            }
        }



    }

    public AssetSubscriptionAllocationModel(Project_Asset_Allocation__c allocation, Integer row){

        this.assetAllocation = allocation;
        this.isQuantityAllocation = (allocation.Asset__c != null && allocation.Asset__r.Quantity > 1);
        this.isPercentageAllocation = (allocation.Asset__c != null && allocation.Asset__r.Budgeted_Hours__c > 0 && allocation.Asset__r.Quantity <= 1);
        this.isAllocatedHours = (allocation.Asset__c != null && allocation.Asset__r.Quantity > 1 && allocation.Asset__r.Budgeted_Hours__c > 0);
        this.rowid = row;
        this.isDelete = false;

    }

    public AssetSubscriptionAllocationModel(SubscriptionReplica__c currentSubscription, Project__c currentProject, Integer row){

        this.subscriptionAllocation = new Project_Subscription_Allocation__c(
                Subscription__c = currentSubscription != null ? currentSubscription.Id : null,
                Subscription__r = currentSubscription != null ? currentSubscription : null,
                project__c = currentProject != null ? currentProject.id : null
        );
        this.isQuantityAllocation = (currentSubscription != null && currentSubscription.Quantity__c > 1);
        this.isPercentageAllocation = (currentSubscription != null && currentSubscription.Budgeted_Hours__c > 0 && currentSubscription.Quantity__c <= 1);
        this.isAllocatedHours = (currentSubscription != null && currentSubscription.Quantity__c > 1 && currentSubscription.Budgeted_Hours__c > 0);
        this.rowid = row;
        this.isDelete = false;

        if(currentSubscription != null){
            List<SubscriptionReplica__c> subscriptionList = new List<SubscriptionReplica__c>([select RemainingQuantity__c, Remaining_Hours__c,
                    Remaning_Percentage__c from SubscriptionReplica__c where Id =: currentSubscription.Id LIMIT 1]);

            if(this.isQuantityAllocation){
                this.subscriptionAllocation.Quantity_Allocation__c = subscriptionList[0].RemainingQuantity__c;
            }
            if(this.isAllocatedHours){
                this.subscriptionAllocation.Hours_Allocated__c = subscriptionList[0].Remaining_Hours__c;
            }
            if(this.isPercentageAllocation){
                this.subscriptionAllocation.Percent_Allocation__c = subscriptionList[0].Remaning_Percentage__c;
            }
        }

    }

    public AssetSubscriptionAllocationModel(Project_Subscription_Allocation__c allocation, Integer row){

        this.subscriptionAllocation = allocation;
        this.isQuantityAllocation = (allocation.Subscription__c != null && allocation.Subscription__r.Quantity__c > 1);
        this.isPercentageAllocation = (allocation.Subscription__c != null && allocation.Subscription__r.Budgeted_Hours__c > 0 && allocation.Subscription__r.Quantity__c <= 1);
        this.isAllocatedHours = (allocation.Subscription__c != null && allocation.Subscription__r.Quantity__c > 1 && allocation.Subscription__r.Budgeted_Hours__c > 0);
        this.rowid = row;
        this.isDelete = false;

    }    

}