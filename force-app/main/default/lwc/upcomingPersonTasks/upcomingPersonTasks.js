import { LightningElement, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import getUpcomingPersonTasks from '@salesforce/apex/PersonController.getUpcomingPersonTasks';

const columns = [
    { label: 'Project', fieldName: 'projectName' },
    { label: 'Task label', fieldName: 'taskLabel' },
    { label: 'Start Date', fieldName: 'taskStartDate', type: 'date' },
    { label: 'End Date', fieldName: 'taskEndDate', type: 'date' },
    { label: 'Status', fieldName: 'taskStatus' },
];

export default class UpcomingPersonTasks extends LightningElement {

    @api recordId;

    errors;
    tasks;

    columns = columns;


    @wire(getUpcomingPersonTasks, {personId: '$recordId'})
    wiredTasksRecords({error, data}) {
        
        if (data) {
            this.tasks = data;
            this.errors = undefined;
        } else if (error) {
            this.errors = reduceErrors(error);
            this.tasks = undefined;
        }
    }


    syncPerson(){
        this.showToastMessage('Failed to sync', 'Person Sync is not yet configured', 'error');
    }

    showToastMessage(title, message, variant){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }


}