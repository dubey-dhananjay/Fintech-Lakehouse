# Secure FinTech Data Lakehouse & Generative AI Copilot

An enterprise-grade, end-to-end data platform built on the Medallion Architecture using Snowflake, dbt, and AWS S3, integrated with an intelligent Generative AI Copilot via LangChain and Streamlit for real-time market analysis and unstructured regulatory document intelligence.

---

## 🎯 Context & Business Value

### The Problem
Financial institutions handle decoupled data paradigms: highly structured, high-frequency transactional data (market ticks) and completely unstructured regulatory text files (SEC filings). Merging these two streams manually causes extreme data silos, high latency, and limits analysts from correlating corporate narrative disclosures with quantitative market performance.

### The Solution
This platform unifies structured and unstructured financial data into a high-performance **Snowflake Data Lakehouse** following the **Medallion Architecture (Bronze $\rightarrow$ Silver $\rightarrow$ Gold)**. By implementing an ELT pipeline, data governance frameworks, and a Generative AI **Retrieval-Augmented Generation (RAG)** loop, financial analysts can run sub-second analytical queries and securely "chat" with both numeric tables and prose disclosures without hallucination risks.

---

## 🧱 Platform Architecture & Data Flow

<img width="218" height="281" alt="image" src="https://github.com/user-attachments/assets/d366dadc-2461-4dd6-bf7e-7ca7e1e28ea8" />




---

## 📁 Dataset Source Reference

1. **Structured Market Data:** 20 years of historical daily stock prices for over 6,000+ Nasdaq tickers.
   * **Source:** [Kaggle - 6000+ Nasdaq Stocks Historical Daily Prices](https://www.kaggle.com/datasets/raymondsunartio/6000-nasdaq-stocks-historical-daily-prices)
   * **Target Files:** `nasdaq_historical_prices_daily.csv` and `nasdaq_list.csv`
2. **Unstructured Text Data:** Corporate annual performance reports containing executive disclosures.
   * **Source:** [SEC EDGAR System](https://www.sec.gov/edgar/searchedgar/companysearch)
   * **Target File:** `apple_10k.txt` (or any equivalent raw corporate text filing)

---

## 📅 Technical Implementation Workflow

### Phase 1: Storage Provisioning & Bronze Raw Landing
* Establish an **AWS S3 Bucket** acting as the raw enterprise data lake.
* Configure Snowflake infrastructure with decoupled storage endpoints using **External Stages** mapping to S3.
* Utilize Snowflake's dynamic **`VARIANT`** schemas and `ARRAY_CONSTRUCT` to ingest files into a raw **Bronze Layer** to preserve full line audit trails and mitigate schema drift.

### Phase 2: Silver Cleaning & Relational Transformation
* Apply relational parsing models to isolate raw variants into structured column primitives.
* Enforce **Data Quality Frameworks** by filtering structural headers, formatting dates, and managing null parameters safely using an `ISO-8859-1` relaxed decoder matrix.
* Implement **Data Governance Role-Based Access Control (RBAC)** by building a dynamic *Data Masking Policy* to systematically hide business metrics based on the query role.

### Phase 3: Gold Layer Dimensional Modeling
* Transform clean Silver tables into an optimized analytical **Star Schema** to establish industry-standard warehouse topologies.
* Build descriptive context vectors into a dimension table (`dim_companies`) and bind high-frequency transactional data to a fact engine table (`fact_market_movements`).
* Apply **Micro-Clustering Performance Optimization Keys** on date and symbol coordinates to enable sub-second aggregation operations across millions of records.

### Phase 4: Generative AI Context Orchestration (RAG Pipeline)
* Connect a Python middleware backend driven by **LangChain** directly into the Snowflake database engine.
* Extract unstructured prose disclosures, apply recursive text splitters into clean paragraph chunks, and convert the tokens into numerical representations via an embedding vector model.
* Implement the core hybrid copilot pipeline: intercept a user's natural language query, extract qualitative context from the vector index, fetch quantitative calculations from the Gold relational warehouse, and fuse them inside an LLM orchestrator (OpenAI / Claude) for grounded financial summaries.

### Phase 5: Production User Frontend & Hosting
* Construct a web-based financial analytics dashboard using **Streamlit** to expose visual metric cards alongside an interactive AI Copilot terminal.
* Package and containerize the application environments to support scalable, cloud-native enterprise application deployment.
