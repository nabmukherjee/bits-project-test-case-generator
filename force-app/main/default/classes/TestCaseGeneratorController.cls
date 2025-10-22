public with sharing class TestCaseGeneratorController {
    @AuraEnabled
    public static List<Map<String, String>> processInputData(String input, String type) {

        // Prompt Template Code Start
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        promptGenerationsInput.isPreview = false;

        Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();

        // String input
        ConnectApi.WrappedValue strWrappedValue = new ConnectApi.WrappedValue();
        strWrappedValue.value = input;
        valueMap.put('Input:AcceptanceCriteria', strWrappedValue); 

        promptGenerationsInput.inputParams = valueMap;
                                
        // Set additional configuration values
        promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';
                                        
        // Call the service
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput;
        if(type == 'GUS'){
            generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Test_Case_Generation_Template_Standard', promptGenerationsInput); 
        }else if(type == 'Narwhale'){
            generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Test_Case_Generation_Template_Narwhale', promptGenerationsInput);
        }
                                        
        // Consume resolution
        System.debug('Prompt resolution: ' + generationsOutput.prompt);
        System.debug('requestId = '+generationsOutput.requestId);
                                        
        // Consume response
        System.debug('Prompt response: ' + generationsOutput.generations[0].text);
        // Prompt Template Code End

        // Tracking the usage of the Tool using the Org62_Error_Log__c object
        String requestAndResponse = 'Input: \n' + input + '\n' + '================================================ \n Output: \n' + generationsOutput.generations[0].text;
        TestCaseGeneratorLogUtil logger = TestCaseGeneratorLogUtil.getInstance();
        logger.logDebug('TestGenie', 'processInputData', requestAndResponse, '');
        logger.logMessage();

        List<Map<String, String>> output = new List<Map<String, String>>();
        
        // Split the input into individual rows using newline as a delimiter
        //List<String> rows = input.split('\n');
        List<String> rows = generationsOutput.generations[0].text.split('\n');
        System.debug('rows = APEX '+rows);
        
        /*=========================FOR GUS===========================================================*/
        if(type == 'GUS'){
            for (String row : rows) {
                row = row.trim();
                if (row == '') continue;
                System.debug('row =Apex '+row);
                // Split each row using '|' as the delimiter
                List<String> columns = row.split('\\|');
                System.debug('columns = Size '+columns.size());

                Map<String, String> record = new Map<String, String>();
                
                for(Integer i=0;i<columns.size();i++){
                    switch on i{
                        when 0{
                            record.put('workId', columns[i].trim());
                        }
                        
                        when 1{
                            record.put('testSuiteName', columns[i].trim());
                        }
                        when 2{
                            record.put('testSuiteDescription', columns[i].trim());
                        }
                            
                        when 3{
                            record.put('testScenarioName', columns[i].trim());
                        }
                            
                        when 4{
                            record.put('testScenarioDetails', columns[i].trim());
                        }
                            
                        when 5{
                            record.put('expectedResults', columns[i].trim());
                        }
                            
                        when 6{
                            record.put('executionType', columns[i].trim());
                        }
                            
                        when 7{
                            record.put('priority', columns[i].trim());
                        }
                    }
                }
            output.add(record);
            }
        }
        /*==========================FOR NARWHALE=======================================================*/
        if(type == 'Narwhale'){
            if (!rows.isEmpty() && rows[0].toLowerCase().contains('work id')) {
                rows.remove(0); // Remove the header row
            }
            for (String row : rows) {
                System.debug('row =Apex '+row);
                row = row.trim();
                if (row == '') continue;
                // Split each row using '|' as the delimiter
                List<String> columns = row.split('\\|');
                System.debug('columns = Size '+columns.size());
                Map<String, String> record = new Map<String, String>();

                /*for(Integer i=0;i<columns.size();i++){
                    switch on i{
                        when 0{
                            record.put('workId', columns[i].trim());
                        }
                        
                        when 1{
                            record.put('testCaseName', columns[i].trim());
                        }
                        when 2{
                            record.put('testCaseDetails', columns[i].trim());
                        }
                            
                        when 3{
                            record.put('detailSteps', columns[i].trim());
                        }
                            
                        when 4{
                            record.put('expectedResults', columns[i].trim());
                        }
                            
                        when 5{
                            record.put('executionStatus', columns[i].trim());
                        }
                            
                        when 6{
                            record.put('ownerName', columns[i].trim());
                        }
                            
                        when 7{
                            record.put('ownerId', columns[i].trim());
                        }
                            
                        when 8{
                            record.put('executionDate',columns[i].trim());
                        }
                            
                        when 9{
                            record.put('project',columns[i].trim());
                        }
                            
                        when 10{
                            record.put('uploadIdentifier',columns[i].trim());
                        }
                    }
                }*/
                for(Integer i=0;i<columns.size();i++){
                    switch on i{
                        when 0{
                            record.put('testCaseName', columns[i].trim());
                        }
                        
                        when 1{
                            if(columns[i].trim() == 'Garbage'){
                                record.put('project', '');
                            }else{
                                record.put('project', columns[i].trim());
                            }
                        }
                        when 2{
                            if(columns[i].trim() == 'Garbage'){
                                record.put('ownerName', '');
                            }else{
                                record.put('ownerName', columns[i].trim());
                            }
                        }

                        when 3{
                            if(columns[i].trim() == 'Garbage'){
                                record.put('ownerId', '');
                            }else{
                                record.put('ownerId', columns[i].trim());
                            }
                        }
                            
                        when 4{
                            if(columns[i].trim() == 'Garbage'){
                                record.put('organization', '');
                            }else{
                                record.put('organization', columns[i].trim());
                            }
                        }
                            
                        when 5{
                            record.put('executionStatus', columns[i].trim());
                        }
                            
                        when 6{
                            if(columns[i].trim() == 'Garbage'){
                                record.put('executionDate', '');
                            }else{
                                record.put('executionDate', columns[i].trim());
                            }
                        }
                            
                        when 7{
                            if(columns[i].trim() == 'Garbage'){
                                record.put('btrelease', '');
                            }else{
                                record.put('btrelease', columns[i].trim());
                            }
                        }
                            
                        when 8{
                            record.put('workId',columns[i].trim());
                        }
                            
                        when 9{
                            record.put('testCaseDetails',columns[i].trim());
                        }
                            
                        when 10{
                            record.put('detailSteps',columns[i].trim());
                        }
                        when 11{
                            record.put('expectedResults',columns[i].trim());
                        }
                    }
                }
            output.add(record);
            }
        }
        /*==========================================================================================*/
        System.debug('output row: ' + output);
        return output;
    }
}