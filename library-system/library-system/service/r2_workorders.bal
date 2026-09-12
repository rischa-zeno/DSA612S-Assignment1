import ballerina/http;
import ballerina/uuid;

map<WorkOrder> workOrderStore = {};

function isValidTransition(string current, string next) returns boolean {
if current == "OPEN" {
 return next == "IN_PROGRESS" || next == "CLOSED";
}
if current == "IN_PROGRESS" {
 return next == "CLOSED" || next == "OPEN";
}
return false;
}

service /library/workorders on new http:Listener(8082) {

resource function post .(WorkOrder newOrder) returns
WorkOrder|http:NotFound|http:BadRequest {
if !assetExistsStub(newOrder.assetTag) {
return<http:NotFound>{
 body: {message: "Asset not found: " + newOrder.assetTag, errorCode: "ASSET_NOT_FOUND", timestamp: nowTimestamp()}
};
}
if newOrder.description.trim() == "" {
 return <http:BadRequest>{
  body: {message: "description is required", errorCode: "INVALID_PAYLOAD", timestamp: nowTimestamp()}
};
}
WorkOrder ord = {
workOrderId:uuid:createType1AsString(),
assetTag: newOrder.assetTag,
description: newOrder.description,
status: "OPEN",
subTasks: [],
createdDate: nowTimestamp()
};
workOrderStore[ord.workOrderId] = ord;

return ord;
}

resource function put [string workOrderId]/status(string status) returns WorkOrder|http:NotFound|http:BadRequest {
WorkOrder? existing = workOrderStore[workOrderId];
if existing is () {
return <http:NotFound>{
body: {message: "Work order not found: " + workOrderId, errorCode: "WORKORDER_NOT_FOUND", timestamp: nowTimestamp()}
};
}
if !isValidTransition(existing.status, status) {
return <http:BadRequest>{
body: {message: "Cannot transition from: " + existing.status + "to" + status, errorCode: "INVALID_STATUS_TRANSITION", timestamp: nowTimestamp()}
};
}
existing.status = status;
workOrderStore[workOrderId] = existing;
return existing;
}
resource function post [string workOrderId]/subtasks(SubTask newTask) returns WorkOrder|http:NotFound|http:BadRequest {
WorkOrder? existing = workOrderStore[workOrderId];
if existing is () {
 return <http:NotFound>{
  body: {message: "Work order not found: " + workOrderId, errorCode: "WORKORDER_NOT_FOUND", timestamp: nowTimestamp()}
};
}
if newTask.description.trim() == "" {
return <http:BadRequest>{
  body: {message: "Sub-task description is required", errorCode: "INVALID_PAYLOAD", timestamp: nowTimestamp()}
};
}
SubTask task = {
 taskId: uuid:createType1AsString(),
description: newTask.description,
completed: false
};
existing.subTasks.push(task);
workOrderStore[workOrderId] = existing;
return existing;
}
resource function get [string workOrderId]() returns WorkOrder|http:NotFound{
WorkOrder? existing = workOrderStore[workOrderId];
if existing is () {
return <http:NotFound>{
 body: {message: "Work order not found: " + workOrderId, errorCode: "WORKORDER_NOT_FOUND", timestamp: nowTimestamp()}
};
}
return existing;
}
}
