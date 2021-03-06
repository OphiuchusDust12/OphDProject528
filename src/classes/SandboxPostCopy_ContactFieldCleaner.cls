/**
 * Created by mohandaas.rangaswamy on 12/22/2016.
 */
// Void contacts email
public class SandboxPostCopy_ContactFieldCleaner extends SandboxPostCopyTask{

    public override String getClassName(){
        return 'SandboxPostCopy_ContactFieldCleaner';
    }

    public override string task(SandboxContext context){

        String contactsQuery = 'SELECT ADFSGuid__c, Email FROM Contact where Email != null';
        String sandboxName = context != null ? context.sandboxName() : UserInfo.getUserName().substringAfterLast('.');
        Id batchId = database.executeBatch(new ContactFieldCleaner(contactsQuery, sandboxName));
        system.debug('task(): batchId - '+batchId);
        return batchId;

    }
}