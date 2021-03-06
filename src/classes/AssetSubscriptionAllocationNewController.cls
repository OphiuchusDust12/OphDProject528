/**
 * Created by ravish.chawla on 10/12/2017.
 */

public with sharing class AssetSubscriptionAllocationNewController {

    // current asset record
    public Asset Asset{
        get {
            return helper != null
                    ? helper.currentAsset : null;
        }set{}
    }

    // current subscription record
    public SubscriptionReplica__c Subscription{
        get {
            return helper != null
                    ? helper.currentSubscription : null;
        }set{}
    }

    // current project record
    public Project__c Project{
        get {
            return helper != null
                    ? helper.currentProject : null;
        }set{}
    }

    Public boolean Manager{
        get{
            return helper != null
                    ? helper.isManager() : null;
        }set{}
    }

    // query string parameter
    public String currentId{get;set;}

    public boolean saveSuccess{get; set;}

    public list<ImplementedProduct__c> ImplementedProducts{get;private set;}
    public boolean showdeleteButton{get; set;}
    // query string parameter
//    public Boolen isSuccesfullySaved{get;set;}
    //Helper Object
    private AssetSubscriptionAllocationHelper helper;



    // constructor
    public AssetSubscriptionAllocationNewController(){

        ImplementedProducts = new list<ImplementedProduct__c>();
        currentId = ApexPages.currentPage().getParameters().get('id');
        saveSuccess = true;
        showdeleteButton = false;
        system.debug('getAsset(): currentId - ' + currentId);

        if(String.isBlank(currentId)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid URL: Missing ID Parameter.'));
            return;
        }

        helper = new AssetSubscriptionAllocationHelper(currentId);
        ImplementedProducts = helper.currentImplementedProducts;
    }

    public void reloadDetails(){
        helper = new AssetSubscriptionAllocationHelper(currentId);
        this.Asset = helper.currentAsset != null ? helper.currentAsset : null;
        this.Subscription = helper.currentSubscription != null ? helper.currentSubscription : null;
        this.Project = helper.currentProject != null ? helper.currentProject : null;

    }


    //Get object type from ID
    @RemoteAction
    public static String getObjectType(String idParam){
        String objType;
        objType = AssetSubscriptionAllocationHelper.getSObjectType(idParam);
        return objType;
    }

    //Get Asset Allocations Data
    @RemoteAction
    public static String getAssetAllocationData(String projectId, String idParam){
        String assetAllocationData = AssetSubscriptionAllocationHelper.getAssetAllocations(projectId, idParam);
        return assetAllocationData;
    }

    //Get Subscription Allocations Data
    @RemoteAction
    public static String getSubscriptionAllocationData(String projectId, String idParam){
        String subscriptionAllocationData = AssetSubscriptionAllocationHelper.getSubscriptionAllocations(projectId, idParam);
        return subscriptionAllocationData;
    }


    @RemoteAction
    public static String PhaseProjectDetails(String objId, string objType){
        String ProjectData = AssetSubscriptionAllocationHelper.getPhaseProjectDetails(objId, objType);
        return ProjectData;
    }

    @RemoteAction
    public static String UpsertAssetSubscriptionAllocation(String objType, String allocationJson){
        String result;
        String message = '';
        try{
            system.debug('UpsertAssetSubscriptionAllocation(): allocationJson - '+allocationJson);
            AssetSubscriptionAllocationNewModel assetSubscriptionAllocation = (AssetSubscriptionAllocationNewModel)JSON.deserialize(allocationJson, AssetSubscriptionAllocationNewModel.class);
            AssetSubscriptionAllocationHelper.SaveAssetSubscriptionAllocation(objType, assetSubscriptionAllocation);
            result = 'Success';
        }
        catch (DmlException ex){
            result = 'Failed';
            message = ex.getMessage();

            if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
	            message = simplyfyErrorMessage(message);
            }
            else {
                message = ex.getMessage();
            }

        }
        return sendResponse(result, message);

    }

    @RemoteAction
    public static String AssetSubscriptionDetailsFromProjectPhase(String projId, String objType){
        String assetSubscriptionData = AssetSubscriptionAllocationHelper.getAssetSubscriptionDetailsFromProjectPhase(projId, objType);
        return assetSubscriptionData;
    }

    @RemoteAction
    public static String DeleteAllocation(String allocationId, String objType){
        String result;
        try{
            result = AssetSubscriptionAllocationHelper.DeleteAllocation(allocationId, objType);

            if (result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){

            }

        }catch (Exception ex){
            result = 'Failed' + ex.getMessage();
        }

        return result;
    }

	@RemoteAction
	public static string SaveAllAllocation(string assetIdList,string subscriptionIdList, string projectId){
		String result;
		list<string> assetIds = new list<string>();
		list<string> subscriptionIds = new list<string>();
		if(assetIdList != null)
			assetIds =  (List<string>)System.JSON.deserialize(assetIdList, List<string>.class);
		if(subscriptionIdList != null)
			subscriptionIds =  (List<string>)JSON.deserialize(subscriptionIdList, List<string>.class);
		result = AssetSubscriptionAllocationHelper.SaveAllAllocations(assetIds,subscriptionIds,projectId);

		if (result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
			result = simplyfyErrorMessage(result);
		}

		return result;
	}

    @RemoteAction
    public static String SearchUsers(String searchString){

        try{

            return AssetSubscriptionAllocationHelper.getUser(searchString);

        }catch (Exception ex){
           return 'Failed' + ex.getMessage();
        }

    }

    public void SaveCancSuspQuantity(){
        try{
            String message =  helper.SaveCancSuspQuantity(Asset);
            saveSuccess = true;
            showdeleteButton = false;
            if(message.contains('Saved')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
                saveSuccess = true;
            }
            else {
               // getUpdatedCancSuspValues();
                System.debug('came back from helper method');
                if(message.contains('modify or delete'))
                    showdeleteButton = true;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
                saveSuccess = false;

            }

        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }

    }

    public void SaveCancSuspQuantitySubs(){
        System.debug('Subscription.QuantityCancelled__c' + Subscription.QuantityCancelled__c);
        try{
            saveSuccess = true;
            showdeleteButton = false;
            String message =  helper.SaveCancSuspQuantitySubs(Subscription);
            if(message.contains('Saved')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
                saveSuccess = true;
            }
            else {
                if(message.contains('modify or delete'))
                        showdeleteButton = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
                saveSuccess = false;
            }
        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            saveSuccess = false;
        }

    }

    public void deleteAssetAllocation(){
        try{
           string result = helper.deleteNonImplementedAssetAllocations(Asset.Id);

            if (result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
	            result = AssetSubscriptionAllocationNewController.simplyfyErrorMessage(result);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result));
            }else if(result != 'success'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result));
            }

            if(result == 'success'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Allocations were deleted successfully.'));
                showdeleteButton = false;
                reloadDetails();
            }

        }catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            saveSuccess = false;
        }
    }

    public void deleteSubsAllocation(){
        string result = helper.deleteNonImplementedSubsAllocations(Subscription.Id);
        if (result.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            result = AssetSubscriptionAllocationNewController.simplyfyErrorMessage(result);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result));
        }else if(result != 'success'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result));
        }

        if(result == 'success'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Allocations were deleted successfully.'));
            showdeleteButton = false;
            reloadDetails();
        }
    }


    public void saveImplementedProduct(){
        if(Asset != null){
            String SelectedRowId = ApexPages.CurrentPage().getParameters().get('rowid');
            helper.SaveImmplementedProductAsset(Asset.Id, SelectedRowId);
        }
        if(Subscription != null){
            String SelectedRowId = ApexPages.CurrentPage().getParameters().get('rowid');
            helper.SaveImmplementedProductSubscription(Subscription.Id, SelectedRowId);
        }
        reloadDetails();
    }

	@RemoteAction
	public static string CancelAllocations(string projectId){
		if(projectId != null){
			string message = AssetSubscriptionAllocationHelper.CancelAllAllocations(projectId);
			return message;
		}
		return null;
	}

	@RemoteAction
    public static string ManageOnHoldAllocations(string projectId, boolean onHold){
        if(projectId != null){
            string message = AssetSubscriptionAllocationHelper.updateOnHoldAllocations(projectId, onHold);
            return message;
        }
        return null;
    }

    public pagereference cancel(){
        return new PageReference('/'+currentId).setRedirect(true);
    }

    private static string sendResponse(String result, string message){
        System.JSONGenerator generator = Json.createGenerator(true);
        generator.writeStartObject();
        generator.writeStringField('result', result);
        generator.writeStringField('message', message);
        return generator.getAsString();

    }

    private static string simplyfyErrorMessage(string result){
        Integer occurence;
        occurence = result.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
        result = result.mid(occurence, result.length());
        occurence = result.lastIndexOf(':');
        result = result.mid(0, occurence);
        return result;
    }

}