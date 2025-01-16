# Confluent Cloud Flink Statement Lifecycle

This guide outlines the typical development lifecycle of a Flink statement. For simplicity, the statement is developed by a user in the Confluent Cloud UI and then deployed using a Service Account (SA) via Terraform (TF).

## Step 0 - Set Up the Flink Compute Pool and produce some data

In the `./compute-pool` directory, run `terraform apply` to create the Flink compute pool.
In addition, we start a Datagen Connector producing order events such as

```json
{
  "ordertime": 1514337450644,
  "orderid": 188764,
  "itemid": "Item_540",
  "orderunits": 7.209762610468496,
  "address": {
    "city": "City_3",
    "state": "State_6",
    "zipcode": 40310
  }
}
```

## Step 1 - Configure Permissions

We assume that the Service Account (SA) and the user developing the statement are managed and have their permissions assigned elsewhere in the organization. These permissions are considered pre-configured.

For detailed information on required permissions, refer to [Grant Role-Based Access in Confluent Cloud for Apache Flink](https://docs.confluent.io/cloud/current/flink/operate-and-deploy/flink-rbac.html).

The following role bindings should be configured for the user:

- **FlinkDeveloper** + **DataDiscovery**  
  These roles should be granted via the default Confluent Cloud user group mappings. For more details, see [Managing SSO User Accounts](https://docs.confluent.io/cloud/current/security/authenticate/user-identities/user-accounts/manage-sso-user-accounts.html#default-user-permissions).

- **DeveloperRead** to topics with the prefix `orders`.
- **ResourceOwner** to all Transactional IDs.

For the Service Account, grant the following roles:

- **FlinkDeveloper**
- **ResourceOwner** to topics with the prefix `orders` (assuming the SA owns the application).
- **DeveloperWrite** to Transactional IDs with the prefix `_confluent-flink_`.

## Step 2 - Develop the Statement

Start by querying the topic and filtering for `orderunits > 5`. Use the following SQL statement:

```sql
SELECT * FROM `team-emea`.`pneff_flink_demo_2025_01_21`.`orders` WHERE `orderunits` > 5;
```

## Step 3 - Deploy the Statement

To deploy the filtering statement to its own table or topic via Infrastructure as Code (IaC), we use Terraform and a Service Account. In the `./statements` directory, run `terraform apply`. The module automatically references the Flink compute pool created in Step 0.

## Step 4 - Set Up Monitoring

Metrics are automatically exposed through the Confluent [Cloud Metrics API](https://api.telemetry.confluent.cloud/docs/descriptors/datasets/cloud). If an integration is configured, the `/export` endpoint will scrape Flink metrics automatically. You can manually query the metrics using the following `curl` command:

```bash
curl --location 'https://api.telemetry.confluent.cloud/v2/metrics/cloud/export?resource.compute_pool.id=lfcp-xyz' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic ABC'
```

The response will include various metrics related to your Flink statements. Here are some example metrics you may encounter:

```plaintext
# HELP confluent_flink_num_records_in Total number of records this statement has received.
# TYPE confluent_flink_num_records_in gauge
confluent_flink_num_records_in{table_name="team-emea.pneff_flink_demo_2025_01_21.orders",compute_pool_id="lfcp-539kx8",flink_statement_uid="a9a5e95c-8e5c-4a0a-84ae-2df36c38b501",flink_statement_name="workspace-2025-01-15-132945-4482b167-051a-4fef-9b00-18663480c4ed",} 122.0 1736948340000
confluent_flink_num_records_in{table_name="team-emea.pneff_flink_demo_2025_01_21.orders_filtered",compute_pool_id="lfcp-539kx8",flink_statement_uid="d4358049-8e0b-4fec-bac9-a6a343221116",flink_statement_name="workspace-2025-01-15-133446-f225af1f-1766-4bb4-8f0a-519d3044dc44",} 58.0 1736948340000

# HELP confluent_flink_num_records_out Total number of records this task statement emitted.
# TYPE confluent_flink_num_records_out gauge
confluent_flink_num_records_out{table_name="team-emea.pneff_flink_demo_2025_01_21.orders_filtered",compute_pool_id="lfcp-539kx8",flink_statement_uid="a9a5e95c-8e5c-4a0a-84ae-2df36c38b501",flink_statement_name="workspace-2025-01-15-132945-4482b167-051a-4fef-9b00-18663480c4ed",} 51.0 1736948340000
confluent_flink_num_records_out{compute_pool_id="lfcp-539kx8",flink_statement_uid="d4358049-8e0b-4fec-bac9-a6a343221116",flink_statement_name="workspace-2025-01-15-133446-f225af1f-1766-4bb4-8f0a-519d3044dc44",} 0.0 1736948340000

# HELP confluent_flink_pending_records Total amount of available records after the consumer offset in a Kafka partition across all operators
# TYPE confluent_flink_pending_records gauge
confluent_flink_pending_records{table_name="team-emea.pneff_flink_demo_2025_01_21.orders",compute_pool_id="lfcp-539kx8",flink_statement_uid="a9a5e95c-8e5c-4a0a-84ae-2df36c38b501",flink_statement_name="workspace-2025-01-15-132945-4482b167-051a-4fef-9b00-18663480c4ed",} 0.0 1736948340000
confluent_flink_pending_records{table_name="team-emea.pneff_flink_demo_2025_01_21.orders_filtered",compute_pool_id="lfcp-539kx8",flink_statement_uid="d4358049-8e0b-4fec-bac9-a6a343221116",flink_statement_name="workspace-2025-01-15-133446-f225af1f-1766-4bb4-8f0a-519d3044dc44",} 0.0 1736948340000

# HELP confluent_flink_current_input_watermark_milliseconds The last watermark this statement has received (in milliseconds) for the given table.
# TYPE confluent_flink_current_input_watermark_milliseconds gauge
confluent_flink_current_input_watermark_milliseconds{table_name="team-emea.pneff_flink_demo_2025_01_21.orders",compute_pool_id="lfcp-539kx8",flink_statement_uid="a9a5e95c-8e5c-4a0a-84ae-2df36c38b501",flink_statement_name="workspace-2025-01-15-132945-4482b167-051a-4fef-9b00-18663480c4ed",} 1.736948396647E12 1736948340000
confluent_flink_current_input_watermark_milliseconds{table_name="team-emea.pneff_flink_demo_2025_01_21.orders_filtered",compute_pool_id="lfcp-539kx8",flink_statement_uid="d4358049-8e0b-4fec-bac9-a6a343221116",flink_statement_name="workspace-2025-01-15-133446-f225af1f-1766-4bb4-8f0a-519d3044dc44",} 1.736948225642E12 1736948340000

# HELP confluent_flink_current_output_watermark_milliseconds The last watermark this statement has produced (in milliseconds) to the given table.
# TYPE confluent_flink_current_output_watermark_milliseconds gauge
confluent_flink_current_output_watermark_milliseconds{table_name="team-emea.pneff_flink_demo_2025_01_21.orders_filtered",compute_pool_id="lfcp-539kx8",flink_statement_uid="a9a5e95c-8e5c-4a0a-84ae-2df36c38b501",flink_statement_name="workspace-2025-01-15-132945-4482b167-051a-4fef-9b00-18663480c4ed",} 1.736948396647E12 1736948340000
confluent_flink_current_output_watermark_milliseconds{compute_pool_id="lfcp-539kx8",flink_statement_uid="d4358049-8e0b-4fec-bac9-a6a343221116",flink_statement_name="workspace-2025-01-15-133446-f225af1f-1766-4bb4-8f0a-519d3044dc44",} 1.736948225642E12 1736948340000

# HELP confluent_flink

_compute_pool_utilization_current_cfus The absolute number of CFUs at a given moment
# TYPE confluent_flink_compute_pool_utilization_current_cfus gauge
confluent_flink_compute_pool_utilization_current_cfus{compute_pool_id="lfcp-539kx8",} 2.0 1736948340000

# HELP confluent_flink_compute_pool_utilization_cfu_minutes_consumed The number of how many CFUs consumed since the last measurement
# TYPE confluent_flink_compute_pool_utilization_cfu_minutes_consumed gauge
confluent_flink_compute_pool_utilization_cfu_minutes_consumed{compute_pool_id="lfcp-539kx8",} 2.0 1736948340000

# HELP confluent_flink_compute_pool_utilization_cfu_limit The possible max number of CFUs for the pool
# TYPE confluent_flink_compute_pool_utilization_cfu_limit gauge
confluent_flink_compute_pool_utilization_cfu_limit{compute_pool_id="lfcp-539kx8",} 10.0 1736948340000
```

This data includes key performance and resource metrics related to your Flink statements and compute pool. You can use these metrics to monitor the performance of your Flink jobs.
