import { LightningElement, wire, track } from 'lwc';
import getLWCList from '@salesforce/apex/ViewComponents.getWebComponentList'
import queryWebComponent from '@salesforce/apex/ViewComponents.getWebComponent'
import updateWebComponent from '@salesforce/apex/ViewComponents.setWebComponent'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Viewweb extends LightningElement {
    @track resultList;
    @track timestamp;
    @track countOfMetadata = 'LWC Components';
    @track isLoading = true;
    @track showResult;
    @track saving=false;
    containerForMetadataResult = [];
    containerForWebBundleResult = [];




    connectedCallback() {
        this.isLoading = true;
        getLWCList().then(result => {
            let data = JSON.parse(result);
            if (data.records) {
                let parsingData = [];
                data.records.forEach(function (record) {
                    let oneRecord = {
                        label: record.MasterLabel,
                        name: record.Id,
                        metatext: 'LastModified By ' + record.LastModifiedBy.Name + ',' + record.LastModifiedDate,
                        expanded: false,
                    }
                    parsingData.push(oneRecord);
                });
                this.countOfMetadata = 'LWC Components (' + data.records.length + ')';
                this.resultList = parsingData;
                this.containerForMetadataResult = data.records;
            }
            else {
                this.countOfMetadata = 'LWC Components (0)';
            }

            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
        })

    }


    handleCodeEvent(event) {
        this.showResult = event.target.value;
    }
    handleSelectTreeSelect(event) {
        let that = this;
        let selectedId = event.detail.name;
        let recordData = this.containerForMetadataResult.filter(a => a.Id === selectedId);

        if (recordData.length > 0) {
            if (recordData[0].attributes.type === 'LightningComponentBundle') {
                this.isLoading = true;
                queryWebComponent({
                    id: selectedId
                }).then(result => {
                    let data = JSON.parse(result);

                    this.containerForWebBundleResult = this.containerForWebBundleResult.concat(data.records);


                    let things = new Object();
                    things.thing = this.containerForWebBundleResult;
                    let myData = things.thing;
                    things.thing = Array.from(new Set(myData.map(JSON.stringify))).map(JSON.parse);
                    this.containerForWebBundleResult = things.thing;


                    let bundleData = this.containerForWebBundleResult.filter(a => a.LightningComponentBundleId === selectedId);
                    let resultRefresh = this.resultList;
                    resultRefresh.forEach(function (findingnode) {
                        if (findingnode.name == selectedId) {
                            let tempList = [];
                            bundleData.forEach(function (continerRecord) {
                                let rempRecrd = {
                                    label: continerRecord.Format,
                                    name: continerRecord.Id,
                                    metatext: continerRecord.FilePath,
                                    expanded: false,
                                }
                                tempList.push(rempRecrd)
                            });
                            findingnode.items = tempList;
                            findingnode.expanded = true;
                        }
                    });
                    this.resultList = resultRefresh;
                    this.isLoading = false;
                }).catch(error => {
                    console.log('error', error);
                });
            }
        }
        else {
            this.isLoading = true;
            let webData = this.containerForWebBundleResult.filter(a => a.Id === selectedId);
            if (webData.length > 0) {
                this.showResult = webData[0].Source;
                this.continerForDispalyedResult = webData[0];
                this.timestamp = 'LastModified By ' + webData[0].LastModifiedBy.Name + ',' + webData[0].LastModifiedDate;
                this.isUpdateAvilabel = true;
            }
            setTimeout(function () { that.isLoading = false; }, 100);
        }
    }
    handlesaveClick(event) {
        let that=this;
        let bundle = this.containerForWebBundleResult;
        let data = this.continerForDispalyedResult;
        let id = data.Id;
        let source = this.showResult;
        console.log(source);
        console.log(id);
        let jsonString = JSON.stringify(source);
        console.log(jsonString);
        if (source && id){
            this.saving=true;
            updateWebComponent({
                id: id,
                sourceString: jsonString
            }).then(result => {
                if (result) {

                    let data = JSON.parse(result);
                    if (data.length > 0 && data[0].errorCode) {
                        const event = new ShowToastEvent({
                            title: 'Error cannot save ' + data[0].errorCode,
                            message: data[0].message
                        });
                        this.dispatchEvent(event);
                        this.saving=false;
                        return
                    }
                    this.saving=false;
                }
              
                bundle.forEach(function (record) {
                    if (record.Id === id) {
                        record.Source = source;
                    }
                });
                this.containerForWebBundleResult = bundle;
                const event = new ShowToastEvent({
                    title: 'Saved'
                });
                this.dispatchEvent(event);
                this.saving=false;
            }).catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error cannot save'
                });
                this.dispatchEvent(event);
                this.saving=false;
            })
        }
            

    }
}