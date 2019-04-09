
# LWC-Editor
Lightweigh tab to view and edit LWC Component

copy code or install unmanaged package from here  https://syeds-lwc-editor-developer-edition.ap0.force.com/
to add package to your org

LWC Editor app contains editor tab for editing and creating components

How to use

1.Add your org domain to remote site settings as it uses tooling api to fetch data (Get Domain name by executing 

URL.getSalesforceBaseUrl().toExternalForm() )

2.Update your domain name to custom label 'DomainName' if you want to use editor option 

a.If click jack protoection is enablend in your org add vf page and lighting urls to whitelisting by going to setup>sessionsetings>add whitlist

3.toggle editor by using Switch TO Editor

4.toggel editor full screen by using Show File Section

5.Editor Shortcut 

a.Ctrl+S=saves file 

b.SHIFT+TAB=Prettify code 

c.Ctrl+Space=Show autocomplete code 

d. Alt-Shift-F=Toggle Full screen




Known Issue

1.When using editor postMessage is not working 

Fix this by preview LWCEditor vf page copy url and replace the text in sourceOfIframe in vewweb LWC Component

2.Editor and New is not working with org with namespace

Fix this by adding name space to methods that are being called from vewweb and update url in sourceOfIframe and in origon of vf page

3.During creation in component select interface if addedd to meta file after creation it doesnt seems to work
SF Api error