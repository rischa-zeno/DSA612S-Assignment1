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
service /library/schedules on new http:Listener(8081) {
 resource function post [string assetTag](Schedule newSchedule) returns Schedule|http:NotFound|http:BadRequest {
if !assetExistsStub(assetTag) {
 return <http:NotFound>{
  body: {message: "Asset not found: " + assetTag, errorCode: "ASSET_NOT_FOUND", timestamp: nowTimestamp()}
};
}
if newSchedule.startDate.trim() == "" || newSchedule.endDate.trim() == "" {
return <http:BadRequest>{
  body: {message: "startDate and endDate are required", errorCode: "INVALID_PAYLOAD", timestamp: nowTimestamp()}
};
}
Schedule schedule = {
 scheduleId: uuid:createType1AsString(),
 assetTag: assetTag,
 scheduleType: newSchedule.scheduleType,
 startDate: newSchedule.startDate,
 endDate: newSchedule.endDate,
 dueDate: newSchedule?.dueDate,
 status: "PENDING"
};

Schedule[] existing = scheduleStore[assetTag] ?: [];
existing.push(schedule);
scheduleStore[assetTag] = existing;

return schedule;
}
resource function delete [string assetTag]/[string scheduleId]() returns http:Ok|http:NotFound {
Schedule[]? existing = scheduleStore[assetTag];
if existing is() {
 return <http:NotFound>{
  body: {message: "No schedules found for asset: " + assetTag, errorCode: "ASSET_NOT_FOUND", timestamp: nowTimestamp()}
};
}

Schedule[] filtered = existing.filter(s => s.scheduleId != scheduleId);
if filtered.length() == existing.length() {
 return <http:NotFound>{
  body: {message: "Schedule not found: " + scheduleId, errorCode: "SCHEDULE_NOT_FOUND", timestamp: nowTimestamp()}
};
}

scheduleStore[assetTag] = filtered;
return http:OK;
}
resource function put[string assetTag]/[string scheduleId](Schedule updates) returns Schedule|http:NotFound|http:BadRequest {
Schedule[]? existing = scheduleStore[assetTag];
if existing is() {
 return <http:NotFound>{
  body: {message: "No schedules found for asset: " + assetTag, errorCode: "ASSET_NOT_FOUND", timestamp: nowTimestamp()}
};
}
int? idx = ();
foreach int i in 0 ..<existing.length() {
 if existing[i].scheduleId == scheduleId {
   idx = i;
   break;
}
}
if idx is () {
 return <http:NotFound>{
  body: {message: "Schedule not found: " + scheduleId, errorCode: "SCHEDULE_NOT_FOUND", timestamp: nowTimestamp
()}
};
}
Schedule updated = existing[idx];
updated.startDate = updates.startDate;
updated.endDate = updates.endDate;
updated.status = updates.status;
updated.dueDate = updates?.dueDate;
existing[idx] = updated;
scheduleStore[assetTag] = existing;

return updated;
}
