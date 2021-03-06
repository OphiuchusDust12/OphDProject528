public class FeedCommentTriggerHandler extends TriggerHandler 
{

    public static String DEVELOPMENT_REVIEW_CHATTER_GROUP = 'Salesforce Development Review';

    private Id developmentReviewGroup;
    private boolean qaTestsFired = false;

    public FeedCommentTriggerHandler(){}
    
    public override void afterInsert()
    {
        SetDevReviewGroup();
        
        for(FeedComment fc:(List<FeedComment>)trigger.new)
        {
            RunQAUnitTests(fc);
        }
    }
    
    private void SetDevReviewGroup()
    {     
        try
        {
            developmentReviewGroup = [SELECT Id FROM CollaborationGroup WHERE Name = :DEVELOPMENT_REVIEW_CHATTER_GROUP].Id;
        }
        catch(Exception ex)
        {
            developmentReviewGroup = null;
            try
            {
            	inContactBaseClass.SendErrorEmail(ex, 'Salesforce Development Review chatter group not found.');
            }
            catch(Exception ex2){}	//don't error if email is shut off
        }
        
    }
    
    private void RunQAUnitTests(FeedComment fc)
    {
        
        if(developmentReviewGroup != null && !qaTestsFired)
        {
            if(fc.ParentId == developmentReviewGroup && fc.CommentBody.containsIgnoreCase('~Run Tests~'))
            {
                DevelopmentReviewHandler.RunLocalTestsAsynchronous();
                qaTestsFired = true;
            }
        }
    }
}