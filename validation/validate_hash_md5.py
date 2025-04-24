import pandas as pd
import hashlib

def generate_hash(df, cols):
    combined = df[cols].astype(str).agg(''.join, axis=1)
    return hashlib.md5(''.join(combined).encode()).hexdigest()

oracle = pd.read_csv("oracle_billing_export.csv")
postgres = pd.read_csv("postgres_billing_export.csv")

oracle_hash = generate_hash(oracle, ['txn_id', 'amount', 'billing_date'])
postgres_hash = generate_hash(postgres, ['txn_id', 'amount', 'billing_date'])

print("Hash Match" if oracle_hash == postgres_hash else " Hash Mismatch")
