public with sharing class TestCaseGeneratorLogUtil{

    /* constants */
    private static TestCaseGeneratorLogUtil errorUtilInstance = null;    
    private static final String EXCEPTION_TYPE_STRING = 'Exception type: ';
    private static final String EXCEPTION_MESSAGE_STRING = 'Exception message: ';
    // class name max length in error log object
    private static final Integer NAME_MAX_SIZE = Test_Case_Generator_Log__c.Class_Name__c.getDescribe().getLength();

    // class name max length in error log object
    private static final Integer CUST_NAME_MAX_SIZE = 50;

    // revenue operations error wrapper class
    private RevenueInfoWrapper revWrapper;

    /* class variables */
    // related record id with the error logs
    private Id currentSObjectId;
    // list of error logs to be inserted together
    private List<Test_Case_Generator_Log__c> errorLogsToInsert = new List<Test_Case_Generator_Log__c>();    
    
    /* default private constructor to prevent external instantiation */
    public TestCaseGeneratorLogUtil(){}

    /*
    * getter for currentSObjectId field
    */
    public Id getCurrentSObjectId(){
        return this.currentSObjectId;
    }
    /*
    * getter for log list that will be collected across the methods
    */
    List<Test_Case_Generator_Log__c> getErrorLogsToInsert(){
        return errorLogsToInsert;
    }
    /*
    * setter for currentSObjectId - represents related record id for the error logs
    */
    public void setCurrentSObjectId( Id pValue ){
        this.currentSObjectId = pValue;
    }
    /*
    * initiatialize the current class
    */
    public static TestCaseGeneratorLogUtil getInstance(){
        if( errorUtilInstance == null ){
            errorUtilInstance = new TestCaseGeneratorLogUtil();
        }
        return errorUtilInstance;
    }    
    /*
    * helper method toputs new log message into the queue, requires call to logMessage() to write to custom object
    * @param self explanatory
    * @return none
    */
    public void logDebug( String className, String moduleName, 
                                        String detail, String objectId ){
        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
        log.Log_Level__c = String.valueOf( LoggingLevel.DEBUG );
        logInternal( log, className, moduleName, detail, objectId );
    }    
    /*
    * puts new log message into the queue, requires call to logMessage() to write to custom object
    * @param self explanatory
    * @return none
    */
    public void logInfo( String className, String moduleName, 
                                    String detail, String objectId ){
        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
        log.Log_Level__c = String.valueOf( LoggingLevel.INFO );
        logInternal( log, className, moduleName, detail, objectId );
    }    
    /*
    * puts new log message into the queue, requires call to logMessage() to write to custom object
    * @param self explanatory
    * @return none
    */
     public void logWarn( String className, String moduleName, String detail, String objectId ){
        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
        log.Log_Level__c = String.valueOf( LoggingLevel.WARN );
        logInternal( log, className, moduleName, detail, objectId );
    }
    /* 
    * helper method to iterate SaveResult array and add any errors to the log detail
    * @param pResults saveresult list
    */
    public void processDMLResults( Database.SaveResult[] pResults ){
        if( pResults != null ){
            // loop through the results and capture any errors
            for( Database.SaveResult result : pResults ){
                if( !result.success ){
                    recordErrorResult( result.getErrors(), result.getId(), 'saving' );
                }
            }
        }
    }    
    /* 
    * helper method to iterate SaveResult array and add any errors to the log detail
    * @param pResults saveresult list
    * @param className - from where its called
    * @param methodName - from where its called
    */
    public void processDMLResults( Database.SaveResult[] pResults, String className, String methodName ){
        if( pResults != null ){
            // loop through the results and capture any errors
            for( Database.SaveResult result : pResults ){
                // for failure
                if( !result.success ){
                    recordErrorResult( result.getErrors(), className, methodName );
                }
            }
        }
    }
    /*
    * helper method to iterate UpsertResult array and add any errors to the log detail
    * @param pResults  a UpsertResult array to process
    * @return none
    */
    public void processDMLResults( Database.UpsertResult[] pResults ){
        if(pResults != null){
            // loop through the results and capture any errors
            for( Database.UpsertResult result : pResults ){
                if(!result.success){
                    recordErrorResult( result.getErrors(), result.getId(), 'upserting' );
                }
            }
        }
    }
    /*
    * helper method to iterate DeleteResult array and add any errors to the log detail
    * @param pResults  a DeleteResult array to process
    * @return none
    */
    public void processDMLResults( Database.DeleteResult[] pResults ){
        if( pResults != null ){
            // loop through the results and capture any errors
            for( Database.DeleteResult result : pResults ){
                if( !result.success ){
                    recordErrorResult( result.getErrors(), result.getId(), 'deleting' );                
                }
            }
        }
    }
    /* 
    * helper method to process deleted results
    * @param pResults  a DeleteResult array to process
    * @param className - class from where the error is originating
    * @param methodName - method from where the error is originating
    * @return - none
    */
    public void processDMLDeleteResults( Database.DeleteResult[] pResults, String className, String methodName ){
        if( pResults != null ){
            // loop through the results and capture any errors
            for( Database.DeleteResult result : pResults ){
                if( !result.success ){
                    // this will pass each result error and logs into org62 error logs
                    recordErrorResult( result.getErrors(), className, methodName );                
                }
            }
        }
    }
    /* 
    * helper method to process Merge results
    * @param pResults  a MergeResult array to process
    * @param className - class from where the error is originating
    * @param methodName - method from where the error is originating
    * @return - none
    */
    public void processDMLMergeResults( Database.MergeResult[] pResults, String className, String methodName ){
        if( pResults != null ){
            // loop through the results and capture any errors
            for( Database.MergeResult result : pResults ){
                if( !result.success ){
                    // this will pass each result error and logs into org62 error logs
                    recordErrorResult( result.getErrors(), className, methodName );                
                }
            }
        }
    }
    /*
    * helper method for process exception - create an error log and add to list
    * @param self explanatory
    * @return none
    */
    /*public void processException( String className, String moduleName, Exception pException ){
        if( pException != null ){
            Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
            log.Log_Level__c = String.valueOf( LoggingLevel.ERROR );
            log.Module_Name__c = getLimitedString( moduleName, NAME_MAX_SIZE );
            log.Class_Name__c = getLimitedString( className, NAME_MAX_SIZE );
            /*        
            // print out the exception type
            log.Log_Detail__c = EXCEPTION_TYPE_STRING + pException.getTypeName() + '\n\n';
            // print out the exception message
            log.Log_Detail__c += EXCEPTION_MESSAGE_STRING + pException.getMessage();            
            if( pException instanceof DmlException ){
                DmlException dmlEx = (DmlException)pException;
                for( Integer i=0; i < dmlEx.getNumDml(); i++ ){
                    log.Log_Detail__c += '\n\nRecord that failed to insert: ' + dmlEx.getDmlId(i) + '\n\n';
                    log.Log_Detail__c += 'DML Message: ' + dmlEx.getDmlMessage(i) + '\n\n';
                    log.Log_Detail__c += 'Field(s) that caused DML error: ' + dmlEx.getDmlFieldNames(i);
                }
            }
            
            log.Category__c = pException.getTypeName();
            log.Log_Detail__c = pException.getStackTraceString() + '\n\n' + pException.getMessage();
            // when keeping track of the current SObject that is being processed
            // use it to stamp the Object Id reference
            log.Object_Id__c = this.currentSObjectId;
            this.errorLogsToInsert.add( log );
        }
    } */   
    /*
    * helper method to process excpetion and create error log against it
    * allows a general exception to be written with a string as the detail rather than an exception detail
    * @param self explanatory
    */
    /*public void processException( String className, String moduleName, String pException ){
        if( pException != null ){
            Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
            log.Log_Level__c = String.valueOf( LoggingLevel.ERROR );
            log.Module_Name__c = getLimitedString( moduleName, NAME_MAX_SIZE );
            log.Class_Name__c = getLimitedString( className, NAME_MAX_SIZE );         
            // print out the exception string
            log.Log_Detail__c = pException;
            // when keeping track of the current SObject that is being processed
            // use it to stamp the Object Id reference
            System.debug('@@@sreejit - Inside ProcessException  current s object id ' + this.currentSObjectId);
            log.Object_Id__c = this.currentSObjectId;
            this.errorLogsToInsert.add( log );
        }
    }*/
    /*
    * helper method to get errors that were thrown from an Exception
    * @param pException  the DmlException to process
    */
    /* public void processException( Exception pException ){
        processException( '','', pException );
    } */
    /**
     * helper method to get Revenue operation error and create an error log for it
     * makes use of RevenueInfoWrapper class
     * @param self explanatory
     * @return none
     */
    /* public void processExceptionWithRevImpact(String className, String moduleName, String pException, String category){
        Test_Case_Generator_Log__c errorLog = new Test_Case_Generator_Log__c();
        errorLog.Log_Level__c = String.valueOf( LoggingLevel.ERROR );
        errorLog.Module_Name__c = getLimitedString( moduleName, NAME_MAX_SIZE );
        errorLog.Class_Name__c = getLimitedString( className, NAME_MAX_SIZE );
        errorLog.Log_Detail__c = pException ; 
        errorLog.Object_Id__c = getCurrentSObjectId();
        errorLog.Error_Status__c = 'New';
        errorLog.Category__c = category;
        if(this.revWrapper != null){
            errorLog.Customer_Name__c = this.revWrapper.customerName!= null 
                                        ? getLimitedString(this.revWrapper.customerName, CUST_NAME_MAX_SIZE)
                                        : '';
            errorLog.Due_Date__c = this.revWrapper.dueDate;
            errorLog.Reference_URL__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+getCurrentSObjectId();
            errorLog.Revenue_Impacted__c = this.revWrapper.revenueImpacted;
        }
        this.errorLogsToInsert.add(errorLog);
        System.debug('Loaded @@@sreejit !!!');
    } */
    /**
     * helper method to populate the fields of RevenueInfoWrapper class
     * @param self explanatory
     * @return none
     */
    public void populateRevenueInfoWrapper(String accName, Date dueDate, Decimal amount){
        this.revWrapper = new RevenueInfoWrapper(accName, dueDate, amount);
    }
    /*
    * helper method to save Test_Case_Generator_Log__c log objects that were built before
    * @param none
    * @return none
    */ 
    public void logMessage(){
        System.debug('@@ANI 11');
        if( !errorLogsToInsert.isEmpty() ){
            System.debug('@@ANI 12');
            //If this fails, none of the previous stuff will be rolled back
            Database.UpsertResult[] results;
            try{ 
                System.debug('@@ANI 13');
                System.debug('@@ANI1'+errorLogsToInsert);
                System.debug('@@ANI2'+this.errorLogsToInsert);
                results = new WSTestCaseGeneratorLogUtil().doUpsertDML(this.errorLogsToInsert );
                System.debug('@@ANI15'+this.errorLogsToInsert);
                System.debug('@@ANI 14'+results);
            }catch ( Exception e ){
                String errorMsg = 'exception thrown while saving Test_Case_Generator_Log__c: ' + e.getMessage() + ' ';                
            }
            errorLogsToInsert.clear();
        }
    }
    /*
    * helper method to log exception - create an error log and add to list
    * @param self explanatory
    * @return none
    */
    /* public void logException( String className, String moduleName, string sObjectID, String category, Exception ex ){
        if( ex != null ){
            Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
            log.Log_Level__c = String.valueOf( LoggingLevel.ERROR );
            log.Module_Name__c = getLimitedString( moduleName, NAME_MAX_SIZE );
            log.Class_Name__c = getLimitedString( className, NAME_MAX_SIZE );
            log.Category__c     =   category;
            String exceptionString = 'Cause : '+ex.getCause()
            +'Message : '+ex.getMessage()
            +'TypeName : '+ex.getTypeName()
            +'LineNumber : '+ex.getLineNumber()
            +'StackTrace : '+ex.getStackTraceString();
            log.Log_Detail__c = exceptionString;
            // when keeping track of the current SObject that is being processed
            // use it to stamp the Object Id reference
            if (sObjectID != null) {
                log.Object_Id__c = sObjectID;
            }
            this.errorLogsToInsert.add( log );
        }
    } */
    /**
     * Helper method to publish Org62_Log_Event__c Platform Event.
     * @param none
     * @return none
     */
    /* public void publishMessage(){
        List<Org62_Log_Event__e> logsToPublish = new List<Org62_Log_Event__e>();
        if( !errorLogsToInsert.isEmpty() ){
            //If this fails, none of the previous stuff will be rolled back
            List<Database.SaveResult> results;
            Org62_Log_Event__e logEvent;
            for( Test_Case_Generator_Log__c log : errorLogsToInsert){
                logEvent = new Org62_Log_Event__e();
                logEvent.Class_Name__c      =   log.Class_Name__c;
                logEvent.Module_Name__c     =   log.Module_Name__c;
                logEvent.Log_Level__c       =   log.Log_Level__c;
                logEvent.Object_Id__c       =   log.Object_Id__c;
                logEvent.Owner_Id__c        =   UserInfo.getUserId();
                logEvent.Log_Detail__c      =   log.Log_Detail__c;
                logEvent.Category__c        =   log.Category__c;
                logsToPublish.add(logEvent);
            }
            try{ 
                results = EventBus.publish( logsToPublish );
            }catch ( Exception e ){
                String errorMsg = 'exception thrown while publishing Org62_Log_Event__e: ' + e.getMessage() + ' ';                
            }
            errorLogsToInsert.clear();
        }
    } */
    /*
    * helper method to iterate UpsertResult array and add any errors to the log detail
    * @param self explanatory
    */
    public void processDMLResults( Database.UpsertResult[] pResults,List<sObject> lstUpsertRecords,
                                                        String className,String methodName ){
        if( pResults != null ){
            try {
                for( Integer i = 0; i < pResults.size(); i++ ){
                    if( !pResults.get(i).isSuccess() ){
                        Database.Error error = pResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();          
                        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
                        log.Log_Detail__c = '';
                        if( error.getMessage() != null ){
                            log.Log_Detail__c = error.getMessage();
                        }
                        else{
                            log.Log_Detail__c = 'Error: But there was no error message\n';
                        }
                        if( lstUpsertRecords.get(i) != null ){
                            log.Object_Id__c = lstUpsertRecords.get(i).Id;
                        }
                        log.Class_Name__c = className;
                        log.Module_Name__c = methodName;
                        errorLogsToInsert.add( log );
                    }    
                }
            }catch( Exception e ){
                //processException( className, methodName, e );
                logMessage();
            }
        }
    }
    /*
    * helper method to iterate UpsertResult array and add any errors to the log detail
    * @param self explanatory 
    * @return none
    */
    public void processDMLResults( Database.SaveResult[] pResults, 
                                                        List<SObject> lstUpsertRecords, 
                                                        String className, String methodName ){
        if( pResults != null ){
            try {
                for( Integer cntOfRes = 0; cntOfRes < pResults.size(); cntOfRes++ ){
                    // for failure ones
                    if ( !pResults.get(cntOfRes).isSuccess() ){
                        Database.Error error = pResults.get(cntOfRes).getErrors().get(0);
                        String failedDML = error.getMessage();
                        // create new error log
                        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
                        log.Log_Detail__c = '';
                        if( error.getMessage() != null ){
                            log.Log_Detail__c = error.getMessage();
                        }
                        else{
                            log.Log_Detail__c = 'Error: But there was no error message\n';
                        }
                        if( lstUpsertRecords.get(cntOfRes) != null){
                            log.Object_Id__c = lstUpsertRecords.get(cntOfRes).Id;
                        }
                        log.Class_Name__c = className;
                        log.Module_Name__c = methodName;
                        errorLogsToInsert.add( log );
                    }    
                }
            }catch( Exception e ){                
                //processException( className, methodName, e );
                logMessage();
            }
        }
    }
    /* 
    * helper method to send email notification
    * @param self explanatory 
    * @return none
    */
    public void sendEmailNotification( List<String> toAddressList, List<String> ccAddressList, 
                                       String emailContent, String subject, String senderDisplayName, 
                                       String replyToAddress, String defaultOrgWideEmail, 
                                       Boolean useSignature, Boolean bccSender, Boolean isPlainTextBody ){
        //
        try{
            // check if there are email id's in system to send the notification
            if( !toAddressList.isEmpty() ){
                // create the instance for SingleEmailMessage
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                // set the email subject(from custom label)
                mail.setSubject( subject );
                // set the to address with all the EOPS email address configured in system
                mail.setToAddresses( toAddressList );
                // set default org wide email address for automated process user(since they don't have valid email)
                if( String.isNotBlank( defaultOrgWideEmail ) ){
                    mail.setOrgWideEmailAddressId( defaultOrgWideEmail );
                }
                // set sender display name for al other non automated user(if needed)
                // - for automated process, system will not allow to set sender display name
                else if( String.isNotBlank( senderDisplayName ) ){
                    mail.setSenderDisplayName( senderDisplayName );
                }
                // set cc address(if needed)
                if( ccAddressList != null && !ccAddressList.isEmpty() ){
                    mail.setCcAddresses( ccAddressList );
                }
                // set reply to address(if needed)
                if( String.isNotBlank( replyToAddress ) ){
                    mail.setReplyTo( replyToAddress );
                }
                // set bcc address as sender(if needed)
                if( bccSender ){
                   mail.setBccSender( true ); 
                }
                // set sender email signature(if needed)
                if( useSignature ){
                   mail.setUseSignature( true ); 
                }
                // if its a plain text content
                if( isPlainTextBody ){
                    mail.setPlainTextBody( emailContent );
                }
                // if its a html content
                else{
                   mail.setHtmlBody( emailContent ); 
                }  
                // send the email
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
            }
        }catch( Exception ex ){                
            //processException( 'TestCaseGeneratorLogUtil', 'sendEmailNotification', ex );
            logMessage();  
        }  
    }
    /*
    * utility method to prepare the error log based on errors 
    * @param errors
    * @param className
    * @param operation
    * @return
    */
    private void recordErrorResult( Database.SaveResult[] errors, String className, String operation ){      
        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
        // need to initialize this because you can't initialize it to error (below)
        // but you can += error
        log.Log_Detail__c = '';
        log.Class_Name__c = className;
        log.Module_Name__c = operation;
        if( errors != null ){
            for( Database.SaveResult error : errors ){
                log.Log_Detail__c += error;
            }
        }else{
            log.Log_Detail__c = 'Error ' + operation + ', but there was no error message\n';
        }        
        errorLogsToInsert.add( log );
    }
    /*
    * utility method to prepare erro log and add to list
    * @param self explanatory
    * @return none
    */
    private void recordErrorResult( Database.Error[] errors, Id objectId, String operation ){
        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
        // need to initialize this because you can't initialize it to error (below)
        // but you can += error
        log.Log_Detail__c = '';
        if( errors != null ){
            for( Database.Error error : errors ){
                log.Log_Detail__c += error;
            }
        }else{
            log.Log_Detail__c = 'Error ' + operation + ', but there was no error message\n';
        }
        log.Object_Id__c = objectId;
        errorLogsToInsert.add( log );
    }
    /*
    * utility method to prepare erro log and add to list
    * @param self explanatory
    * @return none
    */
    private void recordErrorResult( Database.Error[] errors, String className, String operation ){        
        Test_Case_Generator_Log__c log = new Test_Case_Generator_Log__c();
        // need to initialize this because you can't initialize it to error (below)
        // but you can += error
        log.Log_Detail__c = '';
        log.Class_Name__c = className;
        log.Module_Name__c = operation;
        if( errors != null ){
            for( Database.Error error : errors ){
                log.Log_Detail__c += error;
            }
        }else{
            log.Log_Detail__c = 'Error ' + operation + ', but there was no error message\n';
        }        
        errorLogsToInsert.add( log );
    }
    /*
    * utility method to create log record
    * @param self explanatory
    * @return none
    */
    private void logInternal( Test_Case_Generator_Log__c log, String className, 
                                            String moduleName, String detail, String objectId ){
        log.Class_Name__c = getLimitedString( className, NAME_MAX_SIZE );
        log.Log_Detail__c = detail;
        log.Module_Name__c = getLimitedString( moduleName, NAME_MAX_SIZE );
        log.Object_Id__c = objectId;
        errorLogsToInsert.add( log );
    }
    /*
    * get a string of a maximum length
    * @param orig - actual value
    * @param maxSize - size till which it needs to be trimmed off
    * @return trimmed of value
    */
    private String getLimitedString( String orig, Integer maxSize ){
        if (orig != null && orig.length() > maxSize){
            return orig.substring(0, maxSize);
        }
        return orig;
    }
    /* */
    public class TestException extends System.Exception{ }

    /*
    * without sharing class to perform dmls
    */
    private without sharing class WSTestCaseGeneratorLogUtil{

        /*
        * helper method to upsert error logs in database
        * @param errLogs - error records
        * @return list of upsert results
        */
        public Database.UpsertResult[] doUpsertDML( List<Test_Case_Generator_Log__c> errLogs ){
            System.debug('@@ANI3'+errLogs);
            //System.debug('@@ANI4'+errLogs);
            return Database.upsert( errLogs );
        }
    }

    /**
     * wrapper class containing new fields of Error Log Object
     * 
     */
    private class RevenueInfoWrapper{
        // contains the customer's name
        private String customerName{get; set;}
        // contains the due date of transaction
        private Date dueDate{get; set;}
        // revenue impacted by the invoice error
        private Decimal revenueImpacted{get; set;}
        /**
         * constructor method to populate the contents of RevenueInfoWrapper
         * @params self explanatory
         * @return none
         */
        RevenueInfoWrapper(String customerName, Date dueDate, Decimal revenueImpacted){
            this.customerName = customerName;
            this.dueDate = dueDate;
            this.revenueImpacted = revenueImpacted;
        }
    }
}