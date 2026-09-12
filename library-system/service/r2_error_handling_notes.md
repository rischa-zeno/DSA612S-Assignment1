# r2 - Error Handling Notes

## Standard error shape (used across all endpoints)
- message: human-readable explanation
- errorCode: short code like ASSET_NOT_FOUND, INVALID_PAYLOAD, WORKORDER_NOT_FOUND
- timestamp: when the error happened

  ## Error cases covered in my endpoints
  - Asset tag doesn't exist -> 404, ASSET_NOT_FOUND
  - Component/Schedule/WorkOrder ID doesn't exist -> 404, with a specific code
  - Missing required fields (name, dates, description) -> 400, INVALID_PAYLOAD
  - Invalid work order status transition -> 400, INVALID_STATUS_TRANSITION

 ## Still to check before submission
 - []Confirm r1's endpoints use this same error shape
 - []Test r1's CRUD endpoints with bad input (missing fields, wrong assetTag)
 - []Replace assetExistsStub() with r1's real asset lookup once available
