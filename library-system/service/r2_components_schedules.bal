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
 resource function delete [string assetTag]/[string componentId]() returns
http:Ok|http:NotFound {
Component[]? existing = componentStore[assetTag];
if existing is () {
 return <http:NotFound>{
  body: {message: "No components found for asset: " + assetTag, errorCode: "ASSET_NOT_FOUND", timestamp: nowTimestamp()}
};
}
Component[] filtered = existing.filter(c => c.componentId != componentId);
if filtered.length() == existing.length(){
 return <http:NotFound>{
  body: {message: "Component not found: " + componentId, errorCode: "COMPONENT_NOT_FOUND", timestamp: nowTimestamp()}
};
}
componentStore[assetTag] = filtered;
return http:OK;
}
resource function get [string assetTag]() returns Component[]|http:NotFound {
if !assetExistsStub(assetTag) {
 return <http:NotFound>{
  body: {message: "Asset not found: " + assetTag, errorCode: "ASSET_NOT_FOUND", timestamp: nowTimestamp()}
};
}
return componentStore[assetTag] ?: [];
}
}
