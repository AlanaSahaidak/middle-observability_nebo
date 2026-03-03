import os
import time
import random
import logging
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

REGION = os.getenv("AWS_REGION", "eu-central-1")
NAMESPACE = os.getenv("CW_NAMESPACE", "NeboApplication")
APPLICATION_NAME = os.getenv("APPLICATION_NAME", "OrderProcessor")
ENVIRONMENT = os.getenv("ENVIRONMENT", "prod")

# -----------------------------
# Logging
# -----------------------------

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

logger = logging.getLogger(__name__)

# -----------------------------
# CloudWatch Client
# -----------------------------

cloudwatch = boto3.client("cloudwatch", region_name=REGION)

COMMON_DIMENSIONS = [
    {"Name": "Application", "Value": APPLICATION_NAME},
    {"Name": "Environment", "Value": ENVIRONMENT},
]

# -----------------------------
# Publish metrics in batch
# -----------------------------

def publish_metrics(metric_batch):
    try:
        cloudwatch.put_metric_data(
            Namespace=NAMESPACE,
            MetricData=metric_batch
        )
        logger.info("Successfully published %d metrics", len(metric_batch))
    except ClientError as e:
        logger.error("Failed to publish metrics: %s", e)

# -----------------------------
# Simulate order processing
# -----------------------------

def process_order():
    processing_time = random.uniform(0.2, 2.5)
    time.sleep(processing_time)

    success = random.random() > 0.05
    revenue = random.uniform(10, 500) if success else 0

    return processing_time, success, revenue

# -----------------------------
# Main loop
# -----------------------------

def main():
    logger.info("Starting Order Processor metric publisher")

    while True:
        metric_batch = []
        queue_length = random.randint(0, 10)

        orders_in_batch = random.randint(1, 5)

        for _ in range(orders_in_batch):
            processing_time, success, revenue = process_order()

            # OrdersProcessed (per event)
            metric_batch.append({
                "MetricName": "OrdersProcessed",
                "Dimensions": COMMON_DIMENSIONS,
                "Value": 1,
                "Unit": "Count"
            })

            # Processing time
            metric_batch.append({
                "MetricName": "OrderProcessingTime",
                "Dimensions": COMMON_DIMENSIONS,
                "Value": processing_time,
                "Unit": "Seconds"
            })

            # Errors (separate counter)
            if not success:
                metric_batch.append({
                    "MetricName": "OrderErrors",
                    "Dimensions": COMMON_DIMENSIONS,
                    "Value": 1,
                    "Unit": "Count"
                })

            # Revenue
            if revenue > 0:
                metric_batch.append({
                    "MetricName": "Revenue",
                    "Dimensions": COMMON_DIMENSIONS,
                    "Value": revenue,
                    "Unit": "None"
                })

        # Queue length (gauge metric)
        metric_batch.append({
            "MetricName": "QueueLength",
            "Dimensions": COMMON_DIMENSIONS,
            "Value": queue_length,
            "Unit": "Count"
        })

        publish_metrics(metric_batch)

        time.sleep(10)


if __name__ == "__main__":
    main()