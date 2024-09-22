import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getFinancialServicesAccounts';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Account Name', fieldName: 'Name', type: 'text', sortable: true, editable: true },
    { label: 'Account Owner', fieldName: 'OwnerName', type: 'text', sortable: true }, // OwnerName will now be handled correctly
    { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true },
    { label: 'Website', fieldName: 'Website', type: 'url', editable: true },
    { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency', editable: true },
    { type: 'button', typeAttributes: { label: 'View', name: 'view', variant: 'base' }}
];

export default class FinancialServicesAccountList extends LightningElement {
    @track accounts;
    @track sortBy = 'Name';
    @track sortDirection = 'asc';
    @track searchTerm = '';
    @track columns = COLUMNS;
    @track draftValues = [];

    wiredAccountsResult;

    // Sorting options for combobox
    get sortOptions() {
        return [
            { label: 'Account Name', value: 'Name' },
            { label: 'Account Owner', value: 'Owner.Name' }
        ];
    }

    get sortDirectionOptions() {
        return [
            { label: 'Ascending', value: 'asc' },
            { label: 'Descending', value: 'desc' }
        ];
    }

    // Fetch accounts filtered by Industry = 'Financial Services'
    @wire(getAccounts, { searchTerm: '$searchTerm', sortBy: '$sortBy', sortDirection: '$sortDirection' })
    wiredAccounts(result) {
        this.wiredAccountsResult = result; // Store the result to use later for refreshApex
        if (result.data) {
            this.accounts = result.data;
        } else if (result.error) {
            this.showErrorToast('Error fetching accounts', result.error.body.message);
        }
    }

    // Handle filter by account name
    handleFilter(event) {
        this.searchTerm = event.target.value; // Update search term
    }

    // Handle sorting
    handleSort(event) {
        this.sortBy = event.detail.value; // Sort by selected field (Name or Owner.Name)
        // this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc'; // Toggle sorting direction
        this.loadAccounts();
    }

    handleSortDirection(event) {
        this.sortDirection = event.detail.value; // Update sort direction
        this.loadAccounts(); // Refresh accounts after changing sort direction
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues.map(draft => {
            return { fields: { ...draft } }; // Use the fields to update records
        });

        const promises = updatedFields.map(recordInput => updateRecord(recordInput));

        // Execute all save promises
        Promise.all(promises)
            .then(() => {
                this.showSuccessToast('Record Updated', 'Account updated successfully');
                // Clear draft values to hide Save/Cancel buttons
                this.draftValues = [];
                // Refresh account data to show updated information
                return refreshApex(this.wiredAccountsResult); // Refresh the data from the server
            })
            .catch(error => {
                this.showErrorToast('Error updating record', error.body.message);
            });
    }

    // Handle row actions (navigate to record page)
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view') {
            window.open(`/lightning/r/Account/${row.Id}/view`, '_blank');
        }
    }

    // Show success toast
    showSuccessToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant: 'success',
            })
        );
    }

    // Show error toast
    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant: 'error',
            })
        );
    }

    loadAccounts() {
        getAccounts({
            searchTerm: this.searchTerm,
            sortBy: this.sortBy,
            sortDirection: this.sortDirection
        })
        .then(result => {
            this.accounts = result;
        })
        .catch(error => {
            this.showErrorToast('Error fetching accounts', error.body.message);
        });
    }
}
