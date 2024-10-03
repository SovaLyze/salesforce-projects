import { LightningElement } from 'lwc';

export default class TestLwcRef extends LightningElement {
    renderedCallback() {
        console.log('LWC Ref >>> ',this.refs.myDiv);
      }
}