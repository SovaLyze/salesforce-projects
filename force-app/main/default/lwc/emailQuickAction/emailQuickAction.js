import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { CloseActionScreenEvent } from "lightning/actions";

const fields = EMAIL_FIELD;

export default class EmailQuickAction extends NavigationMixin(LightningElement) {

    @api recordId;
    @api selectedRecordId;
    contact;
    email;
    
    matchingInfo = {
        primaryField: { fieldPath: 'Name'},
        additionalFields: [{ fieldPath: 'Title' }]
    };

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['Title', 'Email']
    };

    get filter() {
        return {
            criteria: [
                {
                    fieldPath: 'AccountId',
                    operator: 'eq',
                    value: this.recordId
                }
            ]
        };
    }

    handleChange(event) {
        this.selectedRecordId = event.detail.recordId;
    }

    handleChange(event) {
        this.selectedRecordId = event.detail.recordId;
        console.log("this.selectedRecordId:", this.selectedRecordId);
      }
    
      @wire(getRecord, { recordId: "$selectedRecordId", fields })
      wiredContact({ error, data }) {
        if (error) {
          console.log("###Error: " + error);
        } else if (data) {
          this.contact = data;
          this.email = this.contact.fields.Email.value;
          this.triggerEmail();
          console.log("this.email:", this.email);
        }
      }

      triggerEmail() {
        var pageRef = {
          type: "standard__quickAction",
          attributes: {
            apiName: "Global.SendEmail"
          },
          state: {
            recordId: this.recordId,
            defaultFieldValues: encodeDefaultFieldValues({
              HtmlBody: "Default values from Quick Action.",
              Subject: "Hello from Sova",
              ToAddress: this.email
            })
          }
        };
        this[NavigationMixin.Navigate](pageRef);
        this.dispatchEvent(new CloseActionScreenEvent());
      }
}