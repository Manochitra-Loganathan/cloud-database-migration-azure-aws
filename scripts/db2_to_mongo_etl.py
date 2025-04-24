"""
Db2 to MongoDB ETL Script – Enterprise Version
Migrates legacy policy data from Db2 into MongoDB with nested fields, joins, and audit logging.
Author: Manochitra Loganathan
"""

import ibm_db
import pymongo
import json
import time
from datetime import datetime

# --- Configuration ---
BATCH_SIZE = 100
mongo_uri = "mongodb://localhost:27017"
mongo_db_name = "bcs_archive"
mongo_collection = "policy_archive"

# --- DB2 Setup ---
db2_conn_str = (
    "DATABASE=BCSARCH;HOSTNAME=db2.company.local;PORT=50000;"
    "PROTOCOL=TCPIP;UID=db2user;PWD=securepassword;"
)

try:
    conn = ibm_db.connect(db2_conn_str, "", "")
except Exception as e:
    raise Exception(f"Failed to connect to DB2: {e}")

# --- MongoDB Setup ---
client = pymongo.MongoClient(mongo_uri)
db = client[mongo_db_name]
collection = db[mongo_collection]

# Create indexes for performance
collection.create_index("policyId", unique=True)
collection.create_index("status")
collection.create_index("customerId")

# --- SQL with Join for customer name ---
query = """
SELECT p.policy_id, p.customer_id, p.policy_type, p.issue_date, p.expiry_date,
       p.premium_amount, p.status, p.notes,
       c.full_name AS customer_name
FROM legacy_policy_data p
JOIN customers c ON p.customer_id = c.customer_id
WHERE p.policy_type = 'LIFE' AND p.status IN ('EXPIRED', 'CLOSED')
"""

stmt = ibm_db.exec_immediate(conn, query)
record = ibm_db.fetch_assoc(stmt)

# --- ETL: Transform & Load in Batches ---
batch = []
inserted_count = 0
start_time = time.time()

while record:
    try:
        doc = {
            "policyId": record["POLICY_ID"],
            "customerId": record["CUSTOMER_ID"],
            "customerName": record["CUSTOMER_NAME"].title() if record["CUSTOMER_NAME"] else "Unknown",
            "type": record["POLICY_TYPE"],
            "status": record["STATUS"],
            "dates": {
                "issued": record["ISSUE_DATE"].isoformat() if record["ISSUE_DATE"] else None,
                "expired": record["EXPIRY_DATE"].isoformat() if record["EXPIRY_DATE"] else None
            },
            "premium": float(record["PREMIUM_AMOUNT"] or 0),
            "notes": record["NOTES"] or "",
            "migratedAt": datetime.utcnow()
        }

        batch.append(doc)

        if len(batch) == BATCH_SIZE:
            collection.insert_many(batch)
            inserted_count += len(batch)
            batch = []

    except Exception as etl_err:
        print(f⚠️ ETL Error on policy_id {record['POLICY_ID']}: {etl_err}")

    record = ibm_db.fetch_assoc(stmt)

# Insert remaining records
if batch:
    collection.insert_many(batch)
    inserted_count += len(batch)

# --- Final Log ---
end_time = time.time()
duration = round(end_time - start_time, 2)
print(f"✅ Migration complete: {inserted_count} documents inserted in {duration} seconds")

# Optional: Insert a log document
db["migration_log"].insert_one({
    "source": "Db2",
    "target": mongo_collection,
    "totalRecords": inserted_count,
    "executedBy": "Manochitra",
    "completedAt": datetime.utcnow(),
    "durationSeconds": duration
})

# Close DB2 connection
ibm_db.close(conn)
