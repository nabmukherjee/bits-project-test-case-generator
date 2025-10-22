import { LightningElement, track } from 'lwc';
import processInputData from '@salesforce/apex/TestCaseGeneratorController.processInputData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
export default class TestCaseGenerator extends LightningElement {
    @track inputData = ''; // Stores user input
    @track options = [
        { label: 'GUS', value: 'GUS' },
        { label: 'Narwhale', value: 'Narwhale' },
    ];
    @track selectedOption = '';
    @track tableData = []; // Processed data for datatable
    @track isProcessing = false; // Tracks if processing is in progress

    columns_gus = [
        { label: 'Work ID', fieldName: 'workId', wrapText: true },
        { label: 'Test Suite Name', fieldName: 'testSuiteName', wrapText: true },
        { label: 'Test Suite Description', fieldName: 'testSuiteDescription', wrapText: true },
        { label: 'Test Scenario Name', fieldName: 'testScenarioName', wrapText: true },
        { label: 'Test Scenario Details', fieldName: 'testScenarioDetails', wrapText: true },
        { label: 'Expected Results', fieldName: 'expectedResults', wrapText: true },
        { label: 'Execution Type', fieldName: 'executionType', wrapText: true },
        { label: 'Priority', fieldName: 'priority', wrapText: true },
    ];

    /*columns_narwhale = [
        { label: 'Work ID', fieldName: 'workId', wrapText: true },
        { label: 'Test Case Name', fieldName: 'testCaseName', wrapText: true },
        { label: 'Test Case Details', fieldName: 'testCaseDetails', wrapText: true },
        { label: 'Detail Steps', fieldName: 'detailSteps', wrapText: true },
        { label: 'Expected Result', fieldName: 'expectedResults', wrapText: true },
        { label: 'Execution Status', fieldName: 'executionStatus', wrapText: true },
        { label: 'Owner Full Name', fieldName: 'ownerName', wrapText: true },
        { label: 'Owner ID', fieldName: 'ownerId', wrapText: true },
        { label: 'Planned Execution Date', fieldName: 'executionDate', wrapText: true },
        { label: 'Upload Identifier', fieldName: 'uploadIdentifier', wrapText: true },
        { label: 'Project', fieldName: 'project', wrapText: true }
    ];*/

    columns_narwhale = [
        { label: 'Test Case Name', fieldName: 'testCaseName', wrapText: true },
        { label: 'Project', fieldName: 'project', wrapText: true },
        { label: 'Owner Full Name', fieldName: 'ownerName', wrapText: true },
        { label: 'Owner ID', fieldName: 'ownerId', wrapText: true },
        { label: 'Organization', fieldName: 'organization', wrapText: true },
        { label: 'Execution Status', fieldName: 'executionStatus', wrapText: true },
        { label: 'Planned Execution Date', fieldName: 'executionDate', wrapText: true },
        { label: 'BT Release', fieldName: 'btrelease', wrapText: true },
        { label: 'GUS Work Item ID', fieldName: 'workId', wrapText: true },
        { label: 'Test Case Details', fieldName: 'testCaseDetails', wrapText: true },
        { label: 'Detail Steps', fieldName: 'detailSteps', wrapText: true },
        { label: 'Expected Result', fieldName: 'expectedResults', wrapText: true }
    ];

    // Determines if the Process Data button should be disabled
    get isProcessButtonDisabled() {
        return this.isProcessing || this.inputData.trim() === '' || this.selectedOption === '';
    }

    // Determines if the Copy Table Content button should be disabled
    get isCopyButtonDisabled() {
        return this.tableData.length === 0;
    }

    get displayColumn() {
        return this.selectedOption === 'GUS' ? [...this.columns_gus] : this.selectedOption === 'Narwhale' ? [...this.columns_narwhale] : '';
    }

    // Handles changes in the textarea
    handleInputChange(event) {
        this.inputData = event.target.value;
    }

    handleOptionChange(event) {
        this.selectedOption = event.target.value;
        console.log('Selected option = '+this.selectedOption);
        this.tableData = []; // Clears old data to prevent duplication
        this.dispatchEvent(new RefreshEvent());
    }

    // Clears the table and processes new input data
    processData() {
        this.isProcessing = true; // Disable the button and show processing message

        // Clear existing table data
        this.tableData = [];
        
        processInputData({ input: this.inputData, type: this.selectedOption })
            .then((result) => {
                console.log('Processed result:', result);
                this.tableData = result.map((item, index) => ({ id: index, ...item })); // Add unique key for lightning-datatable
                console.log('Processed Data:', this.tableData);
                this.showToast('Success', 'Data processed successfully!', 'success');
            })
            .catch((error) => {
                console.error('Error processing data:', error);
                this.showToast('Error', 'Error processing data. Please try again.', 'error');
            })
            .finally(() => {
                this.isProcessing = false; // Re-enable the button and hide message
            });
    }

    // Copies the table content to the clipboard
    copyTableContent() {
        if (this.tableData.length === 0) {
            this.showToast('Error', 'No data to copy!', 'error');
            return;
        }
    
        let dataRows = this.selectedOption === 'GUS'
            ? this.tableData.map(row => this.columns_gus.map(col => row[col.fieldName] || '').join('\t'))
            : this.tableData.map(row => this.columns_narwhale.map(col => row[col.fieldName] || '').join('\t'));
    
        const clipboardContent = dataRows.join('\n');
    
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(clipboardContent).then(() => {
                this.showToast('Success', 'Table content copied to clipboard!', 'success');
            }).catch(error => {
                console.error('Clipboard write failed:', error);
                this.fallbackCopyTextToClipboard(clipboardContent);
            });
        } else {
            this.fallbackCopyTextToClipboard(clipboardContent);
        }
    }

    // Fallback to copying via a temporary textarea if Clipboard API fails
    fallbackCopyTextToClipboard(text) {
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
    
        try {
            const successful = document.execCommand('copy');
            if (successful) {
                this.showToast('Success', 'Table content copied to clipboard!', 'success');
            } else {
                console.warn('Document execCommand failed.');
                this.showToast('Error', 'Failed to copy table content.', 'error');
            }
        } catch (err) {
            console.error('Fallback copy failed:', err);
            this.showToast('Error', 'Failed to copy table content.', 'error');
        } finally {
            document.body.removeChild(textArea);
        }
    }

    // Utility method to show toast messages
    showToast(title, message, variant) {
        console.log('Inside showToast');
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }

}