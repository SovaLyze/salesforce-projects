import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {

    childData = {
        percentage: 20,
        myname: 'Sova'
    };

    handleOnchangePercentage(event) {
        this.childData = { percentage: event.target.value };
    }

    handleOnchangeName(event) {
        this.childData = { myname: event.target.value };
    }
}