import { LightningElement, track, wire } from 'lwc';
import getTasksWithRelatedInfo from '@salesforce/apex/TaskController.getTasksWithRelatedInfo';

export default class TaskComponent extends LightningElement {
    @track tasks = [];
    columns = [
        { label: 'Subject', fieldName: 'subject', type: 'text', sortable: true },
        { label: 'Who Name', fieldName: 'whoName', type: 'text', sortable: true },
        { label: 'Who Type', fieldName: 'whoType', type: 'text', sortable: true },
        { label: 'What Name', fieldName: 'whatName', type: 'text', sortable: true },
        { label: 'What Type', fieldName: 'whatType', type: 'text', sortable: true }
    ];

    @wire(getTasksWithRelatedInfo)
    wiredTasks({ error, data }) {
        if (data) {
            this.tasks = data.map(task => ({
                id: task.id,
                subject: task.subject,
                whoName: task.whoName,
                whoType: task.whoType,
                whatName: task.whatName,
                whatType: task.whatType
            }));
            
        } else if (error) {
            console.error('Error fetching tasks:', error);
            this.tasks = [];
        }
    }

    updateWhoName() {
        this.tasks = this.tasks.map(task => {
            task.whoName = 'New Name';
            return task;
        });        
    }
}
