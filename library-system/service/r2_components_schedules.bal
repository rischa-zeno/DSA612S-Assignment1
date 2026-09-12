import ballerina/http;
import ballerina/uuid;
map<Component[]> componentStore = {};
map<Schedule[]> scheduleStore = {};
function assetExistsStub(string assetTag) returns boolean {
return true;
}
service /library/components on new http:Listener (8080) {
 resource function post [string assetTag](Component newComponent) returns
Component |http:NotFound|http:BadRequest {
if !assetExistsStub(assetTag) {
return <http:NotFound>{
body: {message: "Asset not found: " + assetTag, errorCode:
"ASSET_NOT_FOUND", timestamp: nowTimestamp()}
    };
}
if newComponent.name.trim() == "" {
return <http:BadRequest>{
body: {message: "Component name is required", errorCode: 
"INVALID_PAYLOAD", timestamp: nowTimestamp()}
 };
}
Component component = {
componentId: uuid:createType1AsString(),
assetTag: assetTag,
name: newComponent.name,
status: newComponent.status
};

Component[] existing = componentStore[assetTag] ?: [];
existing.push(component);
componentStore[assetTag] = existing;

return component;
}
}
