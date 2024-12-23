import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPolicies from '@salesforce/apex/PoliciesController.getPolicies';
import updateAcknowledgement from '@salesforce/apex/PoliciesController.updateAcknowledgement';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Policies extends NavigationMixin(LightningElement) {
    @track policies = [];
    userId = Id;
    selectedPreviewFileUrl;
    showPreview = false;

    connectedCallback() {
        getPolicies({ userId: this.userId })
            .then(result => {
                this.policies = result;
                console.log('Policies retrieved: ', this.policies);
            })
            .catch(error => {
                console.error('Error fetching policies: ', error);
            });
    }

    previewFile(event) {
        this.selectedPreviewFileUrl = event.target.dataset.index;
        this.showPreview = true;
    }

    closePreview() {
        this.showPreview = false;
    }

    handleAcknowledge(event) {
        const acknowledge = event.currentTarget.dataset.acknowledge === 'true';
        const acknowledgeId = event.currentTarget.dataset.acknowledgeid;
        console.log('acknowledgeId : ', acknowledgeId);
        if (!acknowledge) {
            updateAcknowledgement({ Id: acknowledgeId })
                .then(() => {
                    event.currentTarget.style.backgroundColor = '#088756';
                    this.showToast('Success', 'Policy acknowledged successfully.', 'success');
                })
                .catch(error => {
                    console.error('Error acknowledging policy: ', error);
                    this.showToast('Error', 'Failed to acknowledge policy. Please try again.', 'error');
                });
        }
        else{
            this.showToast('Warning', 'Policy already acknowledged.', 'warning');
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvent);
    }
}