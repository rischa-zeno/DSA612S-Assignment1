import ballerina/time;
public type Component record {|
string componentId;
string assetTag;
string name;
string status;
|};
public type Schedule record {|
string scheduleId;
string assetTag;
string scheduleType;
string startDate;
string endDate;
string dueDate?;
string status;
|};
public type SubTask record {|
string taskId;
string description;
boolean completed;
|};
public type WorkOrder record {|
string workOrderId;
string assetTag;
string description;
string status;
SubTask[] subTasks;
string createdDate;
|};
public type ErrorResponse record {|
string message;
string errorCode;
string timestamp;
|};
public function nowTimestamp() returns string {
return time:utcToString(time:utcNow());
}
