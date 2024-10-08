import { LightningElement, track } from 'lwc';

export default class ProxyExample extends LightningElement {

    @track userData = {
        firstName: 'John',
        lastName: 'Doe'
    };

    proxyData;

    connectedCallback() {
        this.proxyData = new Proxy(this.userData, {
            get: (target, property) => {
                console.log(`Getting ${property}: ${target[property]}`);
                return target[property];
            },
            set: (target, property, value) => {
                console.log(`Setting ${property} to ${value}`);
                target[property] = value;
                this.handleDataChange(property, value);
                return true;
            }
        });
    }

    get fullName() {
        return `${this.proxyData.firstName} ${this.proxyData.lastName}`;
    }

    set firstName(value) {
        this.proxyData.firstName = value;
    }

    handleDataChange(property, value) {
        console.log(`Data changed: ${property} = ${value}`);

        this.userData = { ...this.userData };
    }

    changeFirstName() {
        this.firstName = 'Jane';
    }
}