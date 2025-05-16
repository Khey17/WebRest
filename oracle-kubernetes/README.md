# Oracle + Kubernetes + Docker Project (Guide)

This project shows how to run Oracle Database inside Kubernetes using Docker and connect to it like a normal Oracle database. You can upload SQL files, create users, and everything stays running even if you restart. No need to recreate it all every time.

---

## Requirements/Dependancies

- **Docker Desktop** (with WSL2 backend enabled)
- **Minikube** (Docker driver)
- **kubectl**
- **Oracle Account** (to pull the Oracle XE image)
- **PowerShell (Admin)**

---

## Project Folder Structure

```bash
/oracle-k8s
  ├── PS1.sql   # Schema creation
  ├── PS2.sql   # Data + constraints (optional)
  └── oracle-deployment.yaml
```

For MacOS, use this link [compatible with ARM64](https://hub.docker.com/r/gvenzl/oracle-xe)
```bash
docker pull gvenzl/oracle-xe
```
To load the image:
```bash
minikube image load gvenzl/oracle-xe
```

---

## Pull the Oracle XE Docker Image

```powershell
docker login container-registry.oracle.com
# (use your Oracle credentials)

docker pull container-registry.oracle.com/database/express:21.3.0-xe
```

---

## Start Minikube with Docker Driver

```powershell
minikube start --driver=docker
minikube image load container-registry.oracle.com/database/express:21.3.0-xe
```

This will start the Kubernetes cluster and load the Oracle image.

---

## Deploy Oracle in Kubernetes

Make sure the `oracle-deployment.yaml` file is ready. Then:

```powershell
kubectl apply -f oracle-deployment.yaml
kubectl get pods -w
```

Wait until the pod shows `Running`.

---

## Connect to the Registered Oracle Database remotely 

```powershell
kubectl exec -it oracle-db-XXXXX (podname) -- bash
```

---

## Inside Bash

```bash
sqlplus Username/YourPassword@IPAddress/ServiceName (for example, FREEPDB1 in our case)
```

---

## You should see the following snippet

```sql
SQL*Plus: Release 21.0.0.0.0 - Production on Tue Apr 1 21:49:12 2025
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Sat Mar 22 2025 14:42:26 +00:00

Connected to:
Oracle Database 23ai Free Release 23.0.0.0.0 - Production
Version 23.4.0.24.05
SQL>
```

---

## If You Restart Your PC

```powershell
minikube start
kubectl get pods
```

If the pod isn’t running, use:
```powershell
kubectl rollout restart deployment oracle-db
```

Then reconnect using the same commands.

---

 # Progress
``` Powershell
 bash-4.2$ sqlplus UD_ASHOKK/XXXX@IPAddress:1521/FREEPDB1

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Apr 1 21:49:12 2025
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Sat Mar 22 2025 14:42:26 +00:00

Connected to:
Oracle Database 23ai Free Release 23.0.0.0.0 - Production
Version 23.4.0.24.05
```
---

Exit to bash or powershell and then:
## Run SQL Files Inside the Oracle Pod

### 1. Copy SQL file to pod

```bash
kubectl cp ./PS1.sql <pod-name>:/tmp/PS1.sql
```
```bash
kubectl cp ./PS1.sql <pod-name>:/tmp/PS1.sql
```
and so forth

followed by
```bash
kubectl exec -it <pod-name> -- bash
```

## Execute the SQL file inside the pod
```bash
sqlplus sqlplus UD_ASHOKK/XXXX@IPAddress:1521/FREEPDB1 @/tmp/PS1.sql
```
Followed by
```SQL
@/tmp/PS2.sql
```

Sample Output after running the schemas inside the pod:
```SQL
SQL> select table_name from user_tables;
```
```SQL
TABLE_NAME
--------------------------------------------------------------------------------
CUSTOMER
ORDERS
GENDER
ORDER_STATUS
ADDRESS
ADDRESS_TYPE
CUSTOMER_ADDRESS
INVENTORY
INVENTORY_STATE
INVENTORY_STATUS
ORDERS_LINE

TABLE_NAME
--------------------------------------------------------------------------------
ORDER_STATE
PRODUCT
PRODUCT_PRICE
PRODUCT_STATUS

15 rows selected.

SQL> 
```

