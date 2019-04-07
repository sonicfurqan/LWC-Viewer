import {
    LightningElement,
    wire,
    track
} from 'lwc';
import getLWCList from '@salesforce/apex/ViewComponents.getWebComponentList'
import queryWebComponent from '@salesforce/apex/ViewComponents.getWebComponent'
import updateWebComponent from '@salesforce/apex/ViewComponents.setWebComponent'
import insertComponent from '@salesforce/apex/ViewComponents.createWebComponent'

import DomainName from '@salesforce/label/c.DomainName';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
export default class Viewweb extends LightningElement {
    @track creatingFile=false;
    @track resultList;
    @track timestamp;
    @track countOfMetadata = 'LWC Components';
    @track isLoading = true;
    @track showResult;
    @track saving = false;
    @track ace = false;
    @track istreeLoading = false;
    @track showFile = true;
    @track showpopup = false;
    @track layout = 'slds-size_4-of-6';
    @track fileName = '';
    @track recordPage = false;
    @track homepage = false;
    @track allpage = false;


    halfLayout = 'slds-size_4-of-6';
    fullLayout = 'slds-size_6-of-6';


    containerForMetadataResult = [];
    containerForWebBundleResult = [];
    orgnalresultList;
    @track queryTerm;
    sourceOfIframe = 'https://'+DomainName+'-dev-ed--c.visualforce.com';

    connectedCallback() {
        let that = this;
        window.addEventListener("message", function(event) {
            if (event.origin !== that.sourceOfIframe) {
                // Not the expected origin: Reject the message!
                return;
            }
            // Handle the message
            if (event.data !== undefined) {
                let data = event.data;
                if (data.type == 'code') {
                    that.showResult = data.soruce;
                }
                if (data.type == 'save') {
                    that.showResult = data.soruce;
                    that.handlesaveClick();
                }
                if (data.type == 'fullscreen') {
                    that.showFile = !that.showFile;
                    if (that.showFile === true) {
                        that.layout = that.halfLayout;
                    }
                    if (that.showFile === false) {
                        that.layout = that.fullLayout;
                    }
                }

            }
        });




        this.isLoading = true;
        getLWCList().then(result => {
            let data = JSON.parse(result);
            if (data.records) {
                let parsingData = [];
                data.records.forEach(function (record) {
                    let date = new Date(Date.parse(record.LastModifiedDate));
                    let oneRecord = {
                        label: record.MasterLabel,
                        name: record.Id,
                        metatext: 'LastModified By ' + record.LastModifiedBy.Name + ',' + date,
                        expanded: false,
                    }
                    parsingData.push(oneRecord);
                });
                this.countOfMetadata = 'LWC Components (' + data.records.length + ')';
                this.resultList = parsingData;
                this.orgnalresultList = parsingData;
                this.containerForMetadataResult = data.records;
            } else {
                this.countOfMetadata = 'LWC Components (0)';
            }

            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
        })


    }
    connecttoIframe(type,
        source) {

        let iframe = this.template.querySelector('iframe');
        if (iframe) {

            let message = {
                mode: type,
                code: source
            };

            iframe.contentWindow.postMessage(message, this.sourceOfIframe);
        }

    }

    handleNewClick() {
        let that = this;
        let fileName = this.fileName;
        if (!fileName.trim()) {
            return;
        }
        if (fileName.trim().includes(' ')) {
            const event = new ShowToastEvent({
                title: 'Incorrect File Name',
                message: 'File Name cannot have blank spaces',
                variant: 'error',

            });
            this.dispatchEvent(event);
            return;
        }
        console.log(this.homepage);
        console.log(this.allpage);
        console.log(this.recordPage);
        this.creatingFile=true;
        insertComponent({
            fileName: fileName.trim(),
            isRecordPage: this.recordPage,
            ishomePage: this.homepage,
            isallPage: this.allpage
        }).then(result=> {
            console.log(result)
            if (result == 'true') {
                that.connectedCallback();
                const event = new ShowToastEvent({
                    title: fileName+' Created',
                    variant: 'success'
                });
                that.dispatchEvent(event);

            } else {
                const event = new ShowToastEvent({
                    title: 'Error Createing LWC',
                    message: result, 
                    variant: 'error',
                    mode: 'pester'
                });
                that.dispatchEvent(event);
            }
            that.showpopup = false;
            that.creatingFile=false;
        }).catch(error => {
            console.log('error',
                error);
            that.showpopup = false;
             that.creatingFile=false;
        });

    }
    togglepopup() {

        this.showpopup=!this.showpopup;

    }
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        let searchKey = evt.target.value;
        if (isEnterKey) {
            let result = this.orgnalresultList.filter(data => data.label.toLowerCase().includes(searchKey.toLowerCase()));
            this.resultList = result;

        }
        if (!searchKey) {
            this.resultList = this.orgnalresultList;
        }
    }
    updateValue(event) {
        const fieldName = event.target.name;
        if (fieldName == 'fileName') {
            this.fileName = event.target.value;
        } else if (fieldName == 'home') {
            this.homepage = event.target.checked;
        } else if (fieldName == 'allp') {
            this.allpage = event.target.checked;
        } else if (fieldName == 'recod') {
            this.recordPage = event.target.checked;
        }
    }
    swichEditor(evt) {
        this.ace = evt.target.checked;
    }

    toggleFiles(evt) {
        this.showFile = evt.target.checked;
        if (this.showFile === true) {
            this.layout = this.halfLayout;
        }
        if (this.showFile === false) {
            this.layout = this.fullLayout;
        }
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
                this.isLoading = !this.ace;
                if (this.isLoading == false)
                    this.istreeLoading = true;
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
                    this.istreeLoading = false;
                }).catch(error => {
                    console.log('error',
                        error);
                });
            }
        } else {
            this.isLoading = !this.ace;
            let webData = this.containerForWebBundleResult.filter(a => a.Id === selectedId);
            if (webData.length > 0) {


                let date = new Date(Date.parse(webData[0].LastModifiedDate));
                this.showResult = webData[0].Source;
                this.continerForDispalyedResult = webData[0];
                this.timestamp = 'LastModified By ' + webData[0].LastModifiedBy.Name + ',' + date;
                this.isUpdateAvilabel = true;
                this.connecttoIframe(webData[0].Format, webData[0].Source);
            }
            setTimeout(function () {
                that.isLoading = false;
            }, 100);
        }
    }
    handlesaveClick() {
        let that = this;
        let bundle = this.containerForWebBundleResult;
        let data = this.continerForDispalyedResult;
        let id = data.Id;
        let source = this.showResult;
        //        console.log(source);
        //    console.log(id);
        let jsonString = JSON.stringify(source);
        //  console.log(jsonString);
        if (source && id) {
            this.saving = true;
            updateWebComponent({
                id: id,
                sourceString: jsonString
            }).then(result => {
                if (result) {

                    let data = JSON.parse(result);
                    if (data.length > 0 && data[0].errorCode) {
                        console.error(data[0].errorCode);
                        const event = new ShowToastEvent({
                            title: 'Error cannot save ' + data[0].errorCode,
                            message: data[0].message,
                            variant: 'error',
                            mode: 'pester'
                        });
                        this.dispatchEvent(event);
                        this.saving = false;
                        return
                    }
                    this.saving = false;
                }

                bundle.forEach(function (record) {
                    if (record.Id === id) {
                        record.Source = source;
                    }
                });
                this.containerForWebBundleResult = bundle;
                const event = new ShowToastEvent({
                    title: 'Saved',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.saving = false;
            }).catch(error => {
                console.error(error);
                const event = new ShowToastEvent({
                    title: 'Error cannot save',
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.saving = false;
            })
        }


    }
}