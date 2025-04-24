# Enterprise Cloud Database Modernization: Oracle, SQL Server, Db2 → Azure, AWS, PostgreSQL, MongoDB & Snowflake

This project simulates a full-scale, enterprise-grade modernization of critical database systems powering the **NPS (New Policy System)** and **BCS (Billing & Claims System)** applications. It includes legacy platform migrations from **Oracle, SQL Server, and Db2** to **Azure SQL**, **AWS RDS**, **PostgreSQL**, **MongoDB**, and **Snowflake**, enabling real-time analytics, microservices enablement, and data lifecycle optimization.

---

## 🧰 Tech Stack
- **Relational Sources**: Oracle 12c, SQL Server 2016, Db2 11.1  
- **Targets**: Azure SQL, AWS RDS (SQL & PostgreSQL), Snowflake, MongoDB Atlas  
- **Migration Tools**: SSMA, Ora2Pg, GoldenGate, Db2 export tools, custom ETL  
- **Analytics**: Power BI, Snowflake for warehouse reporting  
- **Automation**: PowerShell, Azure CLI, Shell scripting  
- **Monitoring/Compliance**: Splunk, Dynatrace, ServiceNow

---

## ⚙️ Project Highlights

### NPS & BCS Cloud Pathways:
| Module | Source | Target | Purpose |
|--------|--------|--------|---------|
| NPS Policy | SQL Server | Azure SQL | OLTP (Transactional) |
| NPS Claims | SQL Server | Snowflake | OLAP (BI) |
| BCS Billing | Oracle | PostgreSQL | Core engine rewrite |
| BCS CRM | Db2 | MongoDB | Modernized for microservices |
| Reporting | Mixed (SQL/Oracle) | Snowflake | Real-time dashboards |

---

## 🔁 Migration Complexity

- **Db2 to MongoDB**  
  Converted policy snapshots and claims history (nested JSON) from **Db2 tables** into **MongoDB Atlas collections** using custom Python ETL + BSON transformation  
  - Normalized to document models  
  - Managed data consistency using pre/post migration hashes

- **Oracle to PostgreSQL (BCS)**  
  Replaced PL/SQL-based billing logic with PostgreSQL-compatible functions  
  - Used **Ora2Pg** for DDL + constraint conversion  
  - Built materialized views for reporting  
  - Ensured referential integrity through PK-FK restructuring

- **SQL Server to Azure SQL & AWS RDS**  
  Used SSMA + PowerShell for schema move, Always On replication for live migration testing  
  - Cutover planned with ServiceNow-based change workflows  
  - Ensured rollback compatibility and post-validation

- **Snowflake**  
  Designed OLAP layer with fact-dimension separation, scheduled ingestion from GoldenGate and raw S3 staging

---

## 📁 Folder Structure

| Folder           | Description |
|------------------|-------------|
| `scripts/`        | Multi-platform DDL, transformation logic, rollback queries |
| `diagrams/`       | Hybrid cloud data architecture + source-to-target mappings |
| `migration-plan/` | Gantt plan, risk tracker, change mgmt logs |
| `monitoring/`     | Sample logs (GoldenGate, Mongo insert lag), validation matrix, alert config |

---

## 🔒 Compliance & Monitoring

- **SOX, HIPAA, PCI-DSS** compliant  
- Full access logging to **Splunk**  
- ServiceNow ticket tracking for approvals, rollback points  
- Alerts through **Dynatrace** for replication lag, load failure, schema drift

---

## ✅ Outcomes

- Replaced 3 legacy systems with cloud-native architectures  
- Achieved 70% reduction in storage cost for archived workloads  
- 65% faster reporting after OLAP migration to Snowflake  
- Enabled microservices architecture by breaking Db2 monolith into MongoDB collections  
- Delivered audit-ready, CI/CD-enabled deployment structure

---

## 📌 Author
**Manochitra Loganathan**  
[LinkedIn](https://www.linkedin.com/in/manochitraloganathan)

> *This project is a representative abstraction of my real enterprise-level cloud migration and modernization experience across multiple database systems. All code samples are anonymized and safe to share.*

